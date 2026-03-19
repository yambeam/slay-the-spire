extends Node

func add_buff(buff_context: ApplyBuffContext) -> void:
	
	buff_context.buff_node.stacks = buff_context.amount
	var buff_node: Buff = buff_context.buff_node
	for target: Node2D in buff_context.targets:
		#buff_node = buff_context.buff_node.duplicate()
		var exist_buff: Buff = null
		for child in target.buff_container.get_children():
			# godot的typeof无法分辨自定义类
			if child.buff_name == buff_node.buff_name:
				exist_buff = child
				break
		if exist_buff:
			exist_buff.add_stack(buff_node.amount)
		else:
			# 感觉这么写有点怪
			buff_node.agent = target
			target.buff_container.add_child(buff_node)		


		
			
