# 记得改类名
class_name WeaknessDebuff
extends Buff



func _init() -> void:
	var buff_info: Dictionary = BuffLibrary.buff_data["虚弱"]
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
	if agent and agent.has_signal("turn_ended"):
		agent.connect("turn_ended", _on_turn_ended)

func get_modifier() -> Array[Modifier]:
	var modifier := Modifier.new(Enums.NumericType.DAMAGE, 0, 0.75, null)
	return [modifier]

func _on_before_attack(context: Context) -> void:
	context.amount = int(context.amount * 0.75)

func _on_turn_ended(_creature: Node2D) -> void:
	# remove_stack是继承自buff,层数小于0是调用queue_free()
	remove_stack(1) 
