extends Control

#主菜单
#const MAIN_MENU = preload("res://scenes/main_menu/main_menu.tscn")

#背景资源


const CHARACTER_SELECT_SILENT_BG = preload("res://animations/character_select/silent/character_select_silent_bg.png")
const CHARACTER_SELECT_NECROBINDER_BG = preload("res://animations/character_select/necrobinder/character_select_necrobinder_bg.png")

#节点
@onready var background: SpineManager = $background
@onready var backforsomechar: TextureRect = $backforsomechar


#骨骼资源
const CHARACTERSELECT_IRONCLAD_SKEL_DATA = preload("res://animations/character_select/ironclad/characterselect_ironclad_skel_data.tres")
const CHARACTERSELECT_DEFECT_SKEL_DATA = preload("res://animations/character_select/defect/characterselect_defect_skel_data.tres")
const CHARACTERSELECT_NECROBINDER_SKEL_DATA = preload("res://animations/character_select/necrobinder/characterselect_necrobinder_skel_data.tres")
const CHARACTERSELECT_REGENT_SKEL_DATA = preload("res://animations/character_select/regent/characterselect_regent_skel_data.tres")
const CHARACTERSELECT_SILENT_SKEL_DATA = preload("res://animations/character_select/silent/characterselect_silent_skel_data.tres")

#角色属性资源
const IRONCLAD_STATS := preload("res://entities/characters/ironclad/ironclad_stats.tres")
const SILENT_STATS := preload("res://entities/characters/silent/silent_stats.tres")
var current_character: CharacterStats

#一局游戏的场景
const RUN_SCENE = preload("res://scenes/run/run.tscn")
#用来保存当前界面选择的角色并传给RUN场景
@export var run_startup: RunStartup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_current_charcter(IRONCLAD_STATS)
	background.skeleton_data_res=CHARACTERSELECT_IRONCLAD_SKEL_DATA 
	var temp=background.get_animation_state()
	temp.add_animation("animation",true)
	

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _set_current_charcter(new_character: CharacterStats) -> void:
	current_character = new_character
	# TODO: 设置角色描述（current_character.description

func _on_start_pressed() -> void:
	print("start with {0}".format([current_character.character_name]))
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = current_character
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_ironclad_pressed() -> void:
	current_character = IRONCLAD_STATS
	background.skeleton_data_res=CHARACTERSELECT_IRONCLAD_SKEL_DATA 
	var temp=background.get_animation_state()
	temp.add_animation("animation",true)


func _on_silent_pressed() -> void:
	current_character = SILENT_STATS
	backforsomechar.texture=CHARACTER_SELECT_SILENT_BG
	background.skeleton_data_res=CHARACTERSELECT_SILENT_SKEL_DATA
	var temp=background.get_animation_state()
	temp.add_animation("animation",true)

func _on_regent_pressed() -> void:
	background.skeleton_data_res=CHARACTERSELECT_REGENT_SKEL_DATA
	var temp=background.get_animation_state()
	temp.add_animation("animation",true)


func _on_necrobinder_pressed() -> void:
	backforsomechar.texture=CHARACTER_SELECT_NECROBINDER_BG
	background.skeleton_data_res=CHARACTERSELECT_NECROBINDER_SKEL_DATA
	var temp=background.get_animation_state()
	temp.add_animation("animation",true)



func _on_defect_pressed() -> void:
	background.skeleton_data_res=CHARACTERSELECT_DEFECT_SKEL_DATA
	var temp=background.get_animation_state()
	temp.add_animation("animation",true)


func _on_button_pressed() -> void:
	var log=get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	print(log)
