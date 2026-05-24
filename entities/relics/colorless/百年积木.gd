extends Relic

var used = false

func initialize_relic(owner: RelicUI) -> void:
	Events.player_hit.connect(_on_player_hit.bind(owner))
	Events.combat_won.connect(_on_combat_won)

func activate_relic(owner: RelicUI) -> void:
	if not used:
		super.activate_relic(owner)
		used = true

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.disconnect(_on_player_hit)
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_player_hit(owner: RelicUI) -> void:
	activate_relic(owner)

func _on_combat_won() -> void:
	used = false
	
