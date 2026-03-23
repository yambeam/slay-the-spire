class_name DeckView
extends Control

const CARD_MENU_UI = preload("res://scenes/ui/card_menu_ui.tscn")

@export var card_pile: CardPile
@onready var card_grid_container: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/CardGridContainer
@onready var card_inspect: CardInspect = %CardInspect
@onready var back_button: Button = %BackButton
@onready var hint: Label = $MarginContainer/VBoxContainer/hint

var all_cards: Array[Card]
var current_idx: int = -1

func _ready() -> void:
	back_button.pressed.connect(hide)
	card_inspect.last_card_requested.connect(_on_last_card_requested)
	card_inspect.next_card_requested.connect(_on_next_card_requested)

	for card_ui: Node in card_grid_container.get_children():
		card_ui.queue_free()
	
	card_inspect.hide()

func _update_view(randomized: bool) -> void:
	if not card_pile:
		return
	all_cards = card_pile.cards.duplicate()
	if randomized:
		all_cards.shuffle()
	for card: Card in all_cards:
		var new_card_ui := CARD_MENU_UI.instantiate() as CardMenuUI
		card_grid_container.add_child(new_card_ui)
		new_card_ui.card = card
		new_card_ui.inspect_card_requested.connect(_on_inspect_card_requested)
	
func _on_inspect_card_requested(card: Card) -> void:
	var idx := all_cards.find(card)
	current_idx = idx
	var last_available = idx > 0
	var next_available = idx < all_cards.size() - 1
	card_inspect.show_card(card, last_available, next_available)

func _on_last_card_requested() -> void:
	if current_idx - 1 < 0:
		return 
	current_idx -= 1
	var last_available = current_idx > 0
	var next_available = current_idx < all_cards.size() - 1
	card_inspect.show_card(all_cards[current_idx], last_available, next_available)


func _on_next_card_requested() -> void:
	if current_idx + 1 > all_cards.size() - 1:
		return 
	current_idx += 1
	var last_available = current_idx > 0
	var next_available = current_idx < all_cards.size() - 1
	card_inspect.show_card(all_cards[current_idx], last_available, next_available)

func show_card_pile(hint_text: String, randomized: bool = false) -> void:
	hint.text = hint_text
	for card_ui: Node in card_grid_container.get_children():
		card_ui.queue_free()
	card_inspect.hide()
	# 等待queue_free
	_update_view.call_deferred(randomized)
	show()
	
func _input(event: InputEvent) -> void:
	# ESC
	if event.is_action_pressed("ui_cancel"):
		if card_inspect.visible:
			card_inspect.hide()
		else:
			hide()
			
