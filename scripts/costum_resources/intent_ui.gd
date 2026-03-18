class_name Intent
extends Resource

enum Type{
	ATTACK,
	BUFF,
	CARD_DEBUFF,
	DEFFEND,
	DEBUFF,
	ESCAPE,
	HEAL,
	SUMMON,
	STUN,
	SLEEP,
	UNKOWN,
	SEPERATION,
	ATTACK_DEFFEND,
	ATTACK_BUFF,
	ATTACK_DEBUFF,
	ATTACK_SUMMON,
	DEFFEND_BUFF,
	DEFFEND_DEBUFF,
	DEFFEND_SUMMON
}

## 意图类型
@export var type: Type
## 意图显示文本
@export var values: Array[String]
## 意图音效
@export var sound: AudioStream
