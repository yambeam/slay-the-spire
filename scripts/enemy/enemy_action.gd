class_name EnemyAction
extends Node

enum Type{CONDITIONAL, CHANCE_BASED, CONDITIONAL_OVER_TURN}

@export var type: Type
@export var intent: Intent
## 触发的权重，只对CHANCE_BASED类型的Action生效
@export_range(0.0, 10.0) var weight := 0.0
@export var anim_name: String
@onready var accumulated_weight := 0.0

var enemy: Enemy
var target: Node2D

# 在其他Action中实现
func is_performable() -> bool:
	return false

func perform_action() -> void:
	pass
