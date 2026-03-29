extends Card

func apply_effects(context: Context) -> void:
	var attack_effect := AttackEffect.new()
	attack_effect.sound = sound
	attack_effect.execute(DamageContext.new(context.source, context.targets, \
	get_numeric_value(get_numeric_entries(), 0, context.source, context.targets[0])))
