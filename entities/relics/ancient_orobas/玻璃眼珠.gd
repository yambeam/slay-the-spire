extends Relic

func on_picked_up(_run_stats: RunStats, char_stats: CharacterStats, select_deck_view: DeckView) -> void:
	var candidates :Array[Card] = ItemPool.get_cards_by_color(char_stats.color)
	var common_cards: Array[Card] = candidates.filter(func(card: Card): return card.rarity == Card.Rarity.COMMON).slice(0, 5)
	var uncommon_cards: Array[Card] = candidates.filter(func(card: Card): return card.rarity == Card.Rarity.UNCOMMON).slice(0, 5)
	var rare_cards: Array[Card] = candidates.filter(func(card: Card): return card.rarity == Card.Rarity.RARE).slice(0, 5)
	candidates.clear()
	candidates.append_array(common_cards)
	candidates.append_array(uncommon_cards)
	candidates.append_array(rare_cards)
	var cards: Array[Card] = await select_deck_view.select_card_pile(candidates, 0, 15, "选择任意张卡牌加入牌组")
	for card: Card in cards:
		char_stats.add_card_to_deck(card.duplicate())
