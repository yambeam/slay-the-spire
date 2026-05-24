extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.card_exhausted.connect(_on_card_exhausted.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.card_exhausted.is_connected(_on_card_exhausted):
		Events.card_exhausted.disconnect(_on_card_exhausted)

func _on_card_exhausted(_card: Card, owner: RelicUI) -> void:
	activate_relic(owner)
	owner.flash()
