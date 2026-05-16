extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			source = source as Enemy
			if source.encounter_index == 0:
				return get_intent_by_name("Bite")
			else:
				return get_intent_by_name("Suck")
		"Bite":
			return get_intent_by_name("Suck")
		"Suck":
			return get_intent_by_name("Bite")
	return intents.pick_random()
		
