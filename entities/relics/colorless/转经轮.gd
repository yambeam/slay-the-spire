extends Relic

var available := false

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_room_entered.connect(_on_combat_entered)
	Events.combat_won.connect(_on_combat_won.bind(owner))
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_room_entered.is_connected(_on_combat_entered):
		Events.combat_room_entered.disconnect(_on_combat_entered)
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_entered(room: Room, _run_stats: RunStats, _char_stats: CharacterStats) -> void:
	if room.enemy_encounter.type == EnemyEncounter.Type.STRONG or room.enemy_encounter.type == EnemyEncounter.Type.WEAK:
		available = true
	else:
		available = false

func _on_combat_won(context: RewardContext, owner: RelicUI) -> void:
	if available:
		context.extra_card_count += 1
		owner.flash()
		available = false
