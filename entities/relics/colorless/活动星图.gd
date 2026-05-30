extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.unknown_room_entered.connect(_on_unknown_room_enterd.bind(owner))
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.unknown_room_entered.is_connected(_on_unknown_room_enterd):
		Events.unknown_room_entered.disconnect(_on_unknown_room_enterd)

func _on_unknown_room_enterd(_room, _run_stats, char_stats: CharacterStats, owner: RelicUI) -> void:
	char_stats.health += 5
	owner.flash()
