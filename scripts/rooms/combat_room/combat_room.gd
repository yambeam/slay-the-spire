extends Control

@onready var enemy_handler: EnemyHandler = $EnemyHandler
@onready var player: Player = $Player
@onready var player_handler: PlayerHandler = $PlayerHandler
@onready var combat_ui: CombatUI = $CombatUI
@onready var hand_manager: HandManager = $CombatUI/HandManager
# 子节点的所有char_stats由该节点分发
@export var char_stats: CharacterStats: set = _set_char_stats
@export var music: AudioStream

func _ready() -> void:
	# 这步应该在开始一局时进行
	var new_stats: CharacterStats = char_stats.create_instance()
	combat_ui.char_stats = new_stats
	hand_manager.char_stats = new_stats
	player.stats = new_stats
	enemy_handler.child_order_changed.connect(_on_child_order_changed)
	Events.enemy_turn_ended.connect(_on_enemy_turn_ended)
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(enemy_handler.start_turn)
	
	start_combat(new_stats)
	# 初始化牌堆
	combat_ui.initialize_card_pile_view()

func start_combat(char_stats_: CharacterStats) -> void:
	MusicPlayer.play(music, true)
	enemy_handler.reset_enemy_intents()
	player_handler.start_battle(char_stats_)

func _on_add_card_pressed() -> void:
	player_handler.draw_card()

func _on_child_order_changed() -> void:
	if enemy_handler.get_child_count() == 0:
		Events.combat_won.emit()
	
func _on_enemy_turn_ended() -> void:
	player_handler.start_turn()
	enemy_handler.reset_enemy_intents()

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value


func _on_back_to_map_pressed() -> void:
	Events.combat_won.emit()
