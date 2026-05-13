class_name MainMenu
extends Control


#场景
const RUN_SCENE=preload("res://scenes/run/run.tscn")

@export var run_startup:RunStartup

#变量名：变量类型
#$...获取子节点
@onready var logo: SpineManager = %logo
@onready var top: SpineManager = $top

#设置界面
@onready var settingscene: Settings = $settingscene
#角色选择界面
@onready var character_selector: CharacterSelector = $character_selector

#四个按钮
@onready var continue_button: MainMenuButton = $VBoxContainer/ContinueButton
@onready var new_run: MainMenuButton = $"VBoxContainer/New Run"
@onready var settings: MainMenuButton = $VBoxContainer/Settings
@onready var quit: MainMenuButton = $VBoxContainer/Quit



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#四个按钮的按下的信号链接
	continue_button.main_menu_button_pressed.connect(_on_continue_pressed)
	new_run.main_menu_button_pressed.connect(_on_new_run_pressed)
	settings.main_menu_button_pressed.connect(_on_settings_pressed)
	quit.main_menu_button_pressed.connect(_on_quit_pressed)
	#设置界面的信号链接
	settingscene.settings_exited.connect(handleSettings)
	#角色选择界面的信号链接
	character_selector.back_to_main.connect(handleCharacterSelector)
	
	#如果没有保存的游戏数据，把continue按钮禁用
	if SaveGame.load_data()==null:
		continue_button.button.disabled=true
	#设置背景动画
	var temp=logo.get_animation_state()
	temp.set_animation('animation',true)
	temp=top.get_animation_state()
	temp.set_animation('animation',true)
	get_tree().paused=false
	
	
func handleCharacterSelector()->void:
	character_selector.hide()
	

func handleSettings()->void:
	settingscene.hide()
	get_tree().paused=false


func _on_continue_pressed() -> void:
	run_startup.type=RunStartup.Type.CONTINUE_RUN
	get_tree().change_scene_to_packed(RUN_SCENE)
	print("coutinue button pressed")

func _on_new_run_pressed() -> void:
	character_selector.show()
	
func _on_settings_pressed() -> void:
	settingscene.show()
	get_tree().paused=true
	
func _on_quit_pressed() -> void:
	
	get_tree().quit()
