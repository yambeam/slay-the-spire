extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.before_card_played.connect(_on_before_card_played.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.before_card_played.is_connected(_on_before_card_played):
		Events.before_card_played.disconnect(_on_before_card_played)

func _on_before_card_played(card: Card, card_context: Dictionary, owner: RelicUI) -> void:
	if card.is_x_cost:
		card_context["energy_cost"] = card_context.get("energy_cost", 0) + 2
		owner.flash()
