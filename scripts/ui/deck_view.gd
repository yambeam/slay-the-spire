class_name DeckView
extends Control

const CARD_MENU_UI = preload("res://scenes/ui/card_menu_ui.tscn")

@onready var card_grid_container: GridContainer = $MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/CardGridContainer
# 卡牌检视界面，通过点击CardMenuUI实例显示
@onready var card_inspect: CardInspect = %CardInspect
@onready var back_button: ComfirmButton = $BackButton
@onready var hint: Label = $MarginContainer/VBoxContainer/hint
@onready var upgrade_card_inspect: UpgradeCardInspect = $UpgradeCardInspect

@onready var confirm_button: ComfirmButton = $ConfirmButton

enum SelectionMode{
	NONE,
	UPGRADE,
	ENCHANTE,
	CHANGE,
	SELECT
}

var selection_mode: SelectionMode = SelectionMode.NONE
var max_selection: int = 0
var min_selection: int = 0
var selected_cards: Array[Card] = []

signal selection_confirmed()

var all_cards: Array[Card]
var current_idx: int = -1

func hide_deck_view() -> void:
	hide()
	for child in card_grid_container.get_children():
		child.queue_free()

func _ready() -> void:
	back_button.pressed.connect(
		func():
			if selection_mode != SelectionMode.NONE:
				selected_cards = []
				selection_confirmed.emit()
			hide()
			
	)
	confirm_button.pressed.connect(
		func():
			if selection_mode != SelectionMode.NONE:
				selection_confirmed.emit()
			hide()
	)
	card_inspect.last_card_requested.connect(_on_last_card_requested)
	card_inspect.next_card_requested.connect(_on_next_card_requested)
	upgrade_card_inspect.cancel.connect(_on_upgrade_cancelled)
	upgrade_card_inspect.confirm.connect(_on_upgrade_confirmed)
	for card_ui: Node in card_grid_container.get_children():
		card_ui.queue_free()
		
	card_inspect.hide()
	upgrade_card_inspect.hide()
	confirm_button.hide()

func _update_view(randomized: bool) -> void:
	if randomized:
		all_cards.shuffle()
	for card: Card in all_cards:
		var new_card_ui := CARD_MENU_UI.instantiate() as CardMenuUI
		card_grid_container.add_child(new_card_ui)
		new_card_ui.card = card
		if selection_mode:
			new_card_ui.inspect_card_requested.connect(_on_card_selected)
		else:
			new_card_ui.inspect_card_requested.connect(_on_inspect_card_requested)
	
func _on_inspect_card_requested(card: Card) -> void:
	var idx := all_cards.find(card)
	current_idx = idx
	var last_available = idx > 0
	var next_available = idx < all_cards.size() - 1
	card_inspect.show_card(card, last_available, next_available)

func _on_card_selected(card: Card) -> void:
	match selection_mode:
		SelectionMode.UPGRADE:
			#print("enter")
			if max_selection == 1:
				#print("show")
				upgrade_card_inspect.show_card(card)
			else:
				_on_card_select_normal(card)
				
		_:
			_on_card_select_normal(card)

func _on_card_select_normal(card: Card) -> void:
	if card in selected_cards:
		selected_cards.erase(card)
		_set_card_ui_highlight(card, false)
		confirm_button.visible = len(selected_cards) >= min_selection
	else:
		if selected_cards.size() < max_selection:
			selected_cards.append(card)
			_set_card_ui_highlight(card, true)
			confirm_button.visible = len(selected_cards) >= min_selection
		elif selected_cards.size() == max_selection and max_selection == 1:
			_set_card_ui_highlight(selected_cards[0], false)
			selected_cards.clear()
			selected_cards.append(card)
			_set_card_ui_highlight(card, true)

func _set_card_ui_highlight(card: Card, highlight: bool):
	for child in card_grid_container.get_children():
		if child.card == card:
			if highlight:
				child.modulate = Color(1, 1, 0.1, 1)
			else:
				child.modulate = Color(1, 1, 1, 1)
			break

func _on_inspect_upgrade_card_requested(card: Card) -> void:
	upgrade_card_inspect.show_card(card)

# 检视界面点击左箭头的回调函数
func _on_last_card_requested() -> void:
	if current_idx - 1 < 0:
		return 
	current_idx -= 1
	var last_available = current_idx > 0
	var next_available = current_idx < all_cards.size() - 1
	card_inspect.show_card(all_cards[current_idx], last_available, next_available)
#检视界面点击右箭头的回调函数
func _on_next_card_requested() -> void:
	if current_idx + 1 > all_cards.size() - 1:
		return 
	current_idx += 1
	var last_available = current_idx > 0
	var next_available = current_idx < all_cards.size() - 1
	card_inspect.show_card(all_cards[current_idx], last_available, next_available)

# 显示牌堆
func show_card_pile(pile: Array[Card], hint_text: String, randomized: bool = false) -> void:
	if visible:
		hide()	
		return
	selection_mode = SelectionMode.NONE
	all_cards = pile
	hint.text = hint_text
	for card_ui: Node in card_grid_container.get_children():
		card_ui.queue_free()
	card_inspect.hide()
	upgrade_card_inspect.hide()
	# 等待queue_free
	_update_view.call_deferred(randomized)
	show()

func select_card_pile(pile: Array[Card], min_select: int = 0, max_select: int = 1, hint_text: String = "选择卡牌", selection_mode_: SelectionMode = SelectionMode.SELECT) -> Array[Card]:
	if min_select >= pile.size():
		return pile
	selection_mode = selection_mode_
	max_selection = max_select
	min_selection = min_select
	selected_cards.clear()
	hint.text = hint_text
	all_cards = pile
	for card_ui: Node in card_grid_container.get_children():
		card_ui.queue_free()
	_update_view(false)
	confirm_button.visible = len(selected_cards) >= min_selection
	back_button.visible = true
	#back_button.visible = min_select == 0
	show()
	await selection_confirmed
	return selected_cards

func _input(event: InputEvent) -> void:
	# ESC
	if event.is_action_pressed("ui_cancel"):
		if card_inspect.visible:
			card_inspect.hide()
		else:
			hide()

func _on_upgrade_confirmed(card: Card) -> void:
	#card.upgrade()
	selected_cards.append(card)
	selection_confirmed.emit()
	upgrade_card_inspect.hide()
	hide()
	
func _on_upgrade_cancelled() -> void:
	selected_cards.clear()
	upgrade_card_inspect.hide()
