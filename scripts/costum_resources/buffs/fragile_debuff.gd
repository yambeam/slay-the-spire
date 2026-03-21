# 记得改类名
class_name FragileDebuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["脆弱"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	
func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("before_gain_block"):
		agent.connect("before_gain_block", _on_before_gain_block)
	else:
		printerr("该对象没有before_gain_block信号")
		return
	if agent and agent.has_signal("turn_started"):
		agent.connect("turn_started", _on_turn_started)

func get_modifier() -> Array[Modifier]:
	var modifier := Modifier.new(Enums.NumericType.BLOCK, 0, 0.75, null)
	return [modifier]

func _on_before_gain_block(context: Context) -> void:
	context.amount = int(context.amount * 0.75)

func _on_turn_started(_creature: Node2D) -> void:
	remove_stack(1) 
