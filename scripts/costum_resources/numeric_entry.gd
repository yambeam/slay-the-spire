class_name NumericEntry
extends Resource

enum AFFECTED_BY {
	SELF,
	TARGET,
	BOTH,
	NONE
}

@export var type: Enums.NumericType
@export var base_value: int
# 造成{damage}点伤害, damage就是placeholder	
@export var placeholder: String
# 受到谁的buff影响
@export var affected_by: AFFECTED_BY
