class_name SlowDebuff
extends Buff
	
func initialize() -> void:
	if agent and agent.has_signal("before_take_damage"):
		agent.connect("before_take_damage", _on_before_take_damage)
	else:
		return
	if agent and agent.has_signal("turn_ended"):
		agent.connect("turn_ended", _on_turn_ended)
	Events.card_played.connect(_on_card_played)

func get_modifier() -> Array[Modifier]:
	if stacks == 1:
		return []
	var modifier := Modifier.new(Enums.NumericType.DAMAGE, 0, 1 + 0.01 * stacks, null)
	return [modifier]

func _on_before_take_damage(context: Context) -> void:
	if stacks == 1:
		return 
	else:
		context.modifiers.append(Modifier.new(Enums.NumericType.DAMAGE, 0, 1 + 0.01 * stacks, null))

func _on_turn_ended(_creature: Node2D) -> void:
	remove_stack(stacks - 1) 

func _on_card_played(_card, _card_context) -> void:
	if stacks == 1:
		add_stack(9)
	else:
		add_stack(10)
			
