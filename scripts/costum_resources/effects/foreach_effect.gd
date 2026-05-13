class_name ForeachEffect
extends Effect

@export var effects: Array[Effect]

func execute(source: Node, card_context: Dictionary = {}, previous_result: Variant = null) -> Variant:
	if sound:
		_play_sound_after_delay(source)
	for effect: Effect in effects:
		previous_result = await effect.execute(source, card_context, previous_result)
	return previous_result
