class_name TakeDamageOverTurnDebuff
extends Buff
	
func initialize() -> void:
	agent.turn_ended.connect(_on_turn_ended)

func get_modifier() -> Array[Modifier]:
	return []

func get_description() -> String:
	return description.format({"stacks": stacks})

func _on_turn_ended(_creature: Node2D) -> void:
	agent.take_damage_without_signals(stacks)
