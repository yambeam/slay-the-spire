class_name GainMaxHealthEffect
extends Effect

@export var max_health_provider: NumericProvider

func apply(source: Node, targets: Array[Node], card_context: Dictionary, previous_result: Variant = null) -> Variant:
	var value = max_health_provider.get_value(previous_result, card_context)
	#var card: Card = card_context.get("card")
	#var modifiers :Array[Modifier] = []
	#if card and card.has_enchantment():
		#modifiers.append_array(card.enchantment.get_modifiers_by_type(Enums.NumericType.DAMAGE))
	var total_max_health := 0
	for target: Creature in targets:
		total_max_health += target.gain_max_health(GainMaxHealthContext.new(source, target, value))
		await source.get_tree().create_timer(0.2).timeout
	return total_max_health
	
