extends EnemyAI

var last_action := ""
var awake = false
var awaken = false

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	if current_intent.intent_name == "Sleep" and not awaken and awake:
		current_intent.anim_name = "wake_up"
		awaken = true
		if source.has_buff("覆甲"):
			source.get_buff("覆甲").remove_stack(100)
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	if not awaken:
		return get_intent_by_name("Sleep")
	else:
		match last_action:
			"":
				return get_intent_by_name("Slash")
			"Sleep":
				return get_intent_by_name("Slash")
			"Slash":
				return get_intent_by_name("Disembowel")
			"Disembowel":
				return get_intent_by_name("Slash2")
			"Slash2":
				return get_intent_by_name("SoulSiphon")
			"SoulSiphon":
				return get_intent_by_name("Slash")
			_:
				return random_intent(intents)

func get_idle_animation_name() -> String:
	if awaken:
		return "idle_loop"
	return "sleep_loop"

func get_hurt_animation_name() -> String:
	if awaken:
		return "hurt"
	return "hurt_sleeping"
