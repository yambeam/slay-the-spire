extends Card

func apply_effects(context: Context) -> void:
	var numeric_entries: Array[NumericEntry] = get_numeric_entries()
	var apply_buff_effect := ApplyBuffEffect.new()
	apply_buff_effect.execute(ApplyBuffContext.new(context.source, \
	[context.source], get_numeric_value(numeric_entries, 0), StrengthBuff.new()))
	apply_buff_effect.sound = sound
	apply_buff_effect.execute(ApplyBuffContext.new(context.source,\
	[context.source], get_numeric_value(numeric_entries, 1), DemonFormBuff.new()))
