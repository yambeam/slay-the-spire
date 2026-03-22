class_name CharacterStats
extends Stats


@export_group("游戏数据")
@export var starting_deck: CardPile
@export var cards_per_turn: int
@export var max_energy: int
@export_group("视觉效果")
## 角色的名称
@export var character_name: String
## 角色的图标
@export var character_icon: Texture2D
## 角色的描述，选人界面时使用
@export var character_description: String

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
