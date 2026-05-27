extends Relic

var used := false

func initialize_relic(_owner: RelicUI) -> void:
	Events.card_played.connect(_on_card_played)
	Events.combat_won.connect(_on_combat_won)
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_turn_ended.is_connected(_on_combat_won):
		Events.player_turn_ended.disconnect(_on_combat_won)

func _on_card_played(card: Card, card_context: Dictionary) -> void:
	if not used:
		var player = card_context.get("player", null)
		if player and card.type == Card.Type.POWER:
			(player as Player).gain_block(GainBlockContext.new(player, player, 7, [], true))
			used = true

func _on_combat_won(_context) -> void:
	used = false
