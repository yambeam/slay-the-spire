extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return random_intent([get_intent_by_name("Jab"), get_intent_by_name("WhirlWind")])
		"Jab":
			return get_intent_by_name("WhirlWind")
		"WhirlWind":
			return get_intent_by_name("PiercingGaze")
		"PiercingGaze":
			return get_intent_by_name("Jab")
	return intents.pick_random()
		
