extends Card

func apply_effects(context: Context) -> void:
	var choose_card_effect = ChooseCardEffect.new()
	var player: Player = context.source
	var target_cards: Array[Card] = player.get_hand_cards()
	target_cards.erase(self)
	await choose_card_effect.execute(ChooseCardContext.new(player, target_cards, "选择一张卡牌消耗", 1, 1, func(card: Card): player.exhaust_hand_card(card)))
	await player.draw_cards(DrawCardContext.new(context.source, context.targets, get_numeric_value(get_numeric_entries(), 0)))
