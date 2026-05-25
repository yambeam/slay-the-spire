class_name MainSkill
extends Skill

## 释放技能所需充能
@export var charge_cost: int
## 每回合回复
@export var charge_over_turn: int = 7
## 杀怪回复
@export var charge_over_kill: int = 5

var current_charge: int = 0 : set = _set_current_charge

func available() -> bool:
	return current_charge >= charge_cost

func _set_current_charge(value: int) -> void:
	current_charge = clampi(value, 0, charge_cost * 2)
	skill_stats_changed.emit()

func gain_charge_over_turn() -> void:
	current_charge += charge_over_turn 
	
func gain_charge_over_kill() -> void:
	current_charge += charge_over_kill
