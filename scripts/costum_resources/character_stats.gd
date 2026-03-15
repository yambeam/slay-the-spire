class_name CharacterStats
extends Stats

@export var starting_deck: CardPile
@export var cards_per_turn: int
@export var max_energy: int

var energy: int : set = _set_energy
var deck: CardPile
var discard_pile: CardPile
var draw_pile: CardPile
## TODO:消耗堆

func _set_energy(value: int) -> void:
	energy = value
	stats_changed.emit()

func reset_energy() -> void:
	energy = max_energy
	
func can_play_card(card: Card) -> bool:
	return energy >= card.cost

func create_instance() -> CharacterStats:
	var instance := self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.reset_energy()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard_pile = CardPile.new()
	return instance
