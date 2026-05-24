extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.card_played.connect(_on_card_played.bind(owner))
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)

func _on_card_played(_card: Card, _card_context: Dictionary, owner: RelicUI) -> void:
	var player = owner.get_tree().get_first_node_in_group("ui_player") as Player
	if player and len(player.get_hand_cards()) == 0:
		activate_relic(owner)
