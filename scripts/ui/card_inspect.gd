class_name CardInspect
extends Control

signal last_card_requested
signal next_card_requested

@onready var color_rect: ColorRect = $ColorRect
@onready var inspected_card: CardInspectUI = %CardInspectUI

@onready var last: Button = $HBoxContainer/LeftButtonContainer/Last
@onready var next: Button = $HBoxContainer/RightButtonContainer/Next


func _ready() -> void:
	color_rect.gui_input.connect(_on_color_rect_gui_input)
	last.pressed.connect(
		func(): last_card_requested.emit()
	)
	next.pressed.connect(
		func(): next_card_requested.emit()
	)

func show_card(card: Card, last_available: bool = false, next_available: bool = false) -> void:
	inspected_card.card = card
	last.visible = last_available
	next.visible = next_available
	show()

func _on_color_rect_gui_input(input: InputEvent) -> void:
	if input.is_action_pressed("left_mouse"):
		hide()
