# 记得删掉class_name
# !!一定记得把脚本附加到cardname.tres上
extends Card

func apply_effects(context: Context) -> void:
	var numeric_entries := get_numeric_entries()
	var attack_effect := AttackEffect.new()
	attack_effect.sound = sound
	attack_effect.execute(DamageContext.new(context.source, context.targets, get_numeric_value(numeric_entries, 0)))
	var apply_buff_effect := ApplyBuffEffect.new()
	apply_buff_effect.execute(ApplyBuffContext.new(context.source, context.targets, get_numeric_value(numeric_entries, 1), WeaknessDebuff.new()))
	
