### Deprecated
class_name EnemyActionPicker
extends Node

@export var enemy: Enemy: set = _set_enemy
@export var target: Node2D: set = _set_target

@onready var total_weight := 0.0

func _ready() -> void:
	target = get_tree().get_first_node_in_group("ui_player")
	setup_chances()
	
func get_action() -> EnemyAction:
	var action := get_first_any_conditional_action()
	if action:
		return action
	return get_chance_based_action()
	
func get_first_any_conditional_action() -> EnemyAction:
	var ret: EnemyAction = get_first_conditional_action()
	return ret if ret != null else get_first_conditional_over_turn_action()
	
func get_first_conditional_action() -> EnemyAction:
	for action: EnemyAction in get_children():
		if not action or action.type != EnemyAction.Type.CONDITIONAL:
			continue
		if action.is_performable():
			return action
	return null

func get_first_conditional_over_turn_action() -> EnemyAction:
	for action: EnemyAction in get_children():
		if not action or action.type != EnemyAction.Type.CONDITIONAL_OVER_TURN:
			continue
		if action.is_performable():
			return action
	return null

func get_chance_based_action() -> EnemyAction:
	var roll := randf_range(0.0, total_weight)
	
	for action: EnemyAction in get_children():
		if not action or action.type != EnemyAction.Type.CHANCE_BASED:
			continue
		if action.accumulated_weight > roll:
			return action
	printerr("enemy_action_picker出错")
	return null

func setup_chances() -> void:
	for action: EnemyAction in get_children():
		if not action or action.type != EnemyAction.Type.CHANCE_BASED:
			continue
		total_weight += action.weight
		action.accumulated_weight = total_weight
		
func _set_enemy(value: Enemy) -> void:
	enemy = value
	
	for action: EnemyAction in get_children():
		action.enemy = value

func _set_target(value: Node2D) -> void:
	target = value
	
	for action: EnemyAction in get_children():
		action.target = value
