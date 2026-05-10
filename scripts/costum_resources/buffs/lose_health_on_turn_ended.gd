# 记得改类名
class_name LoseHealthOnTurnEnded
extends Buff
	
func initialize() -> void:
	if agent and agent.has_signal("turn_ended"):
		agent.connect("turn_ended", _on_turn_ended)
		
func get_modifier() -> Array[Modifier]:
	return []

func get_description() -> String:
	return description.format({"stacks": stacks})

func _on_turn_ended(source: Creature) -> void:
	source.lose_health(LoseHealthContext.new(source, source, stacks, [], true))
