extends Card

func apply_effects(context: Context) -> void:
	# 造成6点伤害
	var attack_effect := AttackEffect.new()
	attack_effect.sound = sound
	attack_effect.execute(DamageContext.new(context.source, context.targets, get_numeric_value(get_numeric_entries(), 0)))
	# 这个真的需要effect?
	context.source.put_card_in_discard_pile(self.duplicate())
