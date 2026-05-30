class_name CharacterSelector
extends Control
signal back_to_main


#背景资源
const CHARACTER_SELECT_SILENT_BG = preload("res://animations/character_select/silent/character_select_silent_bg.png")
const CHARACTER_SELECT_NECROBINDER_BG = preload("res://animations/character_select/necrobinder/character_select_necrobinder_bg.png")

#节点
@onready var backforsomechar: TextureRect = $backforsomechar
@onready var bg_spine: SpineSprite = $background
@onready var character_description: CharacterDescription = $CharacterDescription

#骨骼资源
const IRONCLAD = preload("res://animations/character_select/ironclad/characterselect_ironclad_skel_data.tres")
const DEFECT = preload("res://animations/character_select/defect/characterselect_defect_skel_data.tres")
const NECRO = preload("res://animations/character_select/necrobinder/characterselect_necrobinder_skel_data.tres")
const REGENT = preload("res://animations/character_select/regent/characterselect_regent_skel_data.tres")
const SILENT = preload("res://animations/character_select/silent/characterselect_silent_skel_data.tres")
var all_chars := []

#角色属性资源
const IRONCLAD_STATS := preload("res://entities/characters/ironclad/ironclad_stats.tres")
const SILENT_STATS := preload("res://entities/characters/silent/silent_stats.tres")
var current_character: CharacterStats

#一局游戏的场景
const RUN_SCENE = preload("res://scenes/run/run.tscn")
#用来保存当前界面选择的角色并传给RUN场景
@export var run_startup: RunStartup



# 初始化 
func _ready():
	_set_current_charcter(IRONCLAD_STATS)
	# 收集所有角色
	all_chars = [IRONCLAD, DEFECT, NECRO, REGENT, SILENT]
	# 预热所有 Spine 骨架
	prewarm_all_spines()
	switch_character(IRONCLAD)

# ===== 预热（核心）=====
func prewarm_all_spines():
	for data in all_chars:
		# 创建一个“隐藏的 SpineSprite”
		var dummy := SpineSprite.new()
		dummy.visible = false
		dummy.skeleton_data_res = data
		add_child(dummy)
		# 强制推进一帧，让 Spine 完成解析 & GPU 上传
		dummy.get_animation_state().update(0.001)
		# 用完立刻移除
		dummy.queue_free()

# ===== 切换（不再卡顿）=====
func switch_character(data: Resource):
	if not bg_spine:
		return

	bg_spine.skeleton_data_res = data
	var state = bg_spine.get_animation_state()
	state.set_animation("animation",true)


func _set_current_charcter(new_character: CharacterStats) -> void:
	current_character = new_character
	# TODO: 设置角色描述（current_character.description

func _on_start_pressed() -> void:
	print("start with {0}".format([current_character.character_name]))
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = current_character.create_instance()
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_ironclad_pressed() -> void:
	if bg_spine.skeleton_data_res == IRONCLAD:
		return
	character_description.set_description("IRONCLAD")
	current_character = IRONCLAD_STATS
	switch_character(IRONCLAD)
	#background.skeleton_data_res=CHARACTERSELECT_IRONCLAD_SKEL_DATA 
	#var temp=background.get_animation_state()
	#temp.add_animation("animation",true)


func _on_silent_pressed() -> void:
	if bg_spine.skeleton_data_res == SILENT:
		return
	
	character_description.set_description("SILENT")
		
	current_character = SILENT_STATS
	backforsomechar.texture=CHARACTER_SELECT_SILENT_BG
	switch_character(SILENT)
	#background.skeleton_data_res=CHARACTERSELECT_SILENT_SKEL_DATA
	#var temp=background.get_animation_state()
	#temp.add_animation("animation",true)

func _on_regent_pressed() -> void:
	if bg_spine.skeleton_data_res == REGENT:
		return
	switch_character(REGENT)
	
	#background.skeleton_data_res=CHARACTERSELECT_REGENT_SKEL_DATA
	#var temp=background.get_animation_state()
	#temp.add_animation("animation",true)


func _on_necrobinder_pressed() -> void:
	if bg_spine.skeleton_data_res == NECRO:
		return
	backforsomechar.texture=CHARACTER_SELECT_NECROBINDER_BG
	switch_character(NECRO)
	#background.skeleton_data_res=CHARACTERSELECT_NECROBINDER_SKEL_DATA
	#var temp=background.get_animation_state()
	#temp.add_animation("animation",true)



func _on_defect_pressed() -> void:
	if bg_spine.skeleton_data_res == DEFECT:
		return
	switch_character(DEFECT)

	#background.skeleton_data_res=CHARACTERSELECT_DEFECT_SKEL_DATA
	#var temp=background.get_animation_state()
	#temp.add_animation("animation",true)




func _on_button_pressed() -> void:
	current_character = IRONCLAD_STATS
	switch_character(IRONCLAD)
	back_to_main.emit()
	
	
	
	
	
	
	
	
