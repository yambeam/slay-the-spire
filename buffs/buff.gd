class_name Buff
extends Node

# SPECIAL一般是无法解除的buff
enum Type {BUFF, DEBUFF, SPECIAL}
var type
# 实际接受buff的对象
var agent: Creature
# 图标
var icon: Texture

signal stack_changed

@export var stacks: int = 1 : set = _set_stacks
var description: String
var buff_name: String

func add_stack(amount: int):
	stacks += amount
	stack_changed.emit()
	
func remove_stack(amount: int):
	stacks -= amount
	if stacks <= 0:
		queue_free()
	stack_changed.emit()

func get_description() -> String:
	return description

func _set_stacks(value: int) -> void:
	stacks = value
	stack_changed.emit()
