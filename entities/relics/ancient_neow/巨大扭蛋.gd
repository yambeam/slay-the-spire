extends Relic

func on_picked_up(run_stats: RunStats, char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	var strike_and_defend_cards := ItemPool.get_cards_by_color(char_stats.color).filter(func(card: Card): return card.id == "打击" or card.id == "防御")
	var relics := ItemPool.current_relic_pool.duplicate()
	RandomSetting.array_shuffle(relics)
	for relic: Relic in relics.slice(0, 2):
		run_stats.add_relic(relic.duplicate())
		ItemPool.remove_relic(relic)
	for card: Card in strike_and_defend_cards:
		char_stats.add_card_to_deck(card.duplicate())
