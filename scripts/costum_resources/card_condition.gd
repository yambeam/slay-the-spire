class_name CardCondition
extends Resource

enum Type{
	ALWAYS, # 总是满足条件
	NOT_UPGRADED, # 没有升级
	NO_EXHAUTST, # 没有消耗词条
	NO_ETHEREAL, # 没有虚无
	NO_SLY, # 没有奇巧
	IS_ATTACK, # 攻击牌
	IS_SKILL, # 技能牌
	IS_POWER, # 能力牌
	NON_ATTACK, # 非攻击牌
	NON_SKILL, # 非技能牌
	NO_FIRST_PLAY_FREE_AND_NOT_ZERO_COST, # 非第一次打出免费且费用不为0 
}

@export var type: Type = Type.ALWAYS

func _init(type_: Type = Type.ALWAYS) -> void:
	type = type_

func is_met(card: Card) -> bool:
	match type:
		Type.ALWAYS:
			return true
		Type.NOT_UPGRADED:
			return !card.upgraded
		Type.NO_EXHAUTST:
			return !card.exhaust
		Type.NO_ETHEREAL:
			return !card.ethereal
		Type.NO_SLY:
			return !card.sly
		Type.IS_ATTACK:
			return card.type == Card.Type.ATTACK
		Type.IS_SKILL:
			return card.type == Card.Type.SKILL
		Type.IS_POWER:
			return card.type == Card.Type.POWER
		Type.NO_FIRST_PLAY_FREE_AND_NOT_ZERO_COST:
			return !card.first_play_free and !(card.get_cost() == 0)
		Type.NON_ATTACK:
			return card.type != Card.Type.ATTACK
		Type.NON_SKILL:
			return card.type != Card.Type.SKILL
		_:
			return false			
