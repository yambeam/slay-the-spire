extends EnemyAI

var last_action = ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name	
	super.execute_intent(source, target, current_intent)

func choose_intent(source: Creature, _target: Creature) -> Intent:
	source = source as Enemy
	match last_action:
		"":
			if source.encounter_index == 0:
				return get_intent_by_name("Clamp")
			else:
				return get_intent_by_name("Screech")
		"Clamp":
			return get_intent_by_name("Screech")
		"Screech":
			return get_intent_by_name("Clamp")
		_:
			return random_intent(intents)
		
