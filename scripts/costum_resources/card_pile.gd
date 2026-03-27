class_name CardPile
extends Resource

signal card_pile_size_changed(card_amout: int)

@export var cards: Array[Card] = []

func is_empty() -> bool:
	return cards.is_empty()

func draw_card() -> Card:
	var ret: Card = cards.pop_front()
	card_pile_size_changed.emit(cards.size())
	return ret

func add_card(card: Card) -> void:
	cards.append(card)
	card_pile_size_changed.emit(cards.size())

func add_card_to_top(card: Card) -> void:
	cards.insert(0, card)
	card_pile_size_changed.emit(cards.size())

func shuffle() -> void:
	cards.shuffle()
	
func clear() -> void:
	cards.clear()
	card_pile_size_changed.emit(0)
# 重写toString函数 便于调试
func _to_string() -> String:
	var _card_strings: PackedStringArray = []
	for i in range(cards.size()):
		_card_strings.append("%s: %s" % [i + 1, cards[i].id])
	return "\n".join(_card_strings)
