class_name PoisonDebuff
extends Buff



func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	buff_name = "中毒"
	# TODO:动态修改
	description = "回合开始时受到x点伤害"

func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("turn_started"):
		agent.connect("turn_started", _on_turn_started)
	else:
		printerr("该对象没有turn_started信号")

func _on_turn_started(target: Node) -> void:
	target.lose_health(LoseHealthContext.new(self, [target], stacks))
	remove_stack(1)
