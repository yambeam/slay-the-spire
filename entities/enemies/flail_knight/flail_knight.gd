extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("Ram")
		"Ram":
			return get_intent_by_name("WarChant")
		"WarChant":
			return get_intent_by_name("Flail")
		"Flail":
			return get_intent_by_name("Ram")
		_:
			return random_intent(intents)
		
