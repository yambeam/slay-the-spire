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

#当前是否处于保存状态
var is_restoring: bool = false
const BUFF_UI = preload("res://scenes/rooms/combat_room/combat_ui/buff_ui.tscn")

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
			char_stats.block = 0
			Events.combat_won.emit(RewardContext.new())



# 弃用
##修改2 ——————增加
#
## 保存战斗房间状态
## ============================================
## 保存战斗房间状态
## ============================================
#func get_save_state() -> Dictionary:
	#var state := {}
#
	#state["health"] = char_stats.health
	#state["energy"] = char_stats.energy
	#state["block"] = player.stats.block if player and player.stats else 0
#
	## 手牌
	#var hand_cards := []
	#for child in hand_manager.get_children():
		#if child is CardUI and child.card:
			#hand_cards.append(child.card.serialize())
	#print("保存手牌:", hand_cards)
	#state["hand_cards"] = hand_cards
#
	## 主技能充能
	#state["main_skill_charge"] = main_skill_ui.skill.current_charge if main_skill_ui.skill else 0
#
	## 玩家 Buff
	#var player_buffs := []
	#for buff in player.buff_manager.get_children():
		#if buff is Buff:
			#player_buffs.append(buff.serialize())
	#state["player_buffs"] = player_buffs
#
	## 敌人状态
	#var enemies_data := []
	#for enemy in enemy_handler.get_children():
		#if enemy is Enemy:
			#var ed := {
				#"health": enemy.stats.health,
				#"max_health": enemy.stats.max_health,
				#"block": enemy.stats.block,
				#"buffs": [],
				#"intent": enemy.get_intent_data()
			#}
			#for buff in enemy.buff_manager.get_children():
				#if buff is Buff:
					#ed["buffs"].append(buff.serialize())
			#enemies_data.append(ed)
	#state["enemies"] = enemies_data
#
#
	## 保存抽牌堆
	#state["draw_pile"] = []
	#if char_stats.draw_pile and not char_stats.draw_pile.is_empty():
		#for card in char_stats.draw_pile.cards:
			#state["draw_pile"].append(card.serialize())
	#
	## --- 调试打印开始 ---
	#print("========== COMBAT ROOM SAVED STATE ==========")
	#print("Player Health: %d / %d" % [char_stats.health, char_stats.max_health])
	#print("Player Energy: %d / %d" % [char_stats.energy, char_stats.max_energy])
	#print("Player Block: %d" % state.get("block", 0))
#
	## 手牌打印
	#var hand_cards_print := []
	#for child in hand_manager.get_children():
		#if child is CardUI:
			#var card = child.card
			#if card:
				#var name_display = card.id
				#if card.upgraded:
					#name_display += "+"
				#hand_cards_print.append("%s (cost:%d)" % [name_display, card.get_cost()])
			#else:
				#hand_cards_print.append("(empty card)")
	#print("Hand Cards (%d): [%s]" % [hand_cards_print.size(), ", ".join(hand_cards_print)])
#
	## 主技能
	#print("Main Skill Charge: %d" % state.get("main_skill_charge", -1))
#
	## 玩家 Buff 打印
	#print("Player Buffs (%d):" % state["player_buffs"].size())
	#for bd in state["player_buffs"]:
		#print("  - %s | stacks: %d" % [bd.get("buff_id", "??"), bd.get("stacks", 0)])
#
	## 敌人状态打印
	#print("Enemies (%d):" % enemies_data.size())
	#for i in range(enemies_data.size()):
		#var ed = enemies_data[i]
		#print("  Enemy %d:" % i)
		#print("    Health: %d / %d" % [ed["health"], ed["max_health"]])
		#print("    Block: %d" % ed["block"])
		#print("    Intent: %s" % ed.get("intent", {}).get("intent_name", "none"))
		#print("    Buffs (%d):" % ed["buffs"].size())
		#for bd in ed["buffs"]:
			#print("      - %s | stacks: %d" % [bd.get("buff_id", "??"), bd.get("stacks", 0)])
#
	#print("==============================================\n")
	#return state
#
##
### ============================================
### 恢复战斗房间状态
### ============================================
#func set_save_state(state: Dictionary) -> void:
	#if state.is_empty():
		#return
	#hand_manager.char_stats = char_stats
	## --- 0. 修复敌人数量：先删除多余的敌人 ---
	#var enemies_data: Array = state.get("enemies", [])
	#var current_enemies: Array = []
	#for child in enemy_handler.get_children():
		#if child is Enemy:
			#current_enemies.append(child)
#
	#for i in range(enemies_data.size(), current_enemies.size()):
		#current_enemies[i].queue_free()
	#if current_enemies.size() > enemies_data.size():
		#await get_tree().process_frame
#
	#current_enemies.clear()
	#for child in enemy_handler.get_children():
		#if child is Enemy:
			#current_enemies.append(child)
#
	## --- 1. 玩家基础属性 ---
	#char_stats.health = state.get("health", char_stats.health)
	#char_stats.energy = state.get("energy", char_stats.energy)
	#if player and player.stats:
		#player.stats.block = state.get("block", 0)
#
	## --- 2. 手牌恢复 ---
	#print("恢复前手牌数: ", hand_manager.get_children().size())
	#hand_manager.clear_hand()
	#print("恢复手牌:", state.get("hand_cards", []))
	#for card_data in state.get("hand_cards", []):
		#var card: Card = Card.deserialize(card_data)
		#if card:
			#hand_manager.add_card_to_hand(card)
	#hand_manager.set_cards()
	#print("恢复后手牌数: ", hand_manager.get_children().size())
#
	## --- 3. 主技能充能 ---
	#if main_skill_ui.skill:
		#main_skill_ui.skill.current_charge = state.get("main_skill_charge", 0)
#
	## --- 4. 玩家 Buff 恢复 + UI 重建（注意顺序：agent → stacks → add_child）---
	#for buff in player.buff_manager.get_children():
		#if buff is Buff:
			#buff.queue_free()
	#if player.buff_manager.get_child_count() > 0:
		#await get_tree().process_frame
#
	#for bd in state.get("player_buffs", []):
		#var buff: Buff = Buff.deserialize(bd)
		#if buff:
			#buff.agent = player
			#buff.stacks = bd["stacks"]          # 先设层数
			#player.buff_manager.add_child(buff)   # 再入树（_ready 会用正确 stacks）
#
	## 重建玩家 BuffUI
	#for child in player.buff_container.get_children():
		#child.queue_free()
	#for buff in player.buff_manager.get_children():
		#if buff is Buff:
			#var buff_ui := BUFF_UI.instantiate()
			#buff_ui.buff = buff
			#buff_ui.agent = player
			#player.buff_container.add_child(buff_ui)
#
	## --- 5. 敌人状态恢复 + Buff UI 重建 ---
	#for i in range(min(current_enemies.size(), enemies_data.size())):
		#var enemy: Enemy = current_enemies[i]
		#var data = enemies_data[i]
#
		#enemy.stats.max_health = data["max_health"]
		#enemy.stats.health    = data["health"]
		#enemy.stats.block     = data["block"]
#
		## 清空旧 Buff
		#for buff in enemy.buff_manager.get_children():
			#if buff is Buff:
				#buff.queue_free()
#
		## 恢复 Buff 数据（agent → stacks → add_child）
		#for bd in data["buffs"]:
			#var buff: Buff = Buff.deserialize(bd)
			#if buff:
				#buff.agent = enemy
				#buff.stacks = bd["stacks"]          # 先设正确层数
				#enemy.buff_manager.add_child(buff)  # 再入树
#
		## 重建敌人 BuffUI
		#for child in enemy.buff_container.get_children():
			#child.queue_free()
		#for buff in enemy.buff_manager.get_children():
			#if buff is Buff:
				#var buff_ui := BUFF_UI.instantiate()
				#buff_ui.buff = buff
				#buff_ui.agent = enemy
				#enemy.buff_container.add_child(buff_ui)
#
		## 恢复意图（此时 Buff 修饰器已正确注册）
		#if data.has("intent") and not data["intent"].is_empty():
			#enemy.set_intent_from_data(data["intent"])
		#enemy._update_stats()
		## 强制刷新意图显示，以重新计算伤害数值
		#if enemy.intents and enemy.current_intent:
			#enemy.intents.update_intent(enemy.current_intent)
#
	#
	#if player and player.stats:
		#player.stats.block = state.get("block", 0)
		#
	## 恢复抽牌堆
	#if state.has("draw_pile") and state["draw_pile"].size() > 0:
		#char_stats.draw_pile = CardPile.new()
		#for card_data in state["draw_pile"]:
			#var card = Card.deserialize(card_data)
			#if card:
				#char_stats.draw_pile.add_card(card)
#
	## --- 调试打印（保持原样）---
	#print("========== COMBAT ROOM RESTORED STATE ==========")
	#print("Player Health: %d / %d" % [char_stats.health, char_stats.max_health])
	#print("Player Energy: %d / %d" % [char_stats.energy, char_stats.max_energy])
	#print("Player Block: %d" % (player.stats.block if player and player.stats else -1))
#
	#var hand_cards_print := []
	#for child in hand_manager.get_children():
		#if child is CardUI:
			#var card = child.card
			#if card:
				#var name_display = card.id
				#if card.upgraded:
					#name_display += "+"
				#hand_cards_print.append("%s (cost:%d)" % [name_display, card.get_cost()])
			#else:
				#hand_cards_print.append("(empty card)")
	#print("Hand Cards (%d): [%s]" % [hand_cards_print.size(), ", ".join(hand_cards_print)])
#
	#print("Main Skill Charge: %d" % (main_skill_ui.skill.current_charge if main_skill_ui.skill else -1))
#
	#print("Player Buffs (%d):" % player.buff_manager.get_child_count())
	#for buff in player.buff_manager.get_children():
		#if buff is Buff:
			#print("  - %s | stacks: %d" % [buff.buff_name, buff.stacks])
#
	#var final_enemy_list: Array = []
	#for child in enemy_handler.get_children():
		#if child is Enemy:
			#final_enemy_list.append(child)
	#print("Enemies (%d):" % final_enemy_list.size())
	#for i in range(final_enemy_list.size()):
		#var enemy: Enemy = final_enemy_list[i]
		#print("  Enemy %d:" % i)
		#print("    Health: %d / %d" % [enemy.stats.health, enemy.stats.max_health])
		#print("    Block: %d" % enemy.stats.block)
		#print("    Intent: %s" % (enemy.current_intent.intent_name if enemy.current_intent else "none"))
		#print("    Buffs (%d):" % enemy.buff_manager.get_child_count())
		#for buff in enemy.buff_manager.get_children():
			#if buff is Buff:
				#print("      - %s | stacks: %d" % [buff.buff_name, buff.stacks])
	#print("================================================\n")
	#
# 没有意义
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#var mb := event as InputEventMouseButton
		#if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#accept_event() 

func stop_combat_resolver() -> void:
	if combat_resolver:
		combat_resolver.process_mode = Node.PROCESS_MODE_DISABLED
		combat_resolver.should_stop = true
		if combat_resolver.is_resolving:
			await combat_resolver.resolve_finished
