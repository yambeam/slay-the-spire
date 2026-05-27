extends CanvasLayer

@onready var tooltip_container_1: VBoxContainer = %VBoxContainer
@onready var tooltip_container_2: VBoxContainer = %VBoxContainer2
@onready var tooltip_timer: Timer = %TooltipTimer
@onready var keyword_tooltip: HBoxContainer = %KeywordTooltip
@onready var throttle_timer: Timer = %ThrottleTimer

const TOOLTIP_ENTRY = preload("res://globals/tooltip_entry.tscn")

var entry_dict: Dictionary = {
	
}
var current_node: Node
var callback: Callable

var viewport_size: Vector2

func _ready() -> void:
	Events.tooltip_show_request.connect(_on_tooltip_show_requested)
	Events.tooltip_hide_request.connect(_on_tooltip_hide_requested)
	Events.combat_won.connect(func(_context: RewardContext): hide())
	tooltip_timer.timeout.connect(_on_timer_timeout)
	throttle_timer.timeout.connect(_on_throttle_timer_timeout)

func clear():
	for child in tooltip_container_1.get_children():
		child.queue_free()
	for child in tooltip_container_2.get_children():
		child.queue_free()
	entry_dict = {}
	
func add_keyword(title, desc) -> void:
	title = "[color=gold]" + title + "[/color]"
	entry_dict[title] = desc

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
	
func _on_tooltip_show_requested(node: Node, callback_: Callable) -> void:
	clear()
	tooltip_timer.start(0.2)
	current_node = node
	callback = callback_

func _on_tooltip_hide_requested() -> void:
	tooltip_timer.stop()
	hide()
	throttle_timer.stop()

func _on_timer_timeout() -> void:
	# TODO:找时间重构
	if current_node and callback:
		callback.call()
		var count = len(entry_dict)
		for title in entry_dict:
			var tooltip_entry: ToolTipEntry = TOOLTIP_ENTRY.instantiate()
			if tooltip_container_1.get_child_count() < ceil(count / 2.0):
				tooltip_container_1.add_child(tooltip_entry)
			else:
				tooltip_container_2.add_child(tooltip_entry)
			tooltip_entry.setup(title, entry_dict[title])
		await get_tree().process_frame
		show()
		throttle_timer.start()

func _on_throttle_timer_timeout():
	if !is_instance_valid(current_node):
		_on_tooltip_hide_requested()
