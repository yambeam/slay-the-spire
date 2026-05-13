class_name CurlUpBuff
extends Buff

	
func initialize() -> void:
	if agent is Enemy:
		agent.after_take_damage.connect(_on_after_take_damage)

func get_modifier() -> Array[Modifier]:
	return []
	
func _on_after_take_damage(_context: Context) -> void:
	agent.gain_block(GainBlockContext.new(agent, agent, stacks, [], true))
	agent.enemy_ai.curled = true
	agent.spine_anim_state.set_animation("curl", false, 0)
	agent.spine_anim_state.add_animation("curled_loop", 0, false, 0)
	remove_stack(stacks)
