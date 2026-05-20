class_name DiscoverCardView
extends ColorRect

signal card_selected(card: Card)

@onready var discovered_cards_container: HBoxContainer = $DiscoveredCardsContainer
@onready var skip_button: TextureButton = $SkipButton
@onready var peak_button: TextureButton = $PeakButton
@onready var discover_banner: TextureRect = $DiscoverBanner

const CARD_MENU_UI = preload("res://scenes/ui/card_menu_ui.tscn")

var peak_mode: bool = false
var skippable: bool = false

func _ready() -> void:
	skip_button.pressed.connect(_on_skip)
	peak_button.pressed.connect(_on_peak)
	
func select(cards: Array[Card], can_skip : bool = true, upgraded: bool = false, first_play_free: bool = false, duplicate_card: bool = true) -> Card:
	for child in discovered_cards_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	for card: Card in cards:
		var card_ui: CardMenuUI = CARD_MENU_UI.instantiate()
		var new_card = card.duplicate() if duplicate_card else card
		if upgraded:
			new_card.upgrade()
		card_ui.card = new_card
		discovered_cards_container.add_child(card_ui)
		
		card_ui.inspect_card_requested.connect(card_selected.emit)
	show()
	skip_button.visible = can_skip
	skippable = can_skip
	var ret: Card = await card_selected
	hide()
	if ret:
		ret.first_play_free = first_play_free
	return ret 
	
func _on_skip() -> void:
	card_selected.emit(null)

func _on_peak() -> void:
	peak_mode = !peak_mode
	discover_banner.visible = !peak_mode
	discovered_cards_container.visible = !peak_mode
	skip_button.visible = !peak_mode and skippable
	self_modulate.a = 0.0 if peak_mode else 0.502
