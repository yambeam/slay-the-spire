class_name Enemy
extends Area2D

# offset: 根据贴图大小调整各个组件

@export var stats: Stats : set = _set_enemy_stats

@onready var reticles: Node2D = $Reticles
@onready var health_bar: HealthBar = $HealthBar
@onready var spine_manager: SpineManager = $SpineManager


func _set_enemy_stats(value: Stats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(_update_stats):
		stats.stats_changed.connect(_update_stats)
	
	_update_enemy()
	
func _update_stats() -> void:
	health_bar.update_stats(stats)

func _update_enemy() -> void:
	if not stats is Stats:
		printerr("enemy出错")
		return
	if not is_inside_tree():
		await ready
	
	spine_manager.skeleton_data_res = stats.animation
	_update_stats()

func take_damage(damage: int) -> void:
	if stats.health <= 0:
		return
	stats.take_damage(damage)
	if stats.health <= 0:
		print("敌人死亡")


func _on_area_entered(_area: Area2D) -> void:
	reticles.visible = true


func _on_area_exited(_area: Area2D) -> void:
	reticles.visible = false
