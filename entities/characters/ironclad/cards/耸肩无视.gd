extends Card

func apply_effects(context: Context) -> void:
	var numeric_entries = get_numeric_entries()
	var block_effect := BlockEffect.new()
	block_effect.sound = sound
	block_effect.execute(GainBlockContext.new(context.source, context.targets, get_numeric_value(numeric_entries, 0)))
	var draw_card_effect = DrawCardEffect.new()
	draw_card_effect.execute(DrawCardContext.new(context.source, [context.source], get_numeric_value(numeric_entries, 1)))
	
