class_name NumericEntry
extends Resource

enum AFFECTED_BY {
	SELF,
	TARGET,
	BOTH,
	NONE
}

enum Source{
	## 固定值
	FIXED, 
	## 基于玩家格挡
	PLAYER_BLOCK,
	## 基于玩家力量
	PLAYER_STRENGTH,
	## 基于卡牌特定名称数量
	CARD_COUNT_BY_NAME
}

@export var type: Enums.NumericType
@export var base_value: int
## 造成{damage}点伤害, damage就是placeholder	
@export var placeholder: String
## 受到谁的buff影响(实际上的作用为是否受到buff影响，只使用BOTH或NONE)
@export var affected_by: AFFECTED_BY
## 卡牌数值来源
@export var source: Source
## 额外的参数，比如对于完美打击：“每有一张打击牌，伤害加2"，为了检索打击牌，需要传入{”card_name": "打击"}
@export var extra_param: Dictionary = {}
