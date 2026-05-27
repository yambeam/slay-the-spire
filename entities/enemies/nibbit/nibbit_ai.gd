extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			if (source as Enemy).encounter_index == 0:
				return get_intent_by_name("Butt")
			else:
				return get_intent_by_name("Hiss")
		"Hiss":
			return get_intent_by_name("Butt")
		"Butt":
			return get_intent_by_name("Slice")
		"Slice":
			return get_intent_by_name("Hiss")
		_:
			return random_intent(intents)
