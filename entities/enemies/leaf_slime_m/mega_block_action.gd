extends EnemyAction


@export var block := 13
@export var hp_threshhold := 0.9

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
	var block_effect := BlockEffect.new()
	block_effect.amount = block
	block_effect.sound = intent.sound
	block_effect.execute([enemy])	
	Events.enemy_action_completed.emit(enemy)
	
