extends Relic

func on_picked_up(_run_stats: RunStats, char_stats: CharacterStats, select_deck_view: DeckView) -> void:
	var candidates = ItemPool.current_card_pool.filter(func(card: Card): return card.rarity == Card.Rarity.RARE)
	RandomSetting.array_shuffle(candidates)
	var selected_cards := await select_deck_view.select_card_pile(
		candidates.slice(0, 5), 1, 1, "选择一张卡牌加入牌组"
	)
	if !selected_cards.is_empty():
		char_stats.add_card_to_deck(selected_cards[0].duplicate())
	var curse: Card = ItemPool.curse_and_status_card_dict.get("受伤", null)
	if curse:
		char_stats.add_card_to_deck(curse.duplicate())
