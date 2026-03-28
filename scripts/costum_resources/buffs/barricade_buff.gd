# 记得改类名
class_name BarricadeBuff
extends Buff

var block: int

func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["壁垒"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	stackable = false
	
func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("before_turn_started"):
		agent.connect("before_turn_started", _on_before_turn_started)
	if agent and agent.has_signal("after_turn_started"):
		agent.connect("after_turn_started", _on_after_turn_started)

func get_modifier() -> Array[Modifier]:
	var modifier := Modifier.new(Enums.NumericType.DAMAGE, 0, 1.5, null)
	return [modifier]

func _on_before_turn_started(creature: Creature) -> void:
	block = creature.stats.block
	 
func _on_after_turn_started(creature: Creature) -> void:
	creature.stats.block = block

func _on_turn_started(_creature: Node2D) -> void:
	remove_stack(1) 
