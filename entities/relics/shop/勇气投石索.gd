extends Relic

var available := false

func initialize_relic(_owner: RelicUI) -> void:
	Events.combat_room_entered.connect(_on_combat_room_entered)
	
func activate_relic(owner: RelicUI) -> void:
	if available:
		super.activate_relic(owner)
		
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_room_entered.is_connected(_on_combat_room_entered):
		Events.combat_room_entered.disconnect(_on_combat_room_entered)

func _on_combat_room_entered(room: Room, _run_stats: RunStats, _char_stats: CharacterStats) -> void:
	if room.enemy_encounter.type == EnemyEncounter.Type.ELITE:
		available = true
	else:
		available = false
