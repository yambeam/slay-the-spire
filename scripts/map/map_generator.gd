class_name MapGenerator
extends Node

#默认横向和纵向间隔像素
const X_DIST := 200
const Y_DIST := 200
#五个像素的随机性
const PLACEMENT_RANDOMNESS := 25
#网格分布
const FLOORS :=16
const MAP_WIDTH := 7
const PATHS := 6
#房间权重
const MONSTER_ROOM_WEIGHT := 12.0
const SHOP_ROOM_WEIGHT :=5.0
const CAMPFIRE_ROOM_WEIGHT :=5.0
const ELITE_ROOM_WEIGHT := 6.0      # 精英房间权重（可根据需要调整）
const UNKNOWN_ROOM_WEIGHT := 6.0    # 未知房间权重

# 这里直接通过生成boss房次数判断层级
var act = 0

@export var act1_bosses: Array[EnemyEncounter] = []
@export var act2_bosses: Array[EnemyEncounter] = []

var random_room_type_weights ={
	Room.Type.MONSTER:0.0,
	Room.Type.CAMPFIRE: 0.0,
	Room.Type.SHOP:0.0,
	Room.Type.UNKNOWN: 0.0,
	Room.Type.ELITE: 0.0
}

var random_room_type_total_weight := 0
var map_data: Array[Array]

#func _ready() -> void:
	#generate_map()

func generate_map() -> Array[Array]:
	#生成地图数组	
	map_data =_generate_initial_grid()
	
	var middle := floori(MAP_WIDTH * 0.5)
	var ancient_room := map_data[0][middle] as Room
	ancient_room.type = Room.Type.ANCIENT
	
	
	#生成起始节点
	var starting_points := _get_random_starting_points()
	for j in starting_points:
		var first_floor_room := map_data[1][j] as Room
		ancient_room.next_rooms.append(first_floor_room)
	
	
	for j in starting_points:
		var current_j := j
		for i in range(1, FLOORS - 1):
			current_j = _setup_connection(i, current_j)
	
	_setup_boss_room()
	_setup_random_room_weights()
	_setup_room_types()
	
	#debug
	#var i := 0
	#for floor in map_data:
		#
		#print("floor %s" %i )
		#var used_rooms = floor.filter(
			#func(room: Room): return room.next_rooms.size() > 0
		#)
		#print(used_rooms)
		#i += 1
	return map_data

func _generate_initial_grid()-> Array[Array]:
	
	var result: Array[Array]=[]
	
	for i in FLOORS:
		var adjacent_rooms: Array[Room]=[]
		
		for j in MAP_WIDTH:
			var current_room := Room.new()
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST-100,i *-Y_DIST+300) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms=[]
		
			#boss room has a non_random Y
			if i == FLOORS - 1:
				current_room.position.y = (i + 1)* -Y_DIST+300
			adjacent_rooms.append((current_room))
			
		result.append((adjacent_rooms))
		
	return result

func _get_random_starting_points() -> Array[int]:
	
	var y_coordinates: Array[int]
	var unique_points: int = 0
	while unique_points < 2:
		unique_points = 0
		y_coordinates= []
		
		for i in PATHS:
			var starting_point:= randi_range(0, MAP_WIDTH-1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			
			y_coordinates.append(starting_point)
			
	return y_coordinates

func _setup_connection(i: int, j: int) -> int:
	var next_room:Room
	var current_room := map_data[i][j] as Room
	
	while not next_room or _would_cross_existing_path(i, j, next_room):
		var random_j := clampi(randi_range(j-1,j + 1),0,MAP_WIDTH-1)
		next_room = map_data[i+1][random_j]
		
	current_room.next_rooms.append(next_room)
	
	return next_room.column
	
func _would_cross_existing_path(i:int,j:int,room:Room)-> bool:
	var left_neighbour:Room
	var right_neighbour:Room
	
	# if j == 0, there's no left neighbour
	if j > 0:
		left_neighbour = map_data[i][j - 1]
	
	# if j == MAP_WIDTH - 1, there's no right neighbour
	if j <MAP_WIDTH - 1:
		right_neighbour = map_data[i][j + 1]
	
	# can't cross in right dir if right neighbour goes to left
	if right_neighbour and room.column > j:
		for next_room: Room in right_neighbour.next_rooms:
			if next_room.column<room.column:
				return true
	# can't cross in left dir if left neighbour goes to right
	if left_neighbour and room.column <j:
		for next_room: Room in left_neighbour.next_rooms:
			if next_room.column >room.column:
				return true
				
	return false
	 
func _setup_boss_room() -> void:
	#固定boss房间为最后一层最中间的房间
	var middle := floori(MAP_WIDTH * 0.5)
	var boss_room := map_data[FLOORS - 1][middle] as Room
	
	for j in MAP_WIDTH:
		var current_room = map_data[FLOORS - 2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
	boss_room.type = Room.Type.BOSS
	act += 1
	if act == 1:
		boss_room.enemy_encounter = act1_bosses.pick_random()
	else:
		boss_room.enemy_encounter = act2_bosses.pick_random()
	

func _setup_random_room_weights() -> void:
	
	random_room_type_weights[Room.Type.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.Type.ELITE] = random_room_type_weights[Room.Type.MONSTER] + ELITE_ROOM_WEIGHT
	random_room_type_weights[Room.Type.CAMPFIRE] = random_room_type_weights[Room.Type.ELITE] + CAMPFIRE_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = random_room_type_weights[Room.Type.CAMPFIRE] + SHOP_ROOM_WEIGHT
	random_room_type_weights[Room.Type.UNKNOWN] = random_room_type_weights[Room.Type.SHOP] + UNKNOWN_ROOM_WEIGHT

	random_room_type_total_weight = random_room_type_weights[Room.Type.UNKNOWN]
	
func _setup_room_types() -> void:
	# first floor is always a battle
	for room:Room in map_data[1]:
		if room.next_rooms.size() >0:
			room.type = Room.Type.MONSTER
	# 9th floor is always a treasure
	for room: Room in map_data[9]:
		if room.next_rooms.size() >0:
			room.type = Room.Type.TREASURE
	# last floor before the boss is always a campfire
	for room: Room in map_data[14]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.CAMPFIRE
	
	# rest of rooms

	for current_floor in map_data:
		for room:Room in current_floor:
			for next_room:Room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)
	
func _set_room_randomly(room_to_set:Room)-> void:
	var campfire_below_4 := true
	var elite_below_4 := true
	var consecutive_campfire := true
	var consecutive_shop := true
	var campfire_on_13 := true
	var consecutive_elite := true
	var consecutive_unknown := true
	var type_candidate: Room.Type

	while campfire_below_4 or consecutive_campfire or consecutive_shop or campfire_on_13 or consecutive_elite or consecutive_unknown or elite_below_4:
		type_candidate = _get_random_room_type_by_weight()
		var is_campfire := type_candidate == Room.Type.CAMPFIRE
		var is_shop := type_candidate == Room.Type.SHOP
		var is_elite := type_candidate == Room.Type.ELITE
		var is_unknown := type_candidate == Room.Type.UNKNOWN

		var has_campfire_parent := _room_has_parent_of_type(room_to_set, Room.Type.CAMPFIRE)
		var has_shop_parent := _room_has_parent_of_type(room_to_set, Room.Type.SHOP)
		var has_elite_parent := _room_has_parent_of_type(room_to_set, Room.Type.ELITE)
		var has_unknown_parent := _room_has_parent_of_type(room_to_set, Room.Type.UNKNOWN)

		campfire_below_4 = is_campfire and room_to_set.row < 4
		elite_below_4 = is_elite and room_to_set.row < 5
		consecutive_campfire = is_campfire and has_campfire_parent
		consecutive_shop = is_shop and has_shop_parent
		campfire_on_13 = is_campfire and room_to_set.row == 13
		consecutive_elite = is_elite and has_elite_parent
		consecutive_unknown = is_unknown and has_unknown_parent

	room_to_set.type = type_candidate
	
func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	
	var parents: Array[Room]=[]
	
	#获取给定房间所有有效父房间
	# left parent
	if room.column >0 and room.row >0:
		var parent_candidate := map_data[room.row - 1][room.column - 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# parent below
	if room.row >0:
		var parent_candidate := map_data[room.row - 1][room.column] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# right parent
	if room.column < MAP_WIDTH-1 and room.row >0:
		var parent_candidate := map_data[room.row - 1][room.column + 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	#检查是否有任何父房间与我们正在寻找的特定类型匹配
	for parent: Room in parents:
		if parent.type == type:
			return true
	
	return false
	
	
	
#基于权重找到对应类型的房间
func _get_random_room_type_by_weight() -> Room.Type:
	var roll := randf_range(0.0, random_room_type_total_weight)
	if roll < random_room_type_weights[Room.Type.MONSTER]:
		return Room.Type.MONSTER
	elif roll < random_room_type_weights[Room.Type.ELITE]:
		return Room.Type.ELITE
	elif roll < random_room_type_weights[Room.Type.CAMPFIRE]:
		return Room.Type.CAMPFIRE
	elif roll < random_room_type_weights[Room.Type.SHOP]:
		return Room.Type.SHOP
	else:
		return Room.Type.UNKNOWN
	
