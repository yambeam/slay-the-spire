extends Relic

func on_picked_up(run_stats: RunStats, char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	run_stats.max_potion_slots += 4
	var random_potions = ItemPool.get_potions(Potion.COLOR.COLORLESS + char_stats.color, ItemPool.potion_rarity_mask).slice(0, run_stats.max_potion_slots)
	for potion: Potion in random_potions:
		run_stats.add_potion(potion)
