extends Card

func apply_effects(context: Context) -> void:
	# 获得5点格挡
	var source: Player = context.source
	var block_effect := BlockEffect.new()
	block_effect.sound = sound
	block_effect.execute(GainBlockContext.new(source, context.targets, get_numeric_value(get_numeric_entries(), 0)))
	var choose_card_effect := ChooseCardEffect.new()
	var target_cards: Array[Card] = []
	for card: Card in source.get_hand_cards():
		if not card.upgraded:
			target_cards.append(card)
	target_cards.erase(self)
	if upgraded:
		choose_card_effect.execute(ChooseCardContext.new(source, target_cards, "选择一张手牌升级", 10, 10, func(card: Card): card.upgrade()))
	else:
		choose_card_effect.execute(ChooseCardContext.new(source, target_cards, "选择一张手牌升级", 1, 1, func(card: Card): card.upgrade()))
