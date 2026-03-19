extends EnemyAction

@export var damage := 13
@export var hp_threshhold := 0.5

# 只允许使用一次
var already_used := false

func is_performable() -> bool:
	if not enemy or already_used:
		return false
	return enemy.stats.health <= enemy.stats.max_health * hp_threshhold

func perform_action() -> void:
	if not enemy or not target:
		return
	already_used = true
	var damage_effect := DamageEffect.new()
	damage_effect.amount = damage
	damage_effect.sound = intent.sound
	damage_effect.execute([target])	
	Events.enemy_action_completed.emit(enemy)
	
