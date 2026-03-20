# 记得删掉class_name
extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := DamageEffect.new()
	context.amount = 8
	damage_effect.sound = sound
	damage_effect.execute(context)
	var buff_effect := ApplyBuffEffect.new()
	buff_effect.execute(ApplyBuffContext.new(context.source, \
	context.targets, 2, VulnerableDebuff.new()))
