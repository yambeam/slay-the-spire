class_name EnemyAI
extends Resource

# 所有可能的意图
@export var intents: Array[Intent]

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	for sub_intent: SubIntent in current_intent.sub_intents:
		sub_intent.execute(source, [target])

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	return random_intent(intents)

func random_intent(intents_: Array[Intent]) -> Intent:
	return intents_[randi() % intents_.size()]

func get_die_animation_name() -> String:
	return "die"

func get_idle_animation_name() -> String:
	return "idle_loop"

func get_hurt_animation_name() -> String:
	return "hurt" 
