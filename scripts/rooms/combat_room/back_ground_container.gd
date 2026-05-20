class_name BackGroundContainter
extends Control

func update_background(act: int) -> void:
	var background_dict = ItemPool.act1_background_dict if act == 1 else ItemPool.act2_background_dict
	var index = 0
	var background_set = background_dict["a"] if randi() % 2 == 1 else background_dict["b"]
	for child: TextureRect in get_children():
		if index == 0:
			child.texture = background_dict["common"]
		else:
			child.texture = background_set[index - 1]
		index += 1
		
			
