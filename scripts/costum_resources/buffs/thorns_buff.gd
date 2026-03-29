# 记得改类名
class_name ThornsBuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["荆棘"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	
func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("after_take_damage"):
		agent.connect("after_take_damage", _on_after_take_damage)
	else:
		printerr("该对象没有after_take_damage信号")
		return

func get_modifier() -> Array[Modifier]:
	return []

func _on_after_take_damage(context: Context) -> void:
	# 不会触发 before_take_damage
	context.source.stats.take_damage(stacks)

func get_description() -> String:
	return description.format({"stacks": stacks})
