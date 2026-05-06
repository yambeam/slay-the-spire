extends Control


#角色选择场景
#const CHARACTER_SELECTOR = preload("res://scenes/character_selector/character_selector.tscn")

const RUN_SCENE=preload("res://scenes/run/run.tscn")

@export var run_startup:RunStartup

#变量名：变量类型
#$...获取子节点
@onready var logo: SpineManager = %logo
@onready var top: SpineManager = $top

#设置界面

@onready var settingscene: Settings = $settingscene

#四个按钮
@onready var continue_button: Button = %Continue
@onready var new_run_button: Button = $"VBoxContainer/New Run"
@onready var settings_button: Button = $VBoxContainer/Settings
@onready var quit_button: Button = $VBoxContainer/Quit

@onready var buttons: Array[Button]  # 存储所有按钮

var normal_font_size: int = 40
var hover_font_size: int = 50
var normal_font_color: Color = Color.WHITE
var hover_font_color: Color = Color.YELLOW  # 悬停时颜色



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	 # 将所有按钮存入数组
	buttons = [continue_button, new_run_button, settings_button, quit_button]
	
	# 为每个按钮连接信号
	for button in buttons:
		
		# 设置初始字体大小
		button.add_theme_font_size_override("font_size", normal_font_size)
		
		# 连接信号
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
		button.mouse_exited.connect(_on_button_mouse_exited.bind(button))
		
	
	
	var temp=logo.get_animation_state()
	temp.set_animation('animation',true)
	temp=top.get_animation_state()
	temp.set_animation('animation',true)
	get_tree().paused=false
	continue_button.disabled=SaveGame.load_data()==null
	settingscene.settings_exited.connect(handleSettings)

func handleSettings()->void:
	settingscene.hide()
	get_tree().paused=false

func _on_continue_pressed() -> void:
	run_startup.type=RunStartup.Type.CONTINUE_RUN
	get_tree().change_scene_to_packed(RUN_SCENE)
	print("coutinue button pressed")

func _on_new_run_pressed() -> void:
	print("new run button pressed")
	var log=get_tree().change_scene_to_file("res://scenes/character_selector/character_selector.tscn")
	print(log)
	

func _on_settings_pressed() -> void:
	settingscene.show()
	get_tree().paused=true
func _on_quit_pressed() -> void:
	print("quit button pressed")
	get_tree().quit()


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
		0.05
	)
	
	# 字体颜色动画
	tween.tween_method(
		func(value: Color): 
			button.add_theme_color_override("font_color", value),
		normal_font_color,
		hover_font_color,
		0.05
	)
	
	# 按钮缩放动画（可选）
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.2)

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
	
	tween.tween_method(
		func(value: Color): 
			button.add_theme_color_override("font_color", value),
		hover_font_color,
		normal_font_color,
		0.2
	)
	
	tween.tween_property(button, "scale", Vector2.ONE, 0.2)
