class_name EnemyEncounter
extends Resource

enum Type{
	## 弱怪
	WEAK,
	## 强怪
	STRONG,
	## 精英
	ELITE,
	## boss
	BOSS,
	## 事件
	INCIDENT
}

@export var type: Type
@export_range(0.0, 10.0) var weight: float
@export var enemy_entries: Array[EnemyEntry]
## 便于调试和选取特定组合
@export var encounter_name: String
var accumulated_weight : float = 0.0

func roll_gold_reward() -> int:
	return randi_range(get_min_gold_reward(), get_max_gold_reward())

func get_min_gold_reward() -> int:
	match type:
		Type.WEAK:
			return 10
		Type.STRONG:
			return 15
		Type.ELITE:
			return 35
		Type.BOSS:
			return 100
		_:
			return 0

func get_max_gold_reward() -> int:
	match type:
		Type.WEAK:
			return 15
		Type.STRONG:
			return 25
		Type.ELITE:
			return 45
		Type.BOSS:
			return 100
		_:
			return 0
