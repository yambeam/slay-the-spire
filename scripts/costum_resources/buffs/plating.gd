# 记得改类名
class_name plating
extends Buff
	
func initialize() -> void:
	if agent and agent.has_signal("turn_ended"):
		agent.connect("turn_ended", _on_turn_ended)
		
func get_modifier() -> Array[Modifier]:
	return []

func get_description() -> String:
	return description.format({"stacks": stacks})

func _on_turn_ended(player: Creature) -> void:
	agent.gain_block(GainBlockContext.new(player, player, stacks, [], true))
	remove_stack(1)
