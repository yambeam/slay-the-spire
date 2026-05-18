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
