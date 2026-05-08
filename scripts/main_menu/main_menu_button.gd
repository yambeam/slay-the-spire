class_name MainMenuButton
extends HBoxContainer

signal main_menu_button_pressed

@onready var leftwing: TextureRect = $leftwing
@onready var button: Button = %button
@onready var rightwing: TextureRect = $rightwing


#属性
@export var normal_font_size: int = 40
@export var hover_font_size: int = 50
@export var text:String="Continue"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	button.add_theme_font_size_override("font_size", normal_font_size)
	button.text=text
	# 连接信号
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
	

func _on_button_mouse_entered(button: Button):
	# 使用tween实现平滑过渡
	var tween = create_tween()
	tween.set_parallel(true)  # 并行执行
	# 字体大小动画
	tween.tween_method(
		func(value: float): 
			button.add_theme_font_size_override("font_size", int(value)),
		normal_font_size,
		hover_font_size,
		0.2
	)
	# 翅膀淡入
	tween.tween_property(leftwing, "modulate:a", 1.0, 0.2)
	tween.tween_property(rightwing, "modulate:a", 1.0, 0.2)
	
	
	
func _on_button_mouse_exited(button: Button):
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_method(
		func(value: float): 
			button.add_theme_font_size_override("font_size", int(value)),
		hover_font_size,
		normal_font_size,
		0.2
	)
	# 翅膀淡出
	tween.tween_property(leftwing, "modulate:a", 0, 0.2)
	tween.tween_property(rightwing, "modulate:a", 0, 0.2)
	


func _on_button_pressed() -> void:
	main_menu_button_pressed.emit()
	
