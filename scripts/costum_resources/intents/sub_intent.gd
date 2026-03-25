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
	UNKOWN,
}

@export var type: Type
@export var icon: Texture2D
@export var base_value: int
@export var repeat: int = 1
@export var sound: AudioStream

var final_value : int

func get_final_value() -> int:
	return final_value

func calc_final_value(source: Creature, target: Creature) -> void:
	var modifiers := []
	match type:
		Type.ATTACK:
			if target:
				modifiers = NumericHelper.combine_modifiers(source.get_modifiers_by_type(Enums.NumericType.DAMAGE, Buff.AFFECT.SELF), target.get_modifiers_by_type(Enums.NumericType.DAMAGE, Buff.AFFECT.TARGET))
			else:
				modifiers = source.get_modifiers_by_type(Enums.NumericType.DAMAGE, Buff.AFFECT.SELF)
		Type.DEFFEND:
			modifiers = source.get_modifiers_by_type(Enums.NumericType.BLOCK, Buff.AFFECT.SELF)
		_:
			pass
	final_value = NumericHelper.apply_modifiers(base_value, modifiers)
	
# 其他的需要通过继承实现
func execute(source: Creature, targets: Array[Node]) -> void:
	match type:
		Type.ATTACK:
			var attack_effect = AttackEffect.new()
			for i in range(repeat):
				attack_effect.execute(DamageContext.new(source, targets, base_value))
				SFXPlayer.play(sound)
				if i < repeat - 1:
					await source.get_tree().create_timer(0.3).timeout
		Type.DEFFEND:
			var gain_block_effect = BlockEffect.new()
			gain_block_effect.execute(GainBlockContext.new(source, [source], base_value))
			SFXPlayer.play(sound)
		_:
			SFXPlayer.play(sound)

func get_text() -> String:
	match type:
		Type.ATTACK:
			#TODO: 动态显示
			if repeat == 1:
				return "{0}".format([final_value])
			else:
				return "{0}x{1}".format([final_value, repeat])
		_:
			return ""

func get_intent_name() -> String:
	match type:
		Type.ATTACK:
			return "[color=gold]攻势[/color]"
		Type.DEFFEND:
			return "[color=gold]守势[/color]"
		_:
			return ""

func get_intent_description() -> String:
	match type:
		Type.ATTACK:
			if repeat > 1:
				return "该敌人将要[color=gold]攻击[/color]造成{0}点伤害{1}次".format([final_value, repeat])
			return "该敌人将要[color=gold]攻击[/color]造成{0}点伤害".format([final_value])
		Type.DEFFEND:
			return "这个敌人将在其回合获得[color=gold]格挡[/color]"
		_:
			return ""
