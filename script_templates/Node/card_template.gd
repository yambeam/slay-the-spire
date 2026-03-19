# meta-name: 卡牌逻辑
# meta-description: 卡牌逻辑脚本的模板
# 记得删掉class_name
# !!一定记得把脚本附加到cardname.tres上
class_name MyCard
extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := DamageEffect.new()
	context.amount = 6
	damage_effect.sound = sound
	damage_effect.execute(context)
	
