extends Node

const TOOL_TIP = preload("res://scenes/ui/tool_tip.tscn")
var current_tooltip: ToolTip = null

func show_tooltip(text: String, position: Vector2 = get_viewport().get_mouse_position()) -> void:
	if current_tooltip:
		current_tooltip.queue_free()
	current_tooltip = TOOL_TIP.instantiate()
	get_tree().current_scene.add_child(current_tooltip)
	current_tooltip.set_text(text)
	current_tooltip.global_position = position + Vector2(20, 20)

func hide_tooltip():
	if current_tooltip:
		current_tooltip.queue_free()
		current_tooltip = null
	
	
