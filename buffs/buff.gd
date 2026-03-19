class_name Buff
extends Node

# SPECIAL一般是无法解除的buff
enum Type {BUFF, DEBUFF, SPECIAL}
var type
# 实际接受buff的对象
var agent: Node2D

@export var stacks: int = 1
var description: String
var buff_name: String

func add_stack(amount: int):
	stacks += amount
	
func remove_stack(amount: int):
	stacks -= amount
	if stacks <= 0:
		queue_free()
