extends Relic

func on_picked_up(_run_stats: RunStats, _char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	count = 3
	
func initialize_relic(owner: RelicUI) -> void:
	owner.update_count()
	
func activate_relic(owner: RelicUI) -> void:
	if count > 0:
		count -= 1
		super.activate_relic(owner)
		owner.update_count()
