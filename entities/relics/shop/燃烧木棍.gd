extends Relic

var used := false

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_won.connect(_on_combat_won)
	Events.card_exhausted.connect(_on_card_exhausted.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)
	if Events.card_exhausted.is_connected(_on_card_exhausted):
		Events.card_exhausted.disconnect(_on_card_exhausted)

func _on_combat_won(_context) -> void:
	used = false

func _on_card_exhausted(card: Card, owner: RelicUI) -> void:
	if not used and card.type == Card.Type.SKILL:
		var player = owner.get_tree().get_first_node_in_group("ui_player")
		if player:
			(player as Player).put_card_in_hand(card.duplicate())
			used = true
			owner.flash()
