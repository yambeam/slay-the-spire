extends EnemyAction

@export var damage:= 3

# 条件行为必须实现该函数
func is_performable() -> bool:
	return false

func perform_action() -> void:
	if not enemy or not target:
		return
	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage
	damage_effect.sound = intent.sound
	var tween := create_tween()
	tween.tween_callback(damage_effect.execute.bind([target] as Array[Node]))
	tween.tween_interval(0.3)
	tween.tween_callback(damage_effect.execute.bind([target] as Array[Node]))
	await tween.finished
	
	Events.enemy_action_completed.emit(enemy)
