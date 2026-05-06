extends Relic

func on_picked_up(_run_stats: RunStats, char_stats: CharacterStats, select_deck_view: DeckView) -> void:
	var enchantment: Enchantment = ItemPool.enchantment_dict["注能"]
	var selected_cards = await select_deck_view.select_card_pile(char_stats.get_deck()\
	.filter(func(card: Card): return enchantment.can_enchant(card)), 2, 2)
	for card: Card in selected_cards:
		card.enchantment = enchantment.duplicate()
