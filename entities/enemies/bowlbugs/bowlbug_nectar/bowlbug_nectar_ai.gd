extends EnemyAI

var last_action := ""
var buffed = false

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	if current_intent.intent_name == "Buff":
		buffed = true
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("Thrash")
		"Thrash":
			if not buffed:
				return get_intent_by_name("Buff")
			return get_intent_by_name("Thrash")
		"Buff":
			return get_intent_by_name("Thrash")
	return intents.pick_random()
		
func get_skin(spine_sprite: SpineManager) -> SpineSkin:
	var data := spine_sprite.get_skeleton().get_data()
	return data.find_skin("goop")
