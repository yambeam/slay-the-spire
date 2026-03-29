# 记得删掉class_name
# !!一定记得把脚本附加到cardname.tres上
extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.sound = sound
	damage_effect.execute(DamageContext.new(context.source, context.targets, get_numeric_value(get_numeric_entries(), 0)))
	
