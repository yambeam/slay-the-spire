extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := AttackEffect.new()
	damage_effect.sound = sound
	damage_effect.execute(DamageContext.new(context.source, context.targets, get_numeric_value(get_numeric_entries(), 0)))
	
