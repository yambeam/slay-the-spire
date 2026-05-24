extends Relic

func on_picked_up(_run_stats: RunStats, _char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	count = 2
	temp_count = count

func initialize_relic(owner: RelicUI) -> void:
	owner.update_count()
	Events.combat_won.connect(
		func(context: RewardContext):
			if temp_count > 0:
				context.upgrade_all = true
				temp_count -= 1
				if owner != null:
					owner.update_count()
	)
