extends Relic

func on_picked_up(run_stats: RunStats, _char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	var relic = ItemPool.current_relic_pool.pick_random()
	ItemPool.remove_relic(relic)
	run_stats.add_relic(relic.duplicate())
