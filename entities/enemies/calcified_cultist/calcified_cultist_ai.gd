extends EnemyAI

var last_action = ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	if current_intent.intent_name == "Incantation":
		source.speech("咔咔!")
	last_action = current_intent.intent_name	
	
	super.execute_intent(source, target, current_intent)

func choose_intent(source: Creature, _target: Creature) -> Intent:
	source = source as Enemy
	match last_action:
		"":
			return get_intent_by_name("Incantation")
		"Incantation":
			return get_intent_by_name("DarkStrike")
		"DarkStrike":
			return get_intent_by_name("DarkStrike")
		_:
			return get_intent_by_name("DarkStrike")

func get_skin(spine_sprite: SpineManager) -> SpineSkin:
	var data := spine_sprite.get_skeleton().get_data()
	return data.find_skin("coral")
