# 记得改类名
class_name SlipperyBuff
extends Buff

	
func initialize() -> void:

	if agent and agent.has_signal("before_lose_health"):
		agent.connect("before_lose_health", _on_before_take_damage)
	if agent and agent.has_signal("before_take_damage"):
		agent.connect("before_take_damage", _on_before_take_damage)

func get_modifier() -> Array[Modifier]:
	var modifier_1 := Modifier.new(Enums.NumericType.DAMAGE, 0, 1, func(_amount: int): return 1)
	var modifier_2 := Modifier.new(Enums.NumericType.LOSE_HEALTH, 0, 1, func(_amount: int): return 1)
	return [modifier_1, modifier_2]

func _on_before_take_damage(context: Context) -> void:
	context.modifiers.append_array(get_modifier())
	remove_stack(1)
