extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := DamageEffect.new()
	context.amount = 6
	damage_effect.sound = sound
	damage_effect.execute(context)
	
