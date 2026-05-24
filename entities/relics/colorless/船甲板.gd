extends Relic

var turn = 0

func initialize_relic(_owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won)
	
func activate_relic(owner: RelicUI) -> void:
	turn += 1
	if turn == 2:
		super.activate_relic(owner)
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_won(_context) -> void:
	turn = 0
