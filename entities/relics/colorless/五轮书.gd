extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.card_added_to_deck.connect(_on_card_added_to_deck.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	print("如果由事件驱动，在这里解除")

func _on_card_added_to_deck(_card: Card, char_stats: CharacterStats, owner: RelicUI) -> void:
	if temp_count < 4:
		temp_count += 1
	else:
		char_stats.health += 20
		temp_count = 0
	owner.update_count()
