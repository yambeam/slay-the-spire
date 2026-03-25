class_name CardMenuUI
extends CenterContainer

signal inspect_card_requested(card: Card)

@onready var visuals: CardVisuals = $CardMenuUI/Visuals


var tween: Tween

@export var card: Card: set = _set_card

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") or event.is_action_pressed("right_mouse"):
		inspect_card_requested.emit(card)

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	visuals.card = value

func _on_mouse_entered() -> void:
	if tween: 
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	Events.tooltip_show_request.emit(self)
	
func show_keyword_tooltip() -> void:
	var keywords = KeywordTooltip.extract_keyword(card.description)
	if keywords.is_empty():
		return
	for keyword:String in keywords:
		var keyword_name: String = BuffLibrary.get_keyword_name(keyword)
		var desc: String = BuffLibrary.get_keyword_description(keyword)
		KeywordTooltip.add_keyword(keyword_name, desc)
	# preview时会scale到1.3，同时向上移动175px(显示tooltip需要0.2s,此时tween已经完成)
	KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 1.4, 0)
	KeywordTooltip.show()

func _on_mouse_exited() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	Events.tooltip_hide_request.emit()
