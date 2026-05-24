extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.campfire_entered.connect(_on_campfire_entered.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.campfire_entered.is_connected(_on_campfire_entered):
		Events.campfire_entered.disconnect(_on_campfire_entered)

func _on_campfire_entered(_room: Room, _run_stats: RunStats, char_stats: CharacterStats, owner: RelicUI) -> void:
	var deck_count := len(char_stats.get_deck())
	char_stats.health += floor(deck_count / 5.0) * 3
	owner.flash()
