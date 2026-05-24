extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.card_exhausted.connect(_on_card_exhausted.bind(owner))

func _on_card_exhausted(_card: Card, owner: RelicUI) -> void:
	if temp_count < 4:
		temp_count += 1
	else:
		temp_count = 0
		activate_relic(owner)
	owner.update_count()
	
