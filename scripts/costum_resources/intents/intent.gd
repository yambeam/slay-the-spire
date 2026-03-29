class_name Intent
extends Resource


### 意图类型
#@export var type: Type
### 意图显示文本
#@export var values: Array[String]
### 意图音效
#@export var sound: AudioStream

@export var sub_intents: Array[SubIntent]
# 供自定义脚本识别
@export var intent_name: String
# 决定怪物使用的动画
@export var anim_name: String

# 不考虑多玩家
func calc_final_values(source: Creature, target: Creature) -> void:
	for sub_intent: SubIntent in sub_intents:
		sub_intent.calc_final_value(source, target)
