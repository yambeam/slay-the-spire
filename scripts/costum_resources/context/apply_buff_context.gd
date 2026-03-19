## 记录buff的来源，目标，类型,层数
class_name ApplyBuffContext
extends Context

var buff_node: Buff

func _init(source_: Node, targets_: Array[Node], amount_: int, buff_node_: Buff):
	super._init(source_, targets_, amount_)
	buff_node = buff_node_
