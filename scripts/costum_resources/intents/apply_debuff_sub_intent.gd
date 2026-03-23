class_name ApplyDebuffSubIntent
extends SubIntent

@export var buff_id: String

func execute(source: Creature, targets: Array[Node]) -> void:
	targets[0].add_buff(ApplyBuffContext.new(source, targets, base_value, BuffLibrary.buff_scene[buff_id].new()))

func get_text() -> String:
	return ""

func get_intent_name() -> String:
	return "强化"

func get_intent_description() -> String:
	return "这个敌人将要使用一个强化效果"
