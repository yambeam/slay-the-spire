extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	if last_action == "":
		return get_intent_by_name("StickyShot")
	elif last_action == "StickyShot":
		return get_intent_by_name("ClumpShot")
	elif last_action == "ClumpShot":
		return get_intent_by_name("StickyShot")
	else:
		return random_intent(intents)
		
