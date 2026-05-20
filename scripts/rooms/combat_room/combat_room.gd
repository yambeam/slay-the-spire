class_name CombatRoom
extends Control

@export var enemy_encounter: EnemyEncounter
@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var combat_ui: CombatUI = %CombatUI
@onready var hand_manager: HandManager = $CombatUI/HandManager
@onready var hand_selelctor: HandSelector = %HandSelelctor
@onready var combat_resolver: CombatResolver = $CombatUI/CombatResolver
@onready var main_skill_ui: MainSkillUI = $CombatUI/MainSkill
@onready var back_ground_container: BackGroundContainter = $BackGroundContainer

# 子节点的所有char_stats由该节点分发
@export var char_stats: CharacterStats: set = _set_char_stats
@export var relics: RelicHandler

func _ready() -> void:
	# 这步应该在开始一局时进行
	#var new_stats: CharacterStats = char_stats.create_instance()
	
	enemy_handler.child_order_changed.connect(_on_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	# 调试用
	#start_combat()

func update_background(act: int) -> void:
	back_ground_container.update_background(act)

#不要每次都重新激活遗物  ——————修改1
func start_combat(skip_relics: bool = false) -> void:
	enemy_handler.setup_enemies(enemy_encounter)
	enemy_handler.reset_enemy_intents()
	# 调试用
	#char_stats = char_stats.create_instance()
	#
	combat_ui.char_stats = char_stats
	hand_manager.char_stats = char_stats
	hand_selelctor.char_stats = char_stats
	player.stats = char_stats
	
	#适时跳过
	if not skip_relics:
		relics.relics_activated.connect(_on_relics_activated)
		relics.activate_relics_by_trigger_type(Relic.TriggerType.START_OF_COMBAT)	
		
	main_skill_ui.set_skill(char_stats.main_skill)

func _on_add_card_pressed() -> void:
	var card = player_handler.draw_card()
	player_handler.add_card_to_hand(card)

func _on_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0 and is_instance_valid(relics):		
		relics.activate_relics_by_trigger_type(Relic.TriggerType.END_OF_COMBAT)
	
func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_intents()

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value


func _on_back_to_map_pressed() -> void:
	#if combat_resolver.is_resolving:
		#await combat_resolver.resolve_finished
	#Events.combat_won.emit()
	var enemies = get_tree().get_nodes_in_group("ui_enemies")
	for enemy: Enemy in enemies:
		enemy.take_damage_without_signals(9999)
	

func _on_relics_activated(type: Relic.TriggerType) -> void:
	match type:
		Relic.TriggerType.START_OF_COMBAT:
			player_handler.relics = relics
			player_handler.start_battle(char_stats)
			combat_ui.initialize_card_pile_view()
			Events.combat_start.emit()
		Relic.TriggerType.END_OF_COMBAT:
			if combat_resolver.is_resolving:
				await combat_resolver.resolve_finished
			#await get_tree().create_timer(0.5).timeout
			Events.combat_won.emit(RewardContext.new())



#修改2 ——————增加

# 保存战斗房间状态
func get_save_state() -> Dictionary:
	var state := {}

	state["health"] = char_stats.health
	state["energy"] = char_stats.energy
	state["block"] = player.stats.block if player and player.stats else 0

	# 手牌
	var hand_cards := []
	for child in hand_manager.get_children():
		if child is CardUI and child.card:
			hand_cards.append(child.card.serialize())
	print("保存手牌:",hand_cards)
	state["hand_cards"] = hand_cards

	# 主技能充能
	state["main_skill_charge"] = main_skill_ui.skill.current_charge if main_skill_ui.skill else 0

	# 玩家 Buff
	var player_buffs := []
	for buff in player.buff_manager.get_children():
		if buff is Buff:
			player_buffs.append(buff.serialize())
	state["player_buffs"] = player_buffs

	# 敌人状态
	var enemies_data := []
	for enemy in enemy_handler.get_children():
		if enemy is Enemy:
			var ed := {
				"health": enemy.stats.health,
				"block": enemy.stats.block,
				"buffs": [],
				"intent": enemy.get_intent_data()
			}
			for buff in enemy.buff_manager.get_children():
				if buff is Buff:
					ed["buffs"].append(buff.serialize())
			enemies_data.append(ed)
	state["enemies"] = enemies_data

	return state

func set_save_state(state: Dictionary) -> void:
	if state.is_empty():
		return

	# 基础属性
	char_stats.health = state.get("health", char_stats.health)
	char_stats.energy = state.get("energy", char_stats.energy)
	if player and player.stats:
		player.stats.block = state.get("block", 0)

	# 手牌恢复
	hand_manager.clear_hand()
	print("恢复手牌:",state.get("hand_cards", []))
	for card_data in state.get("hand_cards", []):
		var card: Card = Card.deserialize(card_data)
		print("deserialize ", card_data.id, " -> ", card)
		if card:
			hand_manager.add_card_to_hand(card)
	hand_manager.set_cards()         

	# 主技能充能
	if main_skill_ui.skill:
		main_skill_ui.skill.current_charge = state.get("main_skill_charge", 0)

	# 玩家 Buff：先清空，再重建
	for buff in player.buff_manager.get_children():
		if buff is Buff:
			buff.queue_free()
	await get_tree().process_frame     # 确保旧 Buff 已移除
	for bd in state.get("player_buffs", []):
		var buff: Buff = Buff.deserialize(bd)
		if buff:
			player.buff_manager.add_child(buff)
			buff.stacks = bd["stacks"]

	# 敌人状态
	var enemies_data: Array = state.get("enemies", [])
	var enemy_list: Array = []
	for child in enemy_handler.get_children():
		if child is Enemy:
			enemy_list.append(child)

	for i in range(min(enemy_list.size(), enemies_data.size())):
		var enemy: Enemy = enemy_list[i]
		var data = enemies_data[i]
		enemy.stats.health = data["health"]
		enemy.stats.block = data["block"]
		# 敌人 Buff 清理
		for buff in enemy.buff_manager.get_children():
			if buff is Buff:
				buff.queue_free()
		for bd in data["buffs"]:
			var buff: Buff = Buff.deserialize(bd)
			if buff:
				enemy.buff_manager.add_child(buff)
				buff.stacks = bd["stacks"]
		# 恢复意图
		if data.has("intent") and not data["intent"].is_empty():
			enemy.set_intent_from_data(data["intent"])
		enemy._update_stats()
		if enemy.has_method("update_intent"):
			enemy.update_intent()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event() 
