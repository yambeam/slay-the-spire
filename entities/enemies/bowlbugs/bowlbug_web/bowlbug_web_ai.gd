extends EnemyAI

var last_action := ""

func set_up_intents(source: Creature, target: Creature) -> void:
	var visuals: BowlBugWebVisuals = source.visuals
	visuals.spite_target.global_position = target.global_position + target.hitbox.shape.size / 2
	for intent: Intent in intents:
		intent.set_source(source)	
		intent.set_target(target)

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("ToxicSpit")
		"ToxicSpit":
			return get_intent_by_name("Thrash")
		"Thrash":
			return get_intent_by_name("ToxicSpit")
	return intents.pick_random()
		
func get_skin(spine_sprite: SpineManager) -> SpineSkin:
	var data := spine_sprite.get_skeleton().get_data()
	return data.find_skin("web")
