class_name CardInspectUI
extends CenterContainer

var tween: Tween

@export var card: Card: set = _set_card
@onready var visuals: CardVisuals = %Visuals



func _set_card(value: Card) -> void:
	if not value:
		return
	if not is_node_ready():
		await ready
	
	card = value
	visuals.card = value
	
