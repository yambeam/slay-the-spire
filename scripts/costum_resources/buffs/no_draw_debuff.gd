# 记得改类名
class_name NoDrawDebuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["无法抽牌"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	stackable = false
	
func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("before_draw_cards"):
		agent.connect("before_draw_cards", _on_before_draw_cards)
	else:
		printerr("该对象没有before_draw_cards信号")
		return
	if agent and agent.has_signal("turn_ended"):
		agent.connect("turn_ended", _on_turn_ended)

func _on_before_draw_cards(context: Context) -> void:
	context.amount = 0

func _on_turn_ended(_creature: Node2D) -> void:
	remove_stack(1) 
