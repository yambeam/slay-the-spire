class_name VitalSparkBuff
extends Buff

var used = false

func initialize() -> void:
	agent.after_take_damage.connect(_on_after_take_damage)
	agent.turn_ended.connect(_on_turn_ended)

func get_modifier() -> Array[Modifier]:
	return []

func _on_after_take_damage(context: Context) -> void:
	# 不会触发 before_take_damage
	if not used and context.source is Player:
		(context.source as Player).stats.energy += stacks
		used = true
		
func _on_turn_ended(_creature: Creature) -> void:
	used = false

func get_description() -> String:
	return description.format({"stacks": stacks})
