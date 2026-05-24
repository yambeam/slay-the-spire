extends Relic

var used = false

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won)
	Events.player_hand_drawn.connect(activate_relic.bind(owner))
	
func activate_relic(owner: RelicUI) -> void:
	if used:
		return
	super.activate_relic(owner)
	used = true
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)
	if Events.player_hand_drawn.is_connected(activate_relic):
		Events.player_hand_drawn.disconnect(activate_relic)

func _on_combat_won(_context) -> void:
	used = false
