extends EnemyAI

var curled := false
var last_action: String = ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	if current_intent.intent_name == "Pounce":
		if curled:
			current_intent.anim_name = "uncurl"
			curled = false
		else:
			current_intent.anim_name = "attack"
	elif current_intent.intent_name == "CurlAndGrow":
		if curled:
			current_intent.anim_name = "curled_loop"
		else:
			current_intent.anim_name = "curl"
	else:
		if curled:
			current_intent.anim_name = "curled_loop"
		else:
			current_intent.anim_name = "attack_web"
	last_action = current_intent.intent_name
	await super.execute_intent(source, target, current_intent)
	

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("WebCannon")
		"WebCannon":
			return get_intent_by_name("CurlAndGrow")
		"CurlAndGrow":
			return get_intent_by_name("Pounce")
		"Pounce":
			return get_intent_by_name("WebCannon")
		_:
			return random_intent(intents)

func get_die_animation_name() -> String:
	if curled:
		return "die_curled"
	return "die"

func get_idle_animation_name() -> String:
	if curled:
		return "curled_loop"
	return "idle_loop"

func get_hurt_animation_name() -> String:
	if curled:
		return "curled_loop"
	return "hurt" 
