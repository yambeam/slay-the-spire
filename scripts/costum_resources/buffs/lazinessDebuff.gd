class_name LazzinessDebuff
extends Buff

var count = 0

func initialize() -> void:
	if agent is Player:
		Events.card_played.connect(_on_card_played)
		agent.turn_ended.connect(_on_turn_ended)

func get_modifier() -> Array[Modifier]:
	return []

func _on_turn_ended(_creature:Creature) -> void:
	count = 0

func get_description() -> String:
	return description.format({"stacks": stacks})
	
func _on_card_played(_card: Card, _card_context: Dictionary) -> void:
	count += 1
	if count >= stacks:
		(agent as Player).agent.end_turn()	
