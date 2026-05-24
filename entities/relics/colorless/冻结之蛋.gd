extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_won(context: Context, owner: RelicUI) -> void:
	context.upgrade_power = true
	owner.flash()
