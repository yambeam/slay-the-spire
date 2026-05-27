class_name CharacterDescription
extends Control






@onready var char_name: Label = $PanelContainer/HBoxContainer/VBoxContainer/char_name
@onready var hp: Label = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer/HP
@onready var gold: Label = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer/gold

@onready var description: Label = $PanelContainer/HBoxContainer/VBoxContainer/description
@onready var relic: TextureRect = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/relic
@onready var relic_name: Label = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/relicName

@onready var desc_of_relic_1: Label = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/desc_of_relic1
@onready var desc_of_relic_2: Label = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/desc_of_relic2
@onready var desc_of_relic_3: Label = $PanelContainer/HBoxContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/desc_of_relic3

#default
@export var nameofchar:String="铁甲战士"
@export var health:int=70
@export var initgold:int=75
@export var describ:String="铁甲军团最后的士兵。
并非出自自身的意愿，用刀剑与烈焰击溃敌人们。"
@export var relicResource:String="res://images/atlases/relic_atlas.sprites/burning_blood.tres"

@export var relicName:String="燃烧之血"


@export var des1:String="在战斗结束时，回复"
@export var des2:String="6"
@export var des2color:Color=Color.html("#7bee00")
@export var des3:String="点生命"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()

func init()->void:
	char_name.text=nameofchar
	hp.text=str(health)
	gold.text=str(initgold)
	description.text=describ
	relic.texture=load(relicResource)
	relic_name.text=relicName
	desc_of_relic_1.text=des1
	desc_of_relic_2.text=des2
	desc_of_relic_2.add_theme_color_override("font_color", des2color)
	desc_of_relic_3.text=des3

func set_description(name:String)->void:
	if name=="IRONCLAD":
		init()
	elif name=="SILENT":
		char_name.text="静默猎手"
		hp.text=str(66)
		gold.text=str(75)
		description.text="一位来自尖塔之外的女猎手。\n随时准备刀刺与毒杀任何拦路者"
		relic.texture=load("res://images/atlases/relic_atlas.sprites/ring_of_the_snake.tres")
		relic_name.text="蛇之戒指"
		desc_of_relic_1.text="在每场战斗开始时，额外抽"
		desc_of_relic_2.text="2"
		desc_of_relic_2.add_theme_color_override("font_color", Color.html("#77b6cf"))
		desc_of_relic_3.text="张牌"
	
	
