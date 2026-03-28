# 记得改类名
class_name DexterityBuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["敏捷"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	
func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("before_gain_block"):
		agent.connect("before_gain_block", _on_before_gain_block)
	else:
		printerr("该对象没有before_gain_block信号")
	
func get_description() -> String:
	return description.format({"stacks": stacks})
		
func get_modifier() -> Array[Modifier]:
	var modifier := Modifier.new(Enums.NumericType.BLOCK, stacks, 1.0, null)
	return [modifier]
	
func remove_stack(amount: int):
	stacks -= amount
	if stacks == 0:
		queue_free()
	stack_changed.emit()
	
func _on_before_gain_block(context: Context) -> void:
	context.modifiers.append(Modifier.new(Enums.NumericType.BLOCK, stacks, 1.0, null))
