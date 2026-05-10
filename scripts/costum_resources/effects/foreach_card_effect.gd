class_name ForeachCardEffect
extends Effect

@export var effects: Array[CardEffect]

func execute(source: Node, card_context: Dictionary = {}, previous_result: Variant = null) -> Variant:
	if previous_result is Dictionary:
		var cards: Array = previous_result["selected_cards"]
		var total: int = 0
		for card: Card in cards:
			var context = card_context.duplicate()
			context["target_card"] = card
			context["source_pile"] = previous_result["source_pile"]
			var last = null
			for effect: CardEffect in effects:
				last = await effect.execute(source, context, last)
			# 可能有某些效果会阻挡对card的effect，这时会返回0，否则返回1
			if last is int:
				total += last
		return total
	return 0
	
