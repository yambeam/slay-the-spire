extends Relic

var energy_count := 0

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won)
	Events.player_turn_started.connect(_on_player_turn_started.bind(owner))
	Events.player_turn_ended.connect(_on_player_turn_ended.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)
	if Events.player_turn_started.is_connected(_on_player_turn_started):
		Events.player_turn_started.disconnect(_on_player_turn_started)
	if Events.player_turn_ended.is_connected(_on_player_turn_ended):
		Events.player_turn_ended.disconnect(_on_player_turn_ended)
	
func _on_combat_won(_context) -> void:
	energy_count = 0

func _on_player_turn_started(owner: RelicUI):
	var player: Player = owner.get_tree().get_first_node_in_group("ui_player")
	player.gain_energy(GainEnergyContext.new(energy_count))

func _on_player_turn_ended(owner: RelicUI):
	var player: Player = owner.get_tree().get_first_node_in_group("ui_player")
	energy_count = player.stats.energy
