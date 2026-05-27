class_name CampfireRoom
extends Control

@export var char_stats: CharacterStats
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var spine_manager: SpineManager = $SpineManager

@onready var rest: Button = $UI/HBoxContainer/rest


@onready var forging: Button = $UI/HBoxContainer/forging


var deck_view: DeckView
var forgeable_cards: Array[Card]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	#$Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#$UI.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#$UI/HBoxContainer/rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#$UI/HBoxContainer/forging.mouse_filter = Control.MOUSE_FILTER_IGNORE

# 不因该在_input中处理
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#var mb := event as InputEventMouseButton
		#if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#accept_event() 
	#if not (event is InputEventMouseButton):
		#return
	#var mb := event as InputEventMouseButton
	#if mb.button_index != MOUSE_BUTTON_LEFT or not mb.pressed:
		#return
	#var rest_btn := $UI/HBoxContainer/rest
	#var forge_btn := $UI/HBoxContainer/forging
	#var global_pos: Vector2 = event.global_position
#
	#if rest_btn.get_global_rect().has_point(global_pos):
		#_on_rest_pressed()
		#accept_event()
	#elif forge_btn.get_global_rect().has_point(global_pos):
		#_on_forging_pressed()
		#accept_event()

func initialize() -> void:
	forgeable_cards = char_stats.deck.cards.filter(func(card: Card): return card.can_be_upgraded())
	if forgeable_cards.is_empty():
		forging.disabled = true

func _on_rest_pressed() -> void:
	print("休息")
	char_stats.heal(ceil(char_stats.max_health * 0.3))
	animation_player.play("fade_out")
	rest.disabled = true
	forging.disabled = true

func _on_fade_out_finished() -> void:
	Events.campfire_exited.emit()

func _on_forging_pressed() -> void:
	print("锻造")
	var cards: Array[Card] = await deck_view.select_card_pile(forgeable_cards, 1, 1, "选择一张牌升级", DeckView.SelectionMode.UPGRADE)
	if !cards.is_empty():
		cards[0].upgrade()
		animation_player.play("fade_out")
		rest.disabled = true
		forging.disabled = true
	


func _on_rest_mouse_entered() -> void:
	var tween := create_tween()
	tween.tween_property(rest, "scale", Vector2(1.1, 1.1), 0.15)
	


func _on_rest_mouse_exited() -> void:
	var tween := create_tween()
	tween.tween_property(rest, "scale", Vector2(1.0, 1.0), 0.15)


func _on_forging_mouse_entered() -> void:
	var tween := create_tween()
	tween.tween_property(forging, "scale", Vector2(1.1, 1.1), 0.15)
	pass # Replace with function body.


func _on_forging_mouse_exited() -> void:
	var tween := create_tween()
	tween.tween_property(forging, "scale", Vector2(1.0, 1.0), 0.15)
