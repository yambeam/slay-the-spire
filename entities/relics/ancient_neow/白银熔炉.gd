extends Relic

func on_picked_up(_run_stats: RunStats, _char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	count = 2

func initialize_relic(owner: RelicUI) -> void:
	owner.update_count()
	Events.combat_won.connect(
		func(context: RewardContext):
			if count > 0:
				context.upgrade_all = true
				count -= 1
				owner.update_count()
	)
