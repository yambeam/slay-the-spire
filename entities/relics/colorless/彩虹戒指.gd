extends Relic

var attack_played := false
var skill_played := false
var power_played := false
var used := false

func initialize_relic(owner: RelicUI) -> void:
	Events.card_played.connect(_on_card_played.bind(owner))
	Events.player_turn_started.connect(_on_player_turn_started)
	
func deactivate_relic(_owner: RelicUI) -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.player_turn_started.is_connected(_on_player_turn_started):
		Events.card_played.disconnect(_on_player_turn_started)

func _on_card_played(card: Card, _card_context: Dictionary, owner: RelicUI) -> void:
	if used:
		return
	match card.type:
		Card.Type.ATTACK:
			attack_played = true
		Card.Type.SKILL:
			skill_played = true
		Card.Type.POWER:
			power_played = true
	if attack_played and skill_played and power_played:
		activate_relic(owner)
		used = true

func _on_player_turn_started() -> void:
	attack_played = false
	skill_played = false
	power_played = false
	used = false
