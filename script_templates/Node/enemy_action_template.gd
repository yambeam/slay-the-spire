# meta-name: 敌人行动逻辑
# meta-description: 敌人行动逻辑脚本的模板(已弃用，现在使用Intent资源配置敌人行动)
# 记得把class_name删掉
class_name MyEnemyAction
extends EnemyAction

@export var block := 10
@export var damage:= 3

# 条件行动必须实现 
func is_performable() -> bool:
	return false

func perform_action() -> void:
	if not enemy or not target:
		return
		
	var block_effect := BlockEffect.new()
	var damage_effect := DamageEffect.new()
	block_effect.execute(GainBlockContext.new(enemy, [enemy], block))
	damage_effect.sound = intent.sound
	damage_effect.execute(DamageContext.new(enemy, [target], damage))
		
