extends HBoxContainer

@onready var tooltip_container_1: VBoxContainer =$VBoxContainer
@onready var tooltip_container_2: VBoxContainer = $VBoxContainer2
@onready var tooltip_timer: Timer = $TooltipTimer

const TOOLTIP_ENTRY = preload("res://globals/tooltip_entry.tscn")

var current_node: Node

func _ready() -> void:
	Events.tooltip_show_request.connect(_on_tooltip_show_requested)
	Events.tooltip_hide_request.connect(_on_tooltip_hide_requested)
	tooltip_timer.timeout.connect(_on_timer_timeout)

func clear():
	for child in tooltip_container_1.get_children():
		child.queue_free()
	for child in tooltip_container_2.get_children():
		child.queue_free()

func add_keyword(title, desc) -> void:
	var tooltip_entry := TOOLTIP_ENTRY.instantiate()
	tooltip_entry.setup(title, desc)
	# 如果状态装不下了之后再说
	if tooltip_container_1.get_child_count() < 4:
		tooltip_container_1.add_child(tooltip_entry)
	else:
		tooltip_container_2.add_child(tooltip_entry)

func extract_keyword(text: String) -> Array:
	var found: Array[String] = []
	for key: String in BuffLibrary.keyword_info:
		var keyword_name = BuffLibrary.get_keyword_name(key)
		if text.contains(keyword_name):
			found.append(keyword_name)
	var unique_dict := {}
	for keyword in found:
		unique_dict[keyword] = found
	return unique_dict.keys()
	
func _on_tooltip_show_requested(node: Node) -> void:
	clear()
	tooltip_timer.start(0.2)
	current_node = node

func _on_tooltip_hide_requested() -> void:
	tooltip_timer.stop()
	hide()

func _on_timer_timeout() -> void:
	# TODO:找时间重构
	current_node.show_keyword_tooltip()
	show()
