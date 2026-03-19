# meta-name: 敌人行动逻辑
# meta-description: 敌人行动逻辑脚本的模板
# 记得把class_name删掉
class_name MyEnemyAction
extends EnemyAction

@export var block := 10
@export var damage:= 3

# 条件行为必须实现该函数
func is_performable() -> bool:
	return false

func perform_action() -> void:
	if not enemy or not target:
		return
	var block_effect := BlockEffect.new()
	var damage_effect := DamageEffect.new()
	block_effect.amount = block
	block_effect.execute([enemy])
	damage_effect.amount = damage
	damage_effect.sound = intent.sound
	damage_effect.execute([target])
		
	Events.enemy_action_completed.emit(enemy)
