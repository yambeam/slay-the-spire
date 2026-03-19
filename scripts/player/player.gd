class_name Player
extends Node2D

@export var stats: CharacterStats : set = _set_char_stats

@onready var hint_sprite: TextureRect = $Hint
@onready var hint_lable: Label = $Hint/HintLable
@onready var spine_manager: SpineManager = $SpineManager
@onready var health_bar: HealthBar = $HealthBar
@onready var hint_timer: Timer = $Timer

var spine_anim_state: SpineAnimationState

func _ready() -> void:
	Events.player_hited.connect(_hint)
	Events.card_played.connect(_on_card_played)
	hint_timer.timeout.connect(
		func(): hint_sprite.visible = false
	)
	
func _hint(hint_text: String) -> void:
	hint_sprite.visible = true
	hint_lable.text = hint_text
	hint_timer.start(2.5)
	
func lose_health(amount: int) -> void:
	if stats.health <= 0:
		return
	
	stats.health -= amount

	if stats.health <= 0:
		health_bar.hide()
		Events.player_died.emit()
		spine_anim_state.set_animation("die", false, 0)
	else:
		Events.player_hit.emit()
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
		
func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	
	var hurt := stats.take_damage(damage)
	
	if stats.health <= 0:
		health_bar.hide()
		Events.player_died.emit()
		spine_anim_state.set_animation("die", false, 0)
	elif hurt:
		Events.player_hit.emit()
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
		
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
	await get_tree().process_frame
	spine_anim_state = spine_manager.get_animation_state()
	spine_anim_state.set_animation("idle_loop", true, 0)
	_update_stats()

func _on_card_played(card: Card) -> void:
	if card.type == Card.Type.ATTACK:
		spine_anim_state.set_animation("attack", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
	elif card.type == Card.Type.SKILL:
		spine_anim_state.set_animation("cast", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
	
