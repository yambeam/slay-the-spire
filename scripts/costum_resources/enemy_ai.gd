class_name EnemyAI
extends Resource

# 所有可能的意图
@export var intents: Array[Intent]

func set_up_intents(source: Creature, target: Creature) -> void:
	for intent: Intent in intents:
		intent.set_source(source)	
		intent.set_target(target)

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	for sub_intent: SubIntent in current_intent.sub_intents:
		await sub_intent.execute()

func choose_intent(source: Creature, target: Creature) -> Intent:
	var intent: Intent = random_intent(intents)
	return intent

func random_intent(intents_: Array[Intent]) -> Intent:
	return intents_[randi() % intents_.size()]

#func get_intent_by_name(intents_: Array[Intent], intent_name: String) -> Intent:
	#for intent: Intent in intents_:
		#if intent.intent_name == intent_name:
			#return intent
	#return null

func get_intent_by_name(intent_name: String) -> Intent:
	for intent: Intent in intents:
		if intent.intent_name == intent_name:
			return intent
	return null
	

func get_die_animation_name() -> String:
	return "die"

func get_idle_animation_name() -> String:
	return "idle_loop"

func get_hurt_animation_name() -> String:
	return "hurt" 

func get_skin(_spine_sprite: SpineManager) -> SpineSkin:
	return null;
