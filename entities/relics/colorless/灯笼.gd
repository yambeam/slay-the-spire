extends Relic

var used := false

func initialize_relic(_owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won)
	
func activate_relic(owner: RelicUI) -> void:
	if not used:
		super.activate_relic(owner)
		used = true

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_won(_context) -> void:
	used = false
