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

# 子节点的所有char_stats由该节点分发
@export var char_stats: CharacterStats: set = _set_char_stats
@export var music: AudioStream
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
	

func start_combat() -> void:
	MusicPlayer.play(music, true)
	enemy_handler.setup_enemies(enemy_encounter)
	enemy_handler.reset_enemy_intents()
	# 调试用
	#char_stats = char_stats.create_instance()
	#
	combat_ui.char_stats = char_stats
	hand_manager.char_stats = char_stats
	hand_selelctor.char_stats = char_stats
	player.stats = char_stats
	
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



# 保存战斗房间状态
func get_save_state() -> Dictionary:
	var state := {}
	
	# 血量、能量、格挡
	state["health"] = char_stats.health
	state["max_health"] = char_stats.max_health
	state["energy"] = char_stats.energy
	state["block"] = player.stats.block if player and player.stats else 0
	
	# 手牌（序列化每张牌的关键数据）
	var hand_cards := []
	for card in hand_manager.get_all_cards_in_hand():
		hand_cards.append(card.serialize())
	state["hand_cards"] = hand_cards
	
	# 抽牌堆、弃牌堆、消耗堆（如果需要）
	# state["draw_pile"] = ...
	# state["discard_pile"] = ...
	
	# 主技能冷却（假设 main_skill_ui 有 current_cooldown 属性）
	if main_skill_ui.has_method("get_cooldown"):
		state["main_skill_cooldown"] = main_skill_ui.get_cooldown()
	
	# 玩家身上的 Buff/状态效果
	var player_buffs := []
	for effect in player.status_effects:
		player_buffs.append(effect.serialize())
	state["player_buffs"] = player_buffs
	
	# 敌人状态（血量、格挡、Buff）
	var enemies_data := []
	for enemy in enemy_handler.get_children():
		var ed := {
			"health": enemy.health,
			"block": enemy.block,
			"buffs": []
		}
		for effect in enemy.status_effects:
			ed["buffs"].append(effect.serialize())
		enemies_data.append(ed)
	state["enemies"] = enemies_data
	
	return state

# 恢复战斗房间状态
func set_save_state(state: Dictionary) -> void:
	if state.is_empty():
		return
	
	# 恢复血量
	char_stats.health = state.get("health", char_stats.health)
	char_stats.max_health = state.get("max_health", char_stats.max_health)
	char_stats.energy = state.get("energy", char_stats.energy)
	if player and player.stats:
		player.stats.block = state.get("block", 0)
	
	# 恢复手牌（先清空，再添加）
	hand_manager.clear_hand()
	for card_data in state.get("hand_cards", []):
		var card = Card.deserialize(card_data)
		hand_manager.add_card_to_hand(card)
	
	# 恢复主技能冷却
	if main_skill_ui.has_method("set_cooldown"):
		main_skill_ui.set_cooldown(state.get("main_skill_cooldown", 0))
	
	# 恢复玩家 Buff
	player.clear_buffs()
	for buff_data in state.get("player_buffs", []):
		var buff = StatusEffect.deserialize(buff_data)
		player.apply_status_effect(buff)
	
	# 恢复敌人状态
	var enemies_data: Array = state.get("enemies", [])
	var enemy_children = enemy_handler.get_children()
	for i in range(min(enemy_children.size(), enemies_data.size())):
		var enemy = enemy_children[i]
		var data = enemies_data[i]
		enemy.health = data["health"]
		enemy.block = data["block"]
		enemy.clear_buffs()
		for bd in data["buffs"]:
			var buff = StatusEffect.deserialize(bd)
			enemy.apply_status_effect(buff)
