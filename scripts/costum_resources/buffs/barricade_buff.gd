# 记得改类名
class_name BarricadeBuff
extends Buff

var block: int

func initialize() -> void:
	if agent and agent.has_signal("before_turn_started"):
		agent.connect("before_turn_started", _on_before_turn_started)
	if agent and agent.has_signal("after_turn_started"):
		agent.connect("after_turn_started", _on_after_turn_started)

func get_modifier() -> Array[Modifier]:
	return []

func _on_before_turn_started(creature: Creature) -> void:
	block = creature.stats.block
	 
func _on_after_turn_started(creature: Creature) -> void:
	creature.stats.block = block
"res://entities/cards/colorless/准备时间.tres"
