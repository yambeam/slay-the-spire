extends Node


#鼠标的光标
var normal_cursor = preload("res://images/packed/common_ui/cursor_default.png")
var click_cursor  = preload("res://images/packed/common_ui/cursor_tilted.png")


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# 鼠标按下
			Input.set_custom_mouse_cursor(click_cursor)
		else:
			# 鼠标松开
			Input.set_custom_mouse_cursor(normal_cursor)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(normal_cursor)
	pass # Replace with function body.
