class_name CharacterStats
extends Stats

enum COLOR {
	RED = 0b0000001,	# 铁甲战士
	GREEN = 0b0000010,	# 静默猎手
	ORANGE = 0b0000100, # 储君
	PINK = 0b0001000,	# 亡灵契约师
	BLUE = 0b0010000,	# 故障机器人
}

@export_group("游戏数据")
@export var color: COLOR = COLOR.RED
@export var starting_deck: CardPile
@export var draftable_cards: CardPile
@export var cards_per_turn: int
@export var max_energy: int
@export var starting_relic: Relic
@export_group("视觉效果")
## 角色的名称
@export var character_name: String
## 角色的图标
@export var character_icon: Texture2D
## 角色的描述，选人界面时使用
@export var character_description: String
## 角色的技能 
@export var main_skill: MainSkill

@export var energy: int : set = _set_energy
@export var deck: CardPile
@export var discard_pile: CardPile
@export var draw_pile: CardPile
@export var exhaust_pile: CardPile

func _set_energy(value: int) -> void:
	energy = value
	stats_changed.emit()

func reset_energy() -> void:
	energy = max_energy
	
func can_play_card(card: Card) -> bool:
	if card.first_play_free:
		return true
	return energy >= card.get_cost()

func get_draw_pile() -> Array[Card]:
	return draw_pile.cards

func get_discard_pile() -> Array[Card]:
	return discard_pile.cards

func get_exhaust_pile() -> Array[Card]:
	return exhaust_pile.cards

func get_deck() -> Array[Card]:
	return deck.cards

func add_card_to_deck(card: Card) -> void:
	deck.add_card(card)
	Events.card_added_to_deck.emit(card, self)

func create_instance() -> CharacterStats:
	var instance := self.duplicate()
	instance.health = max_health
	instance.block = 0
	instance.reset_energy()
	instance.deck = instance.starting_deck.duplicate()
	instance.draw_pile = CardPile.new()
	instance.discard_pile = CardPile.new()
	instance.exhaust_pile = CardPile.new()
	return instance

func take_damage(damage: int) -> int:
	if damage <= 0:
		return false
	var actual_damage: int
	#实际伤害
	actual_damage = clampi(damage - block, 0, damage)
	#计算护甲
	block = clampi(block - damage, 0, block)
	health -= actual_damage
	if health<=0:
		print("角色生命值小于0，角色死亡")
		Events.player_died_outside.emit()
	return actual_damage
