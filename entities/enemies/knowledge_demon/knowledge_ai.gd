extends EnemyAI

var stage: int = 0
var burnt := false
var last_action: String = ""

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	last_action = current_intent.intent_name
	match current_intent.intent_name:
		"KnowledgeCurse1":
			stage = 1
			await super.execute_intent(source, target, current_intent)
			source.speech("此事已成")
		"KnowledgeCurse2":
			stage = 2
			await super.execute_intent(source, target, current_intent)
			source.speech("此事已成")
		"KnowledgeCurse3":
			stage = 3
			await super.execute_intent(source, target, current_intent)
			source.speech("此事已成")
		"KnowledgeOverload":
			burnt = true
			super.execute_intent(source, target, current_intent)
		"Think":
			burnt = false
			super.execute_intent(source, target, current_intent)
		_:		
			super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			return get_intent_by_name("KnowledgeCurse1")
		"KnowledgeCurse1":
			return get_intent_by_name("ATaste")
		"KnowledgeCurse2":
			return get_intent_by_name("ATaste")
		"KnowledgeCurse3":
			return get_intent_by_name("ATaste")
		"ATaste":
			return get_intent_by_name("KnowledgeOverload")
		"KnowledgeOverload":
			return get_intent_by_name("Think")
		"Think":
			match stage:
				1:
					return get_intent_by_name("KnowledgeCurse2")
				2:
					return get_intent_by_name("KnowledgeCurse3")
				_:
					return get_intent_by_name("ATaste")				
		_:
			return random_intent(intents)

func get_die_animation_name() -> String:
	if burnt:
		return "die_burnt"
	return "die"

func get_idle_animation_name() -> String:
	if burnt:
		return "burnt_loop"
	return "idle_loop"

func get_hurt_animation_name() -> String:
	if burnt:
		return "hurt_burnt"
	return "hurt"
