class_name Enemy
extends Area2D

signal turn_started(enemy: Enemy)
signal turn_ended(enemy: Enemy)
signal before_take_damage(context: Context)
signal before_lose_health(context: Context)
# offset: 根据贴图大小调整各个组件

@export var stats: EnemyStats : set = _set_enemy_stats

@onready var buff_container: Node = $BuffContainer
@onready var reticles: Node2D = $Reticles
@onready var health_bar: HealthBar = $HealthBar
@onready var spine_manager: SpineManager = $SpineManager
@onready var intents: HBoxContainer = $Intents

var enemy_ai: EnemyActionPicker
var current_action: EnemyAction : set = _set_current_action

var spine_anim_state: SpineAnimationState

func do_turn() -> void:
	start_turn()
	stats.block = 0
	
	if not current_action:
		return
		
	current_action.perform_action()
	spine_anim_state.set_animation(current_action.anim_name, true, 0)
	spine_anim_state.add_animation("idle_loop", 0, true, 0)
	update_action()

func _set_current_action(value: EnemyAction) -> void:
	current_action = value
	# TODO: 修改意图
	if not current_action:
		return
	intents.update_intent(current_action.intent)

func _set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(_update_stats):
		stats.stats_changed.connect(_update_stats)
	
	_update_enemy()

func _setup_ai() -> void:
	if enemy_ai:
		enemy_ai.queue_free()
	var new_ai :EnemyActionPicker = stats.ai.instantiate()
	add_child(new_ai)
	enemy_ai = new_ai
	enemy_ai.enemy = self

func start_turn() -> void:
	turn_started.emit(self)

func end_turn() -> void:
	turn_ended.emit(self)

func update_action() -> void:
	if not enemy_ai:
		return
	if not current_action:
		current_action = enemy_ai.get_action()
		return
	
	var new_conditional_action := enemy_ai.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action
	
func _update_stats() -> void:
	health_bar.update_stats(stats)
	update_action()

func _update_enemy() -> void:
	if not stats is Stats:
		printerr("enemy出错")
		return
	if not is_inside_tree():
		await ready
	
	spine_manager.skeleton_data_res = stats.animation
	_setup_ai()
	# 不等一帧的话get_animation_state返回的是null
	await get_tree().process_frame
	spine_anim_state = spine_manager.get_animation_state()
	spine_anim_state.set_animation("idle_loop", true, 0)
	_update_stats()
	
func lose_health(context: Context) -> void:
	if stats.health <= 0:
		return
	
	before_lose_health.emit(context)
	stats.health -= context.amount

	if stats.health <= 0:
		intents.hide()
		health_bar.hide()
		reticles.hide()
		spine_anim_state.set_animation("die", true, 0)
		spine_manager.animation_completed.connect(
			func (_x, _y, _z): queue_free()
		)
	else:
		spine_anim_state.set_animation("hurt", true, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)

func gain_block(context: Context):
	stats.block += context.amount

func take_damage(context: Context) -> void:
	if stats.health <= 0:
		return
	
	before_take_damage.emit(context)
	
	var hurt := stats.take_damage(context.amount)
	
	if stats.health <= 0:
		intents.hide()
		health_bar.hide()
		spine_anim_state.set_animation("die", true, 0)
		spine_manager.animation_completed.connect(
			func (_x, _y, _z): queue_free()
		)
	elif hurt:
		spine_anim_state.set_animation("hurt", true, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)


func _on_area_entered(_area: Area2D) -> void:
	reticles.visible = true


func _on_area_exited(_area: Area2D) -> void:
	reticles.visible = false
