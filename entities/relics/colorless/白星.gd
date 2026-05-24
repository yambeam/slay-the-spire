extends Relic

var available := false

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_room_entered.connect(_on_combat_room_entered)
	Events.combat_won.connect(_on_combat_won.bind(owner))
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_room_entered.is_connected(_on_combat_room_entered):
		Events.combat_room_entered.disconnect(_on_combat_room_entered)
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_room_entered(room: Room, _run_stats, _char_stats) -> void:
	if room.enemy_encounter.type == EnemyEncounter.Type.ELITE:
		available = true
	else:
		available = false
	
func _on_combat_won(context: RewardContext, owner: RelicUI) -> void:
	if available:
		context.all_rare = true
		owner.flash()
		available = false
