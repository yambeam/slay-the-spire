extends EnemyAI

var last_action := ""

var ready_talks = [
	"来吧，糊涂的老鬼！",
	"来吧，没种的蠢货",
	"来吧，狂妄的畜生",
	"来吧，缺德的蠢货",
	"来吧，多管闲事的傻子",
	"来吧，没脑子的白痴！",
	"来吧，没用的废物！",
	"来吧，缺心眼的暴徒！",
	"来吧，要死的祸害！"
]

var attack_talks = [
	"唠叨的土包子！",
	"差劲的蠢货！",
	"特号大傻瓜！",
	"大舌头饭桶！",
	"缺德的笨蛋！",
	"没人要的老狗！",
	"愚蠢的懒蛋！",
	"没良心的走狗！",
	"卑鄙的坏蛋！"
]
func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	if current_intent.intent_name == "Ready":
		source.speech(ready_talks.pick_random())
	else:
		source.speech(attack_talks.pick_random())
	last_action = current_intent.intent_name
	super.execute_intent(source, target, current_intent)

func choose_intent(source: Creature, _target: Creature) -> Intent:
	match last_action:
		"":
			if source.encounter_index == 0:
				return get_intent_by_name("Ready")
			else: 
				return get_intent_by_name("StrongPunch")
		"Ready":
			return get_intent_by_name("StrongPunch")
		"StrongPunch":
			return get_intent_by_name("FastPunch")
		"FastPunch":
			return get_intent_by_name("Ready")
		_:
			return random_intent(intents)
