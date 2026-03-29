extends Card

func apply_effects(context: Context) -> void:
	var numeric_entries: Array[NumericEntry] = get_numeric_entries()
	var lose_health_effect = LossHealthEffect.new()
	var apply_buff_effect = ApplyBuffEffect.new()
	var choose_card_effect = ChooseCardEffect.new()
	var player: Player = context.source
	lose_health_effect.execute(LoseHealthContext.new(player, context.targets, 1))
	apply_buff_effect.execute(ApplyBuffContext.new(player, context.targets, get_numeric_value(numeric_entries, 0), StrengthBuff.new()))
	var target_cards: Array[Card]
	for card: Card in player.get_hand_cards():
		if not card.ethereal:
			target_cards.append(card)
	target_cards.erase(self)
	choose_card_effect.execute(ChooseCardContext.new(player, target_cards, "选择一张卡牌消耗", 1, 1, func(card: Card): player.exhaust_hand_card(card)))
