extends Card

func apply_effects(context: Context) -> void:
	var numeric_entries: Array[NumericEntry] = get_numeric_entries()
	var lose_health_effect = LossHealthEffect.new()
	var apply_buff_effect = ApplyBuffEffect.new()
	var choose_card_effect = ChooseCardEffect.new()
	lose_health_effect.execute(LoseHealthContext.new(context.source, context.targets, 1))
	apply_buff_effect.execute(ApplyBuffContext.new(context.source, context.targets, get_numeric_value(numeric_entries, 0), StrengthBuff.new()))
	
