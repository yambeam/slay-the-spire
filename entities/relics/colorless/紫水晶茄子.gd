extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_won.connect(_combat_won.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_combat_won):
		Events.combat_won.disconnect(_combat_won)

func _combat_won(context: RewardContext, owner: RelicUI) -> void:
	context.extra_gold.append(15)
	owner.flash()
