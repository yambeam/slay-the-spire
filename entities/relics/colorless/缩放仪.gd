extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_room_entered.connect(_on_combat_room_entered.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_room_entered.is_connected(_on_combat_room_entered):
		Events.combat_room_entered.disconnect(_on_combat_room_entered)
	
func _on_combat_room_entered(room: Room, _run_stats: RunStats, char_stats: CharacterStats) -> void:
	var encounter := room.enemy_encounter
	if encounter and encounter.type == EnemyEncounter.Type.BOSS:
		char_stats.health += 25
