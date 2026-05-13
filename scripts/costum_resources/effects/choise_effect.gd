class_name ChoiceEffect
extends Effect

#@export var card_filter: CardFilter
#@export var can_skip: bool = false
#@export var upgraded: bool = false
#@export var first_play_free: bool = false
@export var cards_to_choose: Array[Card]

func apply(source: Node, targets: Array[Node], _card_context: Dictionary, _previous_result: Variant = null) -> Variant:
	if source is Player:
		if animation_name and source is Player:
			source.animate_player(animation_name)
			await source.get_tree().create_timer(animation_delay).timeout
		else:
			await source.get_tree().create_timer(0.1).timeout
		return {"selected_cards": [await source.choice_for_cards(cards_to_choose)], "source_pile": null}

	elif targets[0] is Player:
		return {"selected_cards": [await targets[0].choice_for_cards(cards_to_choose)], "source_pile": null}
	return null
	
