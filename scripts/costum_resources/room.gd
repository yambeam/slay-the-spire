class_name Room

extends Resource

enum Type {NOT_ASSIGNED,MONSTER,TREASURE,CAMPFIRE,SHOP,BOSS}


@export var type:Type
#网格位置
@export var row:int
@export var column:int
#坐标
@export var position: Vector2
@export var next_rooms: Array[Room]
#房间是否被选中
@export var selected := false


func _to_string() -> String:
	return "%s (%s)" % [column , Type.keys()[type][0]]
