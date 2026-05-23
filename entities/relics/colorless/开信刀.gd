extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.card_played.connect(_on_card_played.bind(owner))
	Events.player_turn_started.connect(func():
		temp_count = 0
		owner.update_count()
		)

func _on_card_played(card: Card, _card_context:Dictionary, owner: RelicUI) -> void:
	if card.type == Card.Type.SKILL:
		if temp_count < 2:
			temp_count += 1
		else:
			activate_relic(owner)
			temp_count = 0
		owner.update_count()
