extends EnemyAction

@export var block := 10
@export var damage:= 3

func perform_action() -> void:
	if not enemy or not target:
		return
		
	var block_effect := BlockEffect.new()
	var damage_effect := DamageEffect.new()
	block_effect.execute(GainBlockContext.new(enemy, [enemy], block))
	damage_effect.sound = intent.sound
	damage_effect.execute(DamageContext.new(enemy, [target], damage))
		
	Events.enemy_action_completed.emit(enemy)
