extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			if source.encounter_index == 0:
				return get_intent_by_name("Ready")
			else: 
				return get_intent_by_name("StrongPunch")
		"Ready":
			return get_intent_by_name("StrongPunch")
		"StrongPunch":
			return get_intent_by_name("FastPunch")
		"FastPunch":
			return get_intent_by_name("Ready")
		_:
			return random_intent(intents)
