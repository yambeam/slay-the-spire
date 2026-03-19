extends EnemyAction

@export var damage:= 3

# 条件行为必须实现该函数
func is_performable() -> bool:
	return false

func perform_action() -> void:
	if not enemy or not target:
		return
	var damage_effect := DamageEffect.new()
	damage_effect.sound = intent.sound
	var tween := create_tween()
	tween.tween_callback(damage_effect.execute.bind(DamageContext.new(enemy, [target], damage)))
	tween.tween_interval(0.3)
	tween.tween_callback(damage_effect.execute.bind(DamageContext.new(enemy, [target], damage)))
	await tween.finished
	
	Events.enemy_action_completed.emit(enemy)
