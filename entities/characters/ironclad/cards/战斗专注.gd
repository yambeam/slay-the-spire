extends Card

func apply_effects(context: Context) -> void:
	var draw_effect = DrawCardEffect.new()
	
	draw_effect.execute(DrawCardContext.new(context.source, [context.source], _get_numeric_entries()[0].base_value))
	var buff_effect = ApplyBuffEffect.new()
	buff_effect.execute(ApplyBuffContext.new(context.source, [context.source], 1, NoDrawDebuff.new()))
