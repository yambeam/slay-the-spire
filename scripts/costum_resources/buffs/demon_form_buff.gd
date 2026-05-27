# 记得改类名
class_name DemonFormBuff
extends Buff

	
func initialize() -> void:
	if agent and agent.has_signal("before_turn_started"):
		var player: Player = agent.get_tree().get_first_node_in_group("ui_player")
		player.after_turn_started.connect(_on_before_turn_started)
		#agent.connect("before_turn_started", _on_before_turn_started)

func get_description() -> String:
	return description.format({"stacks": stacks})

func _on_before_turn_started(_creature: Node2D) -> void:
	agent.apply_buff(ApplyBuffContext.new(agent, agent, stacks, "力量"))
