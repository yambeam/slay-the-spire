# 记得删掉class_name
extends Card

func apply_effects(context: Context) -> void:
	var numeric_entries := get_numeric_entries()
	var damage_effect := AttackEffect.new()
	damage_effect.sound = sound
	damage_effect.execute(DamageContext.new(context.source, context.targets, get_numeric_value(numeric_entries, 0)))
	var buff_effect := ApplyBuffEffect.new()
	buff_effect.execute(ApplyBuffContext.new(context.source, \
	context.targets, get_numeric_value(numeric_entries, 1), VulnerableDebuff.new()))
