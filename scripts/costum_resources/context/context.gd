class_name Context
extends RefCounted

var amount: int
var source: Node
var targets: Array[Node]


func _init(source_: Node, targets_: Array[Node], amount_: int):
	source = source_
	targets = targets_
	amount = amount_
