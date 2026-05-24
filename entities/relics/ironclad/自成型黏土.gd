extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.player_hit.connect(_on_player_hit.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.disconnect(_on_player_hit)
	
func _on_player_hit(owner: RelicUI) -> void:
	activate_relic(owner)
