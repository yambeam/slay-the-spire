extends Card

func apply_effects(targets: Array[Node]) -> void:
	var damage_effect := DamageEffect.new()
	var lose_health_effect := LossHealthEffect.new()
	lose_health_effect.amount = 1
	damage_effect.amount = 8
	damage_effect.sound = sound
	# 找到玩家并从targets中去除
	var player_index: int
	for i in range(len(targets)):
		# 不要在遍历数组的同时修改数组
		if targets[i] is Player:
			player_index = i
	lose_health_effect.execute([targets.pop_at(player_index)])
	damage_effect.execute(targets)
	
