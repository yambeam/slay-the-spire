class_name ApplyBuffSubIntent
extends SubIntent

@export var buff_id: String
@export var buff_all_allay: bool

func execute(source: Creature, targets: Array[Node]) -> void:
	if buff_all_allay:
		targets = source.get_tree().get_nodes_in_group("ui_enemies")
	else:
		targets = [source]
	for target: Creature in targets:
		target.add_buff(ApplyBuffContext.new(source, targets, base_value, BuffLibrary.buff_scene[buff_id].new()))

func get_text() -> String:
	return ""

func get_intent_name() -> String:
	return "策略"

func get_intent_description() -> String:
	return "这个敌人将要对你施加一个负面效果"
