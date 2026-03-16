class_name Player
extends Node2D

@export var stats: CharacterStats : set = _set_char_stats

@onready var hint_sprite: TextureRect = $Hint
@onready var hint_lable: Label = $Hint/HintLable
@onready var spine_manager: SpineManager = $SpineManager
@onready var health_bar: HealthBar = $HealthBar
@onready var hint_timer: Timer = $Timer



func _ready() -> void:
	Events.player_hited.connect(_hint)
	hint_timer.timeout.connect(
		func(): hint_sprite.visible = false
	)

func _hint(hint_text: String) -> void:
	hint_sprite.visible = true
	hint_lable.text = hint_text
	hint_timer.start(2.5)

func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	stats.take_damage(damage)
	
	if stats.health <= 0:
		Events.player_died.emit()
		print("玩家死亡")

func _set_char_stats(value: CharacterStats) -> void:
	stats = value
	# 导入变量的setter会在运行游戏时调用一次
	if not stats.stats_changed.is_connected(_update_stats):
		stats.stats_changed.connect(_update_stats)
	
	_update_player()

func _update_stats() -> void:
	health_bar.update_stats(stats)
	
func _update_player() -> void:
	if stats is not CharacterStats:
		printerr("player出现出错")
		return
	if not is_inside_tree():
		await ready
	
	spine_manager.skeleton_data_res = stats.animation
	_update_stats()
