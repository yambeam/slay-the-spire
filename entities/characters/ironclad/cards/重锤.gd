extends Card

func apply_effects(context: Context) -> void:
	# 造成32点伤害
	var attack_effect := AttackEffect.new()
	context.amount = get_numeric_value(get_numeric_entries(), 0)
	attack_effect.sound = sound
	attack_effect.execute(context)
