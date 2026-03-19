extends EnemyAction

@export var damage:= 5

# 条件行为必须实现该函数
func is_performable() -> bool:
	return false

func perform_action() -> void:
	if not enemy or not target:
		return
	var damage_effect := DamageEffect.new()
	damage_effect.sound = intent.sound
	damage_effect.execute(DamageContext.new(enemy, [target], damage))
	Events.enemy_action_completed.emit(enemy)
