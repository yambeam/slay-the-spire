extends Relic

func on_picked_up(_run_stats: RunStats, _char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	count = 2
	temp_count = count

func initialize_relic(owner: RelicUI) -> void:
	owner.update_count()
	Events.combat_won.connect(_on_combat_won.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_won(context: RewardContext, owner: RelicUI) -> void:
	if temp_count > 0:
		context.upgrade_all = true
		temp_count -= 1
		if owner != null:
			owner.update_count()
	
