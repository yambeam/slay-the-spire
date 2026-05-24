extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.enemy_died.connect(_on_enemy_died.bind(owner))
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.enemy_died.is_connected(_on_enemy_died):
		Events.enemy_died.disconnect(_on_enemy_died)
	
func _on_enemy_died(owner: RelicUI) -> void:
	activate_relic(owner)
	owner.flash()
	
