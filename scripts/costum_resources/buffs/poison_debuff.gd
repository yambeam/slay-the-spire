class_name PoisonDebuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["中毒"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	
func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("turn_started"):
		agent.connect("turn_started", _on_turn_started)
	else:
		printerr("该对象没有turn_started信号")

func _on_turn_started(target: Node) -> void:
	target.lose_health(LoseHealthContext.new(self, [target], stacks))
	remove_stack(1)

func get_description() -> String:
	return description.format({"stacks": stacks})
