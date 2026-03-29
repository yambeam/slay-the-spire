class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var hand_manager: HandManager
@onready var player: Player = $"../Player"

var char_stats: CharacterStats

func _ready() -> void:
	Events.card_played.connect(_on_card_played)

func start_battle(char_stats_: CharacterStats) -> void:
	char_stats = char_stats_
	char_stats.draw_pile = char_stats_.deck.duplicate(true)
	char_stats.draw_pile.shuffle()
	char_stats.discard_pile = CardPile.new()
	start_turn()
	
func start_turn() -> void:
	player.start_turn()
	draw_cards(char_stats.cards_per_turn)

func end_turn() -> void:
	player.end_turn()
	discard_cards()

func draw_card() -> Card:
	reshuffle_deck_from_discard_pile()
	if char_stats.draw_pile.is_empty():
		# 抽牌堆与弃牌堆都没牌了
		return null
	var card = char_stats.draw_pile.draw_card()
	# 抽牌堆满了直接放入弃牌堆
	if hand_manager.get_child_count() >= 10:
		char_stats.discard_pile.add_card(card)
		return null
	hand_manager.add_card(card)
	hand_manager.set_cards()
	reshuffle_deck_from_discard_pile()
	return card

func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)

func disable_hand(flag: bool = true) -> void:
	for child:CardUI in hand_manager.get_children():
		child.disabled = flag

func discard_card(card: Card) -> void:
	for child: CardUI in hand_manager.get_children():
		if card == child.card:
			hand_manager.discard_card(child)
			char_stats.discard_pile.add_card(card)
			return
	printerr("player_handler")


func exhaust_hand_card(card: Card) -> void:
	for child: CardUI in hand_manager.get_children():
		if card == child.card:
			hand_manager.exhaust_card(child)
			char_stats.exhaust_pile.add_card(card)
			return
	printerr("player_handler")


func discard_cards() -> void:
	
	if hand_manager.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return
	var tween := create_tween()
	for child: CardUI in hand_manager.get_children():
		if child.card.ethereal:
			tween.tween_callback(char_stats.exhaust_pile.add_card.bind(child.card))
			#TODO:卡片消耗特效
		else:
			tween.tween_callback(char_stats.discard_pile.add_card.bind(child.card))
		tween.tween_callback(hand_manager.discard_card.bind(child))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	tween.finished.connect(
		func(): Events.player_hand_discarded.emit()
	)

func hide_hand() -> void:
	hand_manager.hide()
	
func show_hand() -> void:
	hand_manager.set_cards(true)
	hand_manager.show()
	
	
func get_hand() -> Array[Card]:
	var ret: Array[Card] = []
	for child: CardUI in hand_manager.get_children():
		ret.append(child.card)
	return ret
	
func reshuffle_deck_from_discard_pile() -> void:
	if not char_stats.draw_pile.is_empty():
		return
	
	while not char_stats.discard_pile.is_empty():
		char_stats.draw_pile.add_card(char_stats.discard_pile.draw_card())
	
	char_stats.draw_pile.shuffle()

func put_card_in_draw_pile(card: Card, top: bool = false) -> void:
	if top:
		char_stats.draw_pile.add_card_to_top(card)
	else:
		char_stats.draw_pile.add_card(card)
		char_stats.draw_pile.shuffle()

func put_card_in_discard_pile(card: Card) -> void:
	char_stats.discard_pile.add_card(card)

func update_hand() -> void:
	hand_manager.update_hand()

func _on_card_played(card: Card) -> void:
	if card.type == card.Type.POWER:
		# 能力牌打出后不进入任何牌堆
		return
	if card.exhaust:
		char_stats.exhaust_pile.add_card(card)
	else:
		put_card_in_discard_pile(card)
