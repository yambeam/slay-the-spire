extends Relic

func on_picked_up(run_stats: RunStats, char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	match char_stats.color:
		CharacterStats.COLOR.RED:
			if run_stats.remove_relic_by_name("燃烧之血"):
				var ancient_relic := _find_starter_relic("黑暗之血")
				if ancient_relic:
					run_stats.add_relic(ancient_relic.duplicate())

func _find_starter_relic(target_relic_name: String) -> Relic:
	var starter_relics :Array[Relic] = ItemPool.get_relics_by_rarity(Relic.Rarity.STARTER_RELIC)
	for relic:Relic in starter_relics:
		if relic.relic_name == target_relic_name:
			return relic
	return null
