extends Card

func apply_effects(context: Context) -> void:
	# 造成6点伤害
	var attack_effect := AttackEffect.new()
	context.amount = 6
	attack_effect.sound = sound
	attack_effect.execute(context)
	context.source.put_card_in_discard_pile(self.duplicate())
	# 将一张愤怒复制品加入弃牌堆（需要在后续实现复制逻辑，这里仅作示例）
	# 暂时留空或通过 Buff 实现
