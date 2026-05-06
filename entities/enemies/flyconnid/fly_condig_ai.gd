extends EnemyAI

const SMASH_COOL_DOWN: int = 1
const VULNERABLE_SPORES_COOL_DOWN: int = 2
const FRAIL_SPORES_COOL_DOWN: int = 3 

var smash_cool_down := 0
var vulnerable_spores_cool_down := 2
var frail_spores_cool_down := 0



func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	smash_cool_down = smash_cool_down - 1 if smash_cool_down > 0 else 0
	vulnerable_spores_cool_down = vulnerable_spores_cool_down - 1 if vulnerable_spores_cool_down > 0 else 0
	frail_spores_cool_down = frail_spores_cool_down - 1 if frail_spores_cool_down > 0 else 0
	match current_intent.intent_name:
		"Smash":
			smash_cool_down = SMASH_COOL_DOWN
		"VulnerableSpores":
			vulnerable_spores_cool_down = VULNERABLE_SPORES_COOL_DOWN
		"FrailSpores":
			frail_spores_cool_down = FRAIL_SPORES_COOL_DOWN
	super.execute_intent(source, target, current_intent)

func choose_intent(_source: Creature, _target: Creature) -> Intent:
	var available_intents: Array[String] = []
	if smash_cool_down == 0:
		available_intents.append("Smash")
	if vulnerable_spores_cool_down == 0:
		available_intents.append("VulnerableSpores")
	if frail_spores_cool_down == 0:
		available_intents.append("FrailSpores")
	if available_intents.is_empty():
		available_intents.append("VulnerableSpores")
	return get_intent_by_name(available_intents.pick_random())
		
