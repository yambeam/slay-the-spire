extends Card

func apply_effects(context: Context) -> void:
	var buff_effect := ApplyBuffEffect.new()
	buff_effect.sound = sound
	buff_effect.execute(ApplyBuffContext.new(context.source, [context.source], 1, BarricadeBuff.new()))
