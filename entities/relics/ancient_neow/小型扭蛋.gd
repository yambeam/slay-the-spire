extends Relic

func on_picked_up(run_stats: RunStats, _char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	var relic = RandomSetting.array_pick_random(ItemPool.get_current_relic_pool())
	ItemPool.remove_relic(relic)
	run_stats.add_relic(relic.duplicate())
