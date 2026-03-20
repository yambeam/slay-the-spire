class_name BuffManager
extends Node

func add_buff(buff_context: ApplyBuffContext) -> void:
	var buff_node: Buff = buff_context.buff_node
	var exist_buff: Buff = null;
	for child: Buff in get_children():
		if child.buff_name == buff_node.buff_name:
			exist_buff = child
			break
	if exist_buff:
		exist_buff.add_stack(buff_node.amount)
	else:
		# 在applybuffeffect中多目标buff会被拆成多个单目标buff
		buff_node.agent = buff_context.targets[0]
		add_child(buff_node)
		
