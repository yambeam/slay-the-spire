extends Relic

func on_picked_up(_run_stats: RunStats, char_stats: CharacterStats, _deck_view: DeckView) -> void:
	var candidates := char_stats.get_deck().filter(func(card: Card): return card.type == Card.Type.SKILL)
	if len(candidates) == 0:
		return 
	RandomSetting.array_shuffle(candidates)
	candidates = candidates.slice(0, 2)
	for card: Card in candidates:
		card.upgrade()
		
