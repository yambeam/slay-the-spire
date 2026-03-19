# 记得删掉class_name
extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := DamageEffect.new()
	context.amount = 8
	damage_effect.sound = sound
	damage_effect.execute(context)
	print("apply_damage")
	var buff_effect := ApplyBuffEffect.new()
	buff_effect.execute(ApplyBuffContext.new(context.source, \
	context.targets, context.amount, VunlerableDebuff.new()))
	print("apply_vunlerable")
