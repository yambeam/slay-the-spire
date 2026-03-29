
extends Node2D


@onready var bessel_arrow: BesselArrow = $BesselArrow
@onready var area_2d: Area2D = $Area2D


var current_card: CardUI
var targeting := false

func _ready() -> void:
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_ended.connect(_on_card_aim_ended)

func _process(_delta: float) -> void:
	if not targeting:
		return 
	bessel_arrow.reset(current_card.global_position + current_card.size / 2, get_global_mouse_position())
	area_2d.position = get_local_mouse_position()
	
func _on_card_aim_started(card: CardUI) -> void:
	if not card.card.is_single_targeted():
		printerr("bug_at_card_target_selector")
		return
	bessel_arrow.show()
	targeting = true
	area_2d.monitoring = true
	area_2d.monitorable = true
	current_card = card

func _on_card_aim_ended(_card: CardUI) -> void:
	targeting = false
	area_2d.monitorable = false
	area_2d.monitoring = false
	current_card = null
	bessel_arrow.hide()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not current_card or not targeting:
		return
	if not current_card.targets.has(area):
		Events.target_selected.emit(area, current_card.card)
		current_card.targets.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if not current_card or not targeting:
		return
	Events.target_unselected.emit(current_card.card)
	current_card.targets.erase(area)
