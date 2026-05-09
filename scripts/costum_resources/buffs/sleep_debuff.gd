class_name SleepDebuff
extends Buff

func initialize() -> void:
	if agent is Enemy:
		agent.turn_ended.connect(_on_turn_ended)
		agent.after_take_damage.connect(_on_after_take_damage)
		
func get_modifier() -> Array[Modifier]:
	return []

func get_description() -> String:
	return description.format({"stacks": stacks})
	
func _on_after_take_damage(context: Context) -> void:
	if context.amount > 0:
		remove_stack(stacks)

func _on_turn_ended(_creature: Creature) -> void:
	remove_stack(1)

func remove_stack(amount: int):
	stacks = clampi(stacks - amount, min_stack, max_stack)
	if stacks == 0:
		agent.enemy_ai.awake = true
		queue_free()

func _on_after_turn_started(creature: Creature) -> void:
	creature.gain_block(GainBlockContext.new(creature, creature, stacks, [], true))
	remove_stack(stacks)
