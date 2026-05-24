extends Relic

var used := false

func initialize_relic(owner: RelicUI) -> void:
	Events.player_hand_drawn.connect(_on_player_hand_drawn.bind(owner))	
	Events.combat_won.connect(_on_combat_won)

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.player_hand_drawn.is_connected(_on_player_hand_drawn):
		Events.player_hand_drawn.disconnect(_on_player_hand_drawn)
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)
	
func _on_player_hand_drawn(owner: RelicUI) -> void:
	if not used:
		activate_relic(owner)
		used = true

func _on_combat_won(_context) -> void:
	used = false
