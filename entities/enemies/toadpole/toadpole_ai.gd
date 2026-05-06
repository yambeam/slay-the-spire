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
		sub_intent.execute()

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return random_intent([get_intent_by_name("Spiken"), get_intent_by_name("Whirl")])
		"Whirl":
			return get_intent_by_name("Spiken")
		"Spiken":
			return get_intent_by_name("SpikeSpit")
		"SpikeSpit":
			return get_intent_by_name("Whirl")
		_:
			return random_intent(intents)

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

func get_skin(spine_sprite: SpineManager) -> SpineSkin:
	var eye = randi() % 2
	var pattern = randi() % 2
	var skin: SpineSkin = spine_sprite.new_skin("new skin")
	var data := spine_sprite.get_skeleton().get_data()
	skin.add_skin(data.find_skin("eye1") if eye == 0 else data.find_skin("eye2"))
	skin.add_skin(data.find_skin("pattern1") if pattern == 0 else data.find_skin("pattern2"))
	return skin
