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
	char_stats.block = 0
	char_stats.energy = char_stats.max_energy
	draw_cards(char_stats.cards_per_turn)

func end_turn() -> void:
	player.end_turn()
	discard_cards()

func draw_card() -> void:
	reshuffle_deck_from_discard_pile()
	if char_stats.draw_pile.is_empty():
		# 抽牌堆与弃牌堆都没牌了
		return
	if hand_manager.get_child_count() >= 10:
		# 手牌满了
		return
	hand_manager.add_card(char_stats.draw_pile.draw_card())
	hand_manager.set_cards()
	reshuffle_deck_from_discard_pile()

func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)

func disable_hand() -> void:
	for child:CardUI in hand_manager.get_children():
		child.disabled = true

func discard_card(card_ui:CardUI) -> void:
	pass

func discard_cards() -> void:
	var tween := create_tween()
	for child: CardUI in hand_manager.get_children():
		tween.tween_callback(char_stats.discard_pile.add_card.bind(child.card))
		tween.tween_callback(hand_manager.discard_card.bind(child))
		tween.tween_interval(HAND_DISCARD_INTERVAL)
	tween.finished.connect(
		func(): Events.player_hand_discarded.emit()
	)

func reshuffle_deck_from_discard_pile() -> void:
	if not char_stats.draw_pile.is_empty():
		return
	
	while not char_stats.discard_pile.is_empty():
		char_stats.draw_pile.add_card(char_stats.discard_pile.draw_card())
	
	char_stats.draw_pile.shuffle()

func _on_card_played(card: Card) -> void:
	if card.exhaust:
		char_stats.exhaust_pile.add_card(card)
	else:
		char_stats.discard_pile.add_card(card)
