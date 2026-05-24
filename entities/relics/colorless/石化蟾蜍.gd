extends Relic

var potion: Potion

func initialize_relic(_owner: RelicUI) -> void:
	potion = ItemPool.get_special_potion_by_name("药水形状的石头")
	Events.combat_room_entered.connect(_on_combat_room_entered)

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_room_entered.is_connected(_on_combat_room_entered):
		Events.combat_room_entered.disconnect(_on_combat_room_entered)
	
func _on_combat_room_entered(_room: Room, run_stats: RunStats, _char_stats: CharacterStats) -> void:
	if potion:
		run_stats.add_potion(potion.duplicate())
