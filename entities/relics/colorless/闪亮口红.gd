extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won.bind(owner))
	
func activate_relic(owner: RelicUI) -> void:
	if temp_count < 2:
		temp_count += 1
	else:
		super.activate_relic(owner)
		temp_count = 0
	owner.update_count()

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_won(_context, owner: RelicUI) -> void:
	temp_count = 0
	owner.update_count()
