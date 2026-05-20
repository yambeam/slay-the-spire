class_name Room

extends Resource

enum Type {NOT_ASSIGNED,MONSTER,TREASURE,CAMPFIRE,BOSS,SHOP,ELITE,UNKNOWN,ANCIENT}


@export var type:Type
#网格位置
@export var row:int
@export var column:int
#坐标
@export var position: Vector2
@export var next_rooms: Array[Room]
#房间是否被选中
@export var selected := false
# 只在战斗房间使用
@export var enemy_encounter: EnemyEncounter

#只在问号房间中使用,用来记录此次问号房间的类型
@export var unknownType:String

func _to_string() -> String:
	return "%s (%s)" % [column , Type.keys()[type][0]]
