extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			match (source as Enemy).encounter_index:
				0:
					return get_intent_by_name("Skitter")
				1:
					return get_intent_by_name("Mandible")
				2:
					return get_intent_by_name("Enrage")
				3:
					return random_intent([get_intent_by_name("Skitter"), get_intent_by_name("Mandible")])
				_:
					return random_intent(intents)
		"Skitter":
			return get_intent_by_name("Mandible")
		"Mandible":
			return get_intent_by_name("Enrage")
		"Enrage":
			return random_intent([get_intent_by_name("Skitter"), get_intent_by_name("Mandible")])
		_:
			return random_intent(intents)
