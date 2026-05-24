extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.card_added_to_deck.connect(_on_card_added_to_deck.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.card_added_to_deck.is_connected(_on_card_added_to_deck):
		Events.card_added_to_deck.disconnect(_on_card_added_to_deck)

func _on_card_added_to_deck(_card: Card, char_stats: CharacterStats, owner: RelicUI) -> void:
	if temp_count < 4:
		temp_count += 1
	else:
		char_stats.health += 20
		temp_count = 0
	owner.update_count()
