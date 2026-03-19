class_name VunlerableDebuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	buff_name = "易伤"
	description = "受到的攻击伤害增加50%"

func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("before_take_damage"):
		agent.connect("before_take_damage", _on_before_take_damage)
	else:
		printerr("该对象没有before_take_damage信号")
		return
	if agent and agent.has_signal("turn_started"):
		agent.connect("turn_started", _on_turn_started)

func _on_before_take_damage(context: Context) -> void:
	context.amount = int(context.amount * 1.5)

func _on_turn_started(_creature: Node2D) -> void:
	remove_stack(1) 
