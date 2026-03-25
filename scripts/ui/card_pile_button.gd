class_name CardPileButton
extends TextureButton

@export var label: Label
@export var card_pile: CardPile: set = _set_card_pile

func _set_card_pile(value: CardPile) -> void:
	card_pile = value
	if not card_pile.card_pile_size_changed.is_connected(_on_card_pile_size_changed):
		card_pile.card_pile_size_changed.connect(_on_card_pile_size_changed)
		_on_card_pile_size_changed(card_pile.cards.size())
		
func _on_card_pile_size_changed(card_pile_size: int) -> void:
	label.text = str(card_pile_size)
