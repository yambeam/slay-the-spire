extends EnemyAI

var naked := true
var last_action: String = ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	if current_intent.intent_name == "SpikeExplosion":
		naked = true
	elif current_intent.intent_name == "ProtrudingSpikes":
		naked = false
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("ProtrudingSpikes")
		"ProtrudingSpikes":
			return get_intent_by_name("SpikeExplosion")
		"SpikeExplosion":
			return get_intent_by_name("TongueLash")
		"TongueLash":
			return get_intent_by_name("ProtrudingSpikes")
		_:
			return random_intent(intents)

func get_die_animation_name() -> String:
	if naked:
		return "die_naked"
	return "die"

func get_idle_animation_name() -> String:
	if naked:
		return "idle_naked_loop"
	return "idle_loop"

func get_hurt_animation_name() -> String:
	if naked:
		return "hurt_naked"
	return "hurt" 
