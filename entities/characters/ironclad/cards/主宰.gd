extends Card

func apply_effects(context: Context) -> void:
	var apply_buff_effect := ApplyBuffEffect.new()
	apply_buff_effect.execute(ApplyBuffContext.new(context.source, \
	context.targets, 1, VulnerableDebuff.new()))
	# 该卡牌为单目标
	var buff_node: Buff = context.targets[0].get_buff("易伤")
	if not buff_node:
		return 
	apply_buff_effect.execute(ApplyBuffContext.new(context.source,\
	[context.source], buff_node.stacks, StrengthBuff.new()))
