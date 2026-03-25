class_name EnemyAI
extends Resource

# 所有可能的意图
@export var intents: Array[Intent]
# 自定义的ai脚本
@export var selection_script: Script

func choose_intent(source: Creature, target: Creature) -> Intent:
	if selection_script:
		return selection_script.new().choose_intent(intents, source, target)
	return random_intent(intents)

func random_intent(intents_: Array[Intent]) -> Intent:
	return intents_[randi() % intents_.size()]
