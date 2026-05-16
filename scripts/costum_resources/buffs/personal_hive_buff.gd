class_name  PersionalHiveBuff
extends Buff

var used_times = 0
var card: Card = ResourceLoader.load("res://entities/cards/status_cards/眩晕.tres")

func initialize() -> void:
	agent.before_take_damage.connect(_on_before_take_damage)
	agent.turn_ended.connect(_on_turn_ended)

func get_modifier() -> Array[Modifier]:
	return []

func _on_before_take_damage(context: Context) -> void:
	if used_times < 3 and context.source is Player:
		for i in range(stacks):
			(context.source as Player).put_card_in_draw_pile(card.duplicate())
		used_times += 1
		
func _on_turn_ended(_creature: Creature) -> void:
	used_times = 0

func get_description() -> String:
	return description.format({"stacks": stacks})
