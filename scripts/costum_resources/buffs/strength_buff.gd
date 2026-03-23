# 记得改类名
class_name StrengthBuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["力量"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	
func _ready() -> void:
	type = Type.DEBUFF
	affect = AFFECT.SELF
	if agent and agent.has_signal("before_attack"):
		agent.connect("before_attack", _on_before_attack)
	else:
		printerr("该对象没有before_attack信号")
		return
		
func get_modifier() -> Array[Modifier]:
	var modifier := Modifier.new(Enums.NumericType.DAMAGE, stacks, 1.0, null)
	return [modifier]

func get_description() -> String:
	return description.format({"stacks": stacks})

func remove_stack(amount: int):
	stacks -= amount
	if stacks == 0:
		queue_free()
	stack_changed.emit()

func _on_before_attack(context: Context) -> void:
	context.amount += stacks
