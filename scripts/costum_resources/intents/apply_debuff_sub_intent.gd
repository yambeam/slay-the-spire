class_name ApplyDebuffSubIntent
extends SubIntent

@export var buff_id: String

func execute(source: Creature, targets: Array[Node]) -> void:
	var apply_buff_effect = ApplyBuffEffect.new()
	apply_buff_effect.execute(ApplyBuffContext.new(source, targets, base_value, BuffLibrary.buff_scene[buff_id].new()))
	
func get_text() -> String:
	return ""

func get_intent_name() -> String:
	return "[color=gold]策略[/color]"

func get_intent_description() -> String:
	return "这个敌人将要对你施加一个[color=gold]负面效果[/color]"
