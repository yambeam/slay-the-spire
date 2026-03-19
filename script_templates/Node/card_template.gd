# meta-name: 卡牌逻辑
# meta-description: 卡牌逻辑脚本的模板
# 记得删掉class_name
class_name MyCard
extends Card

func apply_effects(targets: Array[Node]) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 6
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
