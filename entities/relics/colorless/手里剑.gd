extends Relic


func initialize_relic(owner: RelicUI) -> void:
	Events.card_played.connect(_on_card_played.bind(owner))
	Events.player_turn_started.connect(_on_player_turn_started.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_turn_started.is_connected(_on_player_turn_started):
		Events.player_turn_started.disconnect(_on_player_turn_started)

func _on_card_played(card: Card, _card_context:Dictionary, owner: RelicUI) -> void:
	if card.type == Card.Type.ATTACK:
		if temp_count < 2:
			temp_count += 1
		else:
			activate_relic(owner)
			temp_count = 0
		owner.update_count()

func _on_player_turn_started(owner: RelicUI) -> void:
	temp_count = 0
	owner.update_count()
