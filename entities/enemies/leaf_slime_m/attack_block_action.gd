extends EnemyAction

@export var block := 10
@export var damage:= 3

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
