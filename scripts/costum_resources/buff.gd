class_name Buff
extends Node

# SPECIAL一般是无法解除的buff
enum Type {BUFF, DEBUFF, SPECIAL}
enum AFFECT{SELF, TARGET, ALL}
var type: Type
var affect: AFFECT
# 实际接受buff的对象
var agent: Creature
# 图标
var icon: Texture

signal stack_changed

@export var stacks: int = 1 : set = _set_stacks
var description: String
var buff_name: String 
var stackable: bool = true

func add_stack(amount: int):
	if not stackable and stacks > 0:
		return
	elif amount < 0:
		remove_stack(-amount)
		return
	stacks += amount
	stack_changed.emit()
	
func remove_stack(amount: int):
	stacks -= amount
	if stacks <= 0:
		queue_free()
	stack_changed.emit()

func get_description() -> String:
	return description

func get_modifier() -> Array[Modifier]:
	return []

func get_modifiers_on_type(type_: Enums.NumericType) -> Array:
	var result := []
	for modifier: Modifier in get_modifier():
		if modifier.type == type_:
			result.append(modifier)
	return result	

func _set_stacks(value: int) -> void:
	if stackable:
		stacks = value
	else:
		stacks = clampi(value, 0, 1)
	stack_changed.emit()
