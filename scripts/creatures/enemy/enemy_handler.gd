class_name EnemyHandler
extends Node2D

func _ready() -> void:
	Events.enemy_action_completed.connect(_on_enemy_action_completed)

func reset_enemy_intents() -> void:
	for child: Enemy in get_children():
		child.current_intent = null
		child.update_intent()

func start_turn() -> void:
	if get_child_count() == 0:
		return
	
	var first_enemy: Enemy = get_child(0)
	first_enemy.do_turn()

func _on_enemy_action_completed(enemy: Enemy) -> void:
	# 最后一个敌人行动结束
	if enemy.get_index() == get_child_count() - 1:
		Events.enemy_turn_ended.emit()
		return
	(get_child(enemy.get_index() + 1) as Enemy).do_turn()
