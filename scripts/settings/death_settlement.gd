class_name DeathSettlement
extends CanvasLayer

signal DeathSettlementBackToMainMenu

@onready var floor_climed: Label = $VBoxContainer/VBoxContainer/HBoxContainer/floor_climed
@onready var monster_killed: Label = $VBoxContainer/VBoxContainer/HBoxContainer2/monster_killed
@onready var gold_obtained: Label = $VBoxContainer/VBoxContainer/HBoxContainer3/gold_obtained

@onready var dicovered_card: Label = $VBoxContainer/HBoxContainer/dicovered_card
@onready var dicovered_relic: Label = $VBoxContainer/HBoxContainer/dicovered_relic
@onready var discovered_potion: Label = $VBoxContainer/HBoxContainer/discovered_potion

@onready var texture_button: TextureButton = $TextureButton
@onready var label: Label = $TextureButton/Label

#从run中获取的资源
@export var char_stats:CharacterStats
@export var run_stats:RunStats

# 原始字体大小和颜色，以及文本
@export var original_font_size: int = 50
@export var original_font_color: Color = Color(1,0.96,0.88)
@export var text:String
#悬停时的字体大小和颜色
@export var hover_font_size: int = 60
@export var hover_font_color: Color = Color(1.0, 0.9, 0.3)  # 金色
#动画时长
@export var animation_duration: float = 0.2


func init(mobkilled:int)->void:
	if char_stats!=null:
		
		var i:int=char_stats.deck.cards.size()
		dicovered_card.text+=str(i)
		
	if run_stats!=null:
		#攀爬楼层
		var i :int= run_stats.floors_climbed
		floor_climed.text+=str(i)
		#击杀精英
		i=mobkilled
		monster_killed.text+=str(i)
		#获得的金币
		i=run_stats.gold
		gold_obtained.text+=str(i)
		
		#发现的遗物
		i=run_stats.relic_count()
		dicovered_relic.text+=str(i)
		
		#发现的药水
		i=run_stats.potion_count()
		discovered_potion.text+=str(i)
	
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
		
	
	texture_button.mouse_entered.connect(_on_button_hover)
	texture_button.mouse_exited.connect(_on_button_hover)
	


func _on_button_hover():
	# 判断当前是进入还是离开
	var mouse_inside = texture_button.is_hovered()
	if mouse_inside:
		_animate_label(true)	
	else:
		_animate_label(false)



func _animate_label(is_hover: bool):
	var tween = create_tween().set_parallel(true)
	
	if is_hover:
		# 悬停时：放大字体 + 变色
		tween.tween_method(_update_label_font_size, original_font_size, hover_font_size, animation_duration)
		tween.tween_property(label, "modulate", hover_font_color, animation_duration)
	else:
		# 离开时：恢复
		tween.tween_method(_update_label_font_size, 
						  hover_font_size, original_font_size, 
						  animation_duration)
		tween.tween_property(label, "modulate", original_font_color, animation_duration)

# 更新字体大小的辅助函数
func _update_label_font_size(size: float):
	label.add_theme_font_size_override("font_size", int(size))
	
# 更新字体颜色的辅助函数
func _update_label_font_color(color: Color):
	label.add_theme_color_override("font_color", color)

func _on_texture_button_pressed() -> void:
	DeathSettlementBackToMainMenu.emit()
	
