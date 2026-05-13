class_name TerritorialBuff
extends Buff

func initialize() -> void:
	if agent and agent.has_signal("turn_ended"):
		agent.turn_ended.connect(_on_turn_ended)

func get_description() -> String:
	return description.format({"stacks": stacks})

func _on_turn_ended(creature: Node2D) -> void:
	print("test")
	(creature as Creature).apply_buff(ApplyBuffContext.new(creature, creature, stacks, "力量"))
