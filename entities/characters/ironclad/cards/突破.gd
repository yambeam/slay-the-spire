extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := DamageEffect.new()
	var lose_health_effect := LossHealthEffect.new()
	damage_effect.sound = sound
	# 找到玩家并从targets中去除
	var player_index: int
	var targets = context.targets
	for i in range(len(targets)):
		# 不要在遍历数组的同时修改数组
		if targets[i] is Player:
			player_index = i
	# RefCounted没有duplicate函数
	var lose_health_context = LoseHealthContext.new(context.source, [targets.pop_at(player_index)], 1)
	var	damage_context = DamageContext.new(context.source, targets, 8)
	lose_health_effect.execute(lose_health_context)
	damage_effect.execute(damage_context)
	
