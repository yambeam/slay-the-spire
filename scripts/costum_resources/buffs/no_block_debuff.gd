class_name NoBlockEffect
extends Buff

func initialize() -> void:
	agent.before_gain_block.connect(_on_before_gain_block)
	agent.turn_ended.connect(_on_turn_ended)
		
func get_modifier() -> Array[Modifier]:
	var modifier := Modifier.new(Enums.NumericType.BLOCK, 0, 1.0, func(_block: int): return 0)
	return [modifier]
	
func _on_before_gain_block(context: Context) -> void:
	context.modifiers.append(Modifier.new(Enums.NumericType.BLOCK, stacks, 1.0, null))

func _on_turn_ended(_creature: Creature) -> void:
	remove_stack(1)
