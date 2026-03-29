extends EnemyAI

var buffed := false
var last_action: String = ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	
	match current_intent.intent_name:
		"Whirl":
			current_intent.anim_name = "attack_single_buffed" if buffed else "attack_single"
		"Spiken":
			current_intent.anim_name = "buff"
			buffed = true
		"SpikeSpit":
			current_intent.anim_name = "attack_triple_buffed" if buffed else "attack_triple"
			buffed = false
		_:
			pass
	last_action = current_intent.intent_name
	for sub_intent: SubIntent in current_intent.sub_intents:
		sub_intent.execute(source, [target])

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	if last_action.is_empty():
		var intent = random_intent([intents[0], intents[2]])
		last_action = intent.intent_name
		return intent
	else:
		# 考虑到一个怪物的意图也没几个我就不重构了
		match last_action:
			"Whirl":
				return intents[2]
			"Spiken":
				return intents[1]
			"SpikeSpit":
				return intents[0]
			_:
				return random_intent(intents)

func random_intent(intents_: Array[Intent]) -> Intent:
	return intents_[randi() % intents_.size()]

func get_die_animation_name() -> String:
	if buffed:
		return "die_buffed"
	return "die"

func get_idle_animation_name() -> String:
	if buffed:
		return "idle_loop_buffed"
	return "idle_loop"

func get_hurt_animation_name() -> String:
	if buffed:
		return "hurt_buffed"
	return "hurt" 
