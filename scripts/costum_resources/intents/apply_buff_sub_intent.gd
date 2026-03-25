class_name ApplyBuffSubIntent
extends SubIntent

@export var buff_id: String
@export var buff_all_allay: bool

func execute(source: Creature, targets: Array[Node]) -> void:
	if buff_all_allay:
		targets = source.get_tree().get_nodes_in_group("ui_enemies")
	else:
		targets = [source]
	var apply_buff_effect := ApplyBuffEffect.new()
	apply_buff_effect.execute(ApplyBuffContext.new(source, targets, base_value, BuffLibrary.buff_scene[buff_id].new()))

func get_text() -> String:
	return ""

func get_intent_name() -> String:
	return "[color=gold]强化[/color]"

func get_intent_description() -> String:
	return "这个敌人将要使用一个[color=gold]强化效果[/color]"
