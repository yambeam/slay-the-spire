extends EnemyAI
var last_action := ""


func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	var visuals : VantomVisuals = source.visuals
	match current_intent.intent_name:
		"InkStain":
			visuals.scale_up()
			super.execute_intent(source, target, current_intent)
		"InkSpade":
			visuals.scale_up()
			super.execute_intent(source, target, current_intent)
			visuals.show_mega_tail(source.global_position, target.global_position + Vector2(100, 0))
		"Dismental":
			super.execute_intent(source, target, current_intent)
			await visuals.heavy_attack_down()
			visuals.hide_mega_tail()
			visuals.scale_back()
		_:
			super.execute_intent(source, target, current_intent)
	

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("InkStain")
		"InkStain":
			return get_intent_by_name("InkSpade")
		"InkSpade":
			return get_intent_by_name("Dismental")
		"Dismental":
			return get_intent_by_name("ChargeUp")
		"ChargeUp":
			return get_intent_by_name("InkStain")
		_:
			return random_intent(intents)
