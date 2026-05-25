class_name CalamityBuff
extends Buff

func initialize() -> void:
	if agent is Player:
		Events.card_played.connect(_on_card_played)

func get_description() -> String:
	return description.format({"stacks": stacks})

func _on_card_played(card: Card, _card_context: Dictionary) -> void:
	if card.type == Card.Type.ATTACK:
		agent.gain_charge(GainChargeContext.new(stacks))
