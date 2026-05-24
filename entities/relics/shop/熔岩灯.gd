extends Relic

var available := false

func initialize_relic(_owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won)

func activate_relic(owner: RelicUI) -> void:
	var player = owner.get_tree().get_first_node_in_group("ui_player") as Player
	if player and player.player_hit_this_combat == 0:
		available = true
		owner.flash()
	else:
		available = false

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)

func _on_combat_won(context: RewardContext) -> void:
	if available:
		context.upgrade_all = true
		available = false
