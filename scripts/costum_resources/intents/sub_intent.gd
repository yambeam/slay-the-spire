class_name SubIntent
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
	STATUS,
	UNKOWN,
}

@export var type: Type
@export var sound: AudioStream
@export var effect: Effect

var source: Creature
var target: Creature


func execute() -> void:
	await effect.execute(source, {"targets": [target] as Array[Node]}, null)

func get_text() -> String:
	#match type:
		#Type.ATTACK:
			##TODO: 动态显示
			#if repeat == 1:
				#return "{0}".format([final_value])
			#else:
				#return "{0}x{1}".format([final_value, repeat])
		#_:
			#return ""
	return ""
	
func get_intent_name() -> String:
	match type:
		Type.ATTACK:
			return "[color=gold]攻势[/color]"
		Type.BUFF:
			return "[color=gold]强化[/color]"
		Type.DEFFEND:
			return "[color=gold]守势[/color]"
		Type.DEBUFF:
			return "[color=gold]策略[/color]"
		Type.CARD_DEBUFF:
			return "[color=gold]恶意[/color]"
		Type.ESCAPE:
			return "[color=gold]懦弱[/color]"
		Type.HEAL:
			return "[color=gold]恢复[/color]"
		Type.SUMMON:
			return "[color=gold]召唤[/color]"
		Type.STUN:
			return "[color=gold]击晕[/color]"
		Type.SLEEP:
			return "[color=gold]沉睡[/color]"
		Type.STATUS:
			return "[color=gold]策略[/color]"
		Type.UNKOWN:
			return "[color=gold]未知[/color]"
		_:
			return ""

func get_intent_description() -> String:
	#match type:
		#Type.ATTACK:
			#if repeat > 1:
				#return "该敌人将要[color=gold]攻击[/color]造成{0}点伤害{1}次".format([final_value, repeat])
			#return "该敌人将要[color=gold]攻击[/color]造成{0}点伤害".format([final_value])
		#Type.DEFFEND:
			#return "这个敌人将在其回合获得[color=gold]格挡[/color]"
		#_:
			#return ""
	return ""
