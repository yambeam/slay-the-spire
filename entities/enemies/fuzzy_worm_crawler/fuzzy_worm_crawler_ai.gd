extends EnemyAI

var puffed := false
var acid_goop_count = 1
var last_action: String = ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	if current_intent.intent_name == "Inhale":
		puffed = true
	else:
		acid_goop_count += 1
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("AcidGoop")
		"AcidGoop":
			if acid_goop_count == 2:
				acid_goop_count = 0
				return get_intent_by_name("Inhale")
			else:
				return get_intent_by_name("AcidGoop")
		"Inhale":
			return get_intent_by_name("AcidGoop")
		_:
			return random_intent(intents)

func get_die_animation_name() -> String:
	if puffed:
		return "die_puffed"
	return "die"

func get_idle_animation_name() -> String:
	if puffed:
		return "idle_loop_puffed"
	return "idle_loop"

func get_hurt_animation_name() -> String:
	if puffed:
		return "hurt_puffed"
	return "hurt" 
