# 记得改类名
class_name DemonFormBuff
extends Buff

# 后面可能会重构
var buff_sound := preload("res://audio/SFX/dark_orb_channel.mp3")

func _init() -> void:
	# 一定要在init中设置buff名
	# 在buff进树之前会判断buff_name
	var buff_info: Dictionary = BuffLibrary.buff_data["恶魔形态"]
	buff_name = buff_info["name"]
	description = buff_info["description"]
	icon = buff_info["icon"]
	
func _ready() -> void:
	type = Type.DEBUFF
	if agent and agent.has_signal("before_turn_started"):
		agent.connect("before_turn_started", _on_before_turn_started)

func get_description() -> String:
	return description.format({"stacks": stacks})

func _on_before_turn_started(_creature: Node2D) -> void:
	var apply_buff_effect = ApplyBuffEffect.new()
	apply_buff_effect.sound = buff_sound
	apply_buff_effect.execute(ApplyBuffContext.new(agent, [agent], 2, StrengthBuff.new()))
