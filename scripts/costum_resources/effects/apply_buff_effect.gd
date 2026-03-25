class_name ApplyBuffEffect
extends Effect

func execute(context: Context) -> void:
	for target: Creature in context.targets:
		if target:
			# 给每个目标单独上buff
			context.source.apply_buff(ApplyBuffContext.new(context.source, [target], context.amount, context.buff_node.duplicate()))
	SFXPlayer.play(sound)
