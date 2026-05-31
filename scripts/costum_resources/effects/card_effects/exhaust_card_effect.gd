class_name ExhaustCardEffect
extends CardEffect

func execute(source: Node, card_context: Dictionary = {}, _previous_result: Variant = null) -> Variant:
	var card = card_context.get("target_card", null)
	var source_pile = card_context.get("source_pile", -1)
	if !(card is Card):
		return 0
	match source_pile:
		SelectCardEffect.Where.HAND:
			(source as Player).exhaust_hand_card(card)
			return 1
		SelectCardEffect.Where.DRAW_PILE:
			(source as Player).exhaust_draw_pile_card(card)
			return 1
		SelectCardEffect.Where.DISCARD_PILE:
			(source as Player).exhaust_discard_pile_card(card)
			return 1
		_:
			return 0
		
	
