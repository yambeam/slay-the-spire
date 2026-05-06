extends EnemyAI

var last_action := ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			var enemy_count = _source.get_tree().get_node_count_in_group("ui_enemies")
			if enemy_count > 1:
				return random_intent([get_intent_by_name("Hiss"), get_intent_by_name("Slice")])
			else:
				return get_intent_by_name("Butt")
		"Hiss":
			return get_intent_by_name("Butt")
		"Butt":
			return get_intent_by_name("Slice")
		"Slice":
			return get_intent_by_name("Hiss")
		_:
			return random_intent(intents)
