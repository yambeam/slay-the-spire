class_name Enemy
extends Area2D

# offset: 根据贴图大小调整各个组件

@export var stats: EnemyStats : set = _set_enemy_stats

@onready var reticles: Node2D = $Reticles
@onready var health_bar: HealthBar = $HealthBar
@onready var spine_manager: SpineManager = $SpineManager

var enemy_ai: EnemyActionPicker
var current_action: EnemyAction : set = _set_current_action

func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
		
	current_action.perform_action()
	update_action()

func _set_current_action(value: EnemyAction) -> void:
	current_action = value
	# TODO: 修改意图

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
	_update_stats()

func take_damage(damage: int) -> void:
	print("take_damage")
	if stats.health <= 0:
		return
	stats.take_damage(damage)
	if stats.health <= 0:
		print("敌人死亡")
		queue_free()


func _on_area_entered(_area: Area2D) -> void:
	reticles.visible = true


func _on_area_exited(_area: Area2D) -> void:
	reticles.visible = false
