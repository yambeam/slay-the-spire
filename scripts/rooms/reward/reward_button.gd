class_name RewardButton
extends Button

@export var reward_icon: Texture : set = set_reward_icon
@export var reward_text: String : set = set_reward_text
@onready var custom_icon: TextureRect = $MarginContainer/HBoxContainer/CustomIcon
@onready var custom_text: Label =$MarginContainer/HBoxContainer/CustomText

func _ready():
	# 确保按钮可以接收鼠标事件
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# 连接信号（也可在编辑器里连接，但代码更清晰）
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	self_modulate = Color(0.7, 0.7, 0.7)

func _on_mouse_exited():
	# 离开时恢复原色
	self_modulate = Color.WHITE

func set_reward_icon(new_icon:Texture)->void:
	reward_icon = new_icon
	if not is_node_ready():
		await ready
	custom_icon.texture=reward_icon

func set_reward_text(new_text:String)->void:
	reward_text = new_text
	if not is_node_ready():
		await ready
	custom_text.text =reward_text


func _on_pressed() -> void:
	#queue_free()
	pass
	
