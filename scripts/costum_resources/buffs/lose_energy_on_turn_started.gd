class_name LoseEnergyOverTrunDebuff
extends Buff
	
func initialize() -> void:
	if agent is Player:
		agent.after_turn_started.connect(_on_after_turn_started)

func get_modifier() -> Array[Modifier]:
	return []

func get_description() -> String:
	return description.format({"stacks": stacks})
	
func _on_after_turn_started(_creature: Creature):
	(agent as Player).stats.energy -= stacks
