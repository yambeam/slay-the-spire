extends Card

func apply_effects(context: Context) -> void:
	var block_effect := BlockEffect.new()
	context.amount = 5
	block_effect.sound = sound
	block_effect.execute(context)
