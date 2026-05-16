class_name Map
extends Node2D

#//滚动速度加快
const SCROLL_SPEED := 250
const MAP_ROOM = preload("res://scenes/map/map_room.tscn")
const MAP_LINE = preload("res://scenes/map/map_line.tscn")



const STAGE_BACKGROUNDS = {
	1: {
		"top": "res://images/packed/map/map_bgs/overgrowth/map_top_overgrowth.png",
		"middle": "res://images/packed/map/map_bgs/overgrowth/map_middle_overgrowth.png",
		"bottom": "res://images/packed/map/map_bgs/overgrowth/map_bottom_overgrowth.png",
		"legend_bg": "res://images/rooms/false_queen/false_queen_bg.png"
	},
	2: {
		"top": "res://images/packed/map/map_bgs/underdocks/map_top_underdocks.png",
		"middle": "res://images/packed/map/map_bgs/underdocks/map_middle_underdocks.png",
		"bottom": "res://images/packed/map/map_bgs/underdocks/map_bottom_underdocks.png",
		"legend_bg": "res://images/events/crystal_sphere/crystal_sphere_minigame_bg.png"  
	}
}

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals:Node2D = $Visuals
@onready var camera_2d:Camera2D = $Camera2D
@onready var legend: Legend = $Legend_background/Legend
@onready var legendAll: CanvasLayer = $Legend_background

@export var scroll_enabled: bool = true   

#var map_data: Array[Array]
#var floors_climbed: int
@export var last_room: Room
@export var camera_edge_y: float

@export var room_to_lines: Dictionary = {} 

@export var run_stats: RunStats   # 外部状态

@export var old_camera_2d_position_y: float

# 预加载的商店场景资源
@export var shop_scene_resource: PackedScene = null

func _ready() -> void:
	camera_edge_y = MapGenerator.Y_DIST * (MapGenerator.FLOORS -1)
	
	legend.highlight_requested.connect(_on_legend_highlight_requested)
	legend.highlight_cleared.connect(_on_legend_highlight_cleared)
	
	_preload_shop_scene()
	#先执行 map的_ready()	方法
	#if run_stats.map_data == null:
		#generate_new_map()
	#unlock_floor(run_stats.floors_climbed)
	
	#await get_tree().process_frame  # 等待一帧确保视口尺寸已确定
	#var viewport_size = get_viewport().get_visible_rect().size
	#var design_size = Vector2(1000, 550)
	#var scale_factor = viewport_size / design_size
	## 取最小缩放因子以保持宽高比（与 keep aspect 类似）
	#var zoom_factor = min(scale_factor.x, scale_factor.y)
	#camera_2d.zoom = Vector2(zoom_factor, zoom_factor)
	
func _preload_shop_scene() -> void:
	# 如果已经加载过则跳过
	if shop_scene_resource != null:
		return
	# 使用 ResourceLoader 异步加载，不阻塞当前帧
	ResourceLoader.load_threaded_request("res://scenes/rooms/shop_room/shop_room.tscn")

# 获取已加载的商店场景资源（如果尚未完成则等待）
func get_shop_scene() -> PackedScene:
	if shop_scene_resource:
		return shop_scene_resource
	
	var path = "res://scenes/rooms/shop_room/shop_room.tscn"
	var status = ResourceLoader.load_threaded_get_status(path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		shop_scene_resource = ResourceLoader.load_threaded_get(path)
		return shop_scene_resource
	elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		# 如果还在加载中，可以等待或返回 null
		return null
	else:
		# 加载失败或未请求，同步加载作为后备
		shop_scene_resource = load(path)
		return shop_scene_resource
	
func init(stats:RunStats) -> void:
	run_stats = stats
	if run_stats.map_data.is_empty():
		generate_new_map()
	else:
		create_map()
	unlock_floor(run_stats.floors_climbed)


func _input(event:InputEvent) -> void:
	#print("Map._input received: ", event, " scroll_enabled: ", scroll_enabled)
	if not scroll_enabled:
		return                     
	if event.is_action_pressed("scroll_up"):
		camera_2d.position.y = max(camera_2d.position.y - SCROLL_SPEED, -camera_edge_y)
	elif event.is_action_pressed("scroll_down"):
		camera_2d.position.y = min(camera_2d.position.y + SCROLL_SPEED, 0)
		
func generate_new_map() -> void:
	run_stats.floors_climbed =0
	run_stats.map_data = map_generator.generate_map()
	create_map()
	
func load_map(stats:RunStats,last_room_climbed:Room)->void:
	run_stats = stats
	last_room=last_room_climbed
	if run_stats.map_data.is_empty():
		generate_new_map()
	else:
		create_map()
	if run_stats.floors_climbed>0:
		unlock_next_rooms()
	else:
		unlock_floor()
		
	_restore_line_visibility()  
	
func create_map() -> void:
	for current_floor: Array in run_stats.map_data:
		for room: Room in current_floor:
			if room.next_rooms.size() >0:
				_spawn_room(room)
				
	# Boss room has no next room but we need to spawn it
	var middle := floori(MapGenerator.MAP_WIDTH * 0.5)
	
	_spawn_room(run_stats.map_data[MapGenerator.FLOORS-1][middle])
	var map_width_pixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH -1)
	
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y / 2
	
	
			
func unlock_floor(which_floor:int = run_stats.floors_climbed) -> void:
	for map_room:MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true
			
func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true
			
			
			
func show_map() -> void:
	show()
	camera_2d.enabled =true
		
func hide_map() -> void:
	hide()
	#camera_2d.enabled = false
	
func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)   
	
	#将对应的点击范围按比例缩小
	if room.type == Room.Type.CAMPFIRE or room.type == Room.Type.SHOP:
		new_map_room.scale = Vector2(1.4, 1.4)
		new_map_room.Select_Circle.scale = Vector2(1.0, 1.0 )
	else:
		new_map_room.scale = Vector2(1.0005, 1.0005)
		new_map_room.Select_Circle.scale = Vector2(1.3,1.3)
		
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)
	
	new_map_room._update_collision_scale()
	
	#if room.selected:
		#if room.type != Room.Type.ANCIENT and room.type != Room.Type.BOSS:
			#new_map_room.show_selected()
		
	new_map_room.original_scale = new_map_room.scale
		
func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return
	for next:Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		# 设置初始透明度（ 0.2 ）
		new_map_line.modulate = Color(1, 1, 1, 0.1)
		
		# 保存两端房间引用
		new_map_line.set_meta("room_a", room)
		new_map_line.set_meta("room_b", next)
		lines.add_child(new_map_line)
		#print("连线已添加，从 ", room.position, " 到 ", next.position, "，节点数：", lines.get_child_count())
	
	
func _on_map_room_selected(room: Room) -> void:
	#print("=== _on_map_room_selected 被调用 ===")
	run_stats.current_room = room
	var previous_room = last_room
	Events.map_room_selected.emit(room)

	#print("捕获到的 previous_room: ", previous_room.position if previous_room else "null")
	call_deferred("_apply_map_ui_updates", room, previous_room)
	
func _apply_map_ui_updates(room: Room, previous_room: Room) -> void:
	#print("=== _apply_map_ui_updates 被调用 ===")
	#print("room: ", room.position)
	#if previous_room:
		#print("previous_room: ", previous_room.position)
	#else:
		#print("previous_room is null")
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false
	if previous_room != null and previous_room != room:
		update_line_opacity_between(previous_room, room, 0.9)
	last_room = room

	old_camera_2d_position_y = camera_2d.position.y
	camera_2d.position.y = 0
	scroll_enabled = false
	hide()
	legendAll.hide()
	
func complete_current_room() -> void:
	if last_room == null:
		print("last_room is null, aborting")
		return
	#print("complete_current_room: last_room row=", last_room.row, " next_rooms count=", last_room.next_rooms.size())
	var new_floor = last_room.row + 1
	run_stats.set_floor(new_floor)
	unlock_next_rooms()
	
	#地图和legend显现,可以滚动
	show()
	camera_2d.position.y = old_camera_2d_position_y
	legendAll.show()
	scroll_enabled = true
	# 更新 floors_climbed：当前房间的下一层索引 = last_room.row + 1
	# 解锁新楼层（根据新 floors_climbed 解锁）
	#unlock_floor(run_stats.floors_climbed)
	# 可选：如果只想解锁相连的房间，可以使用 unlock_next_rooms()
	# 但 unlock_next_rooms 依赖 last_room，直接调用即可
	
func _on_legend_highlight_requested(type: int):
	#print("收到高亮请求，类型: ", type)
	for map_room in rooms.get_children():
		if map_room.room.type == type:
			map_room.set_highlight(true)

func _on_legend_highlight_cleared():
	for map_room in rooms.get_children():
		map_room.set_highlight(false)

func update_line_opacity_between(room_a: Room, room_b: Room, opacity: float) -> void:
	#print("开始查找连线: ", room_a.position, " -> ", room_b.position)
	for line in lines.get_children():
		var points = line.points
		if points.size() == 2:
			var p1 = points[0]
			var p2 = points[1]
			if (p1.distance_to(room_a.position) < 1.0 and p2.distance_to(room_b.position) < 1.0) or \
			   (p1.distance_to(room_b.position) < 1.0 and p2.distance_to(room_a.position) < 1.0):
				line.modulate.a = opacity
				#print("已设置连线透明度为 ", opacity, " 路径: ", p1, " -> ", p2)
				return   # 找到即返回
	#print("未找到匹配的连线！")


func rebuild_for_stage(stats: RunStats) -> void:
	_clear_map()
	generate_new_map()

	#根据当前阶段换背景
	_apply_stage_background(stats.current_stage)

	# 激活起点房间
	var start_room: MapRoom = null
	for child in rooms.get_children():
		var map_room := child as MapRoom
		if map_room.room.row == 0 and map_room.room.type == Room.Type.ANCIENT:
			start_room = map_room
			break
	if start_room:
		start_room.available = true
		last_room = start_room.room
	unlock_floor(0)

	camera_2d.position.y = 0
	old_camera_2d_position_y = 0
	scroll_enabled = true
	show()
	legendAll.show()

func _clear_map() -> void:
	for child in rooms.get_children():
		child.queue_free()
	for child in lines.get_children():
		child.queue_free()


func _apply_stage_background(stage: int) -> void:
	var paths = STAGE_BACKGROUNDS.get(stage, STAGE_BACKGROUNDS[1])

	var bg = $Background
	if bg:
		var top = bg.get_node_or_null("Top")
		var middle = bg.get_node_or_null("Middle")
		var down = bg.get_node_or_null("Down")
		if top and FileAccess.file_exists(paths["top"]):

			top.texture = load(paths["top"])
		if middle and FileAccess.file_exists(paths["middle"]):
			middle.texture = load(paths["middle"])
		if down and FileAccess.file_exists(paths["bottom"]):
			down.texture = load(paths["bottom"])

	var legend_bg_rect = $Legend_background.get_node_or_null("background") as TextureRect
	if legend_bg_rect and "legend_bg" in paths and FileAccess.file_exists(paths["legend_bg"]):
		legend_bg_rect.texture = load(paths["legend_bg"])



func play_stage_transition(stage: int) -> void:
	if stage <= run_stats.max_stage:
		rebuild_for_stage(run_stats)
		camera_2d.position.y = -camera_edge_y
		old_camera_2d_position_y = 0.0
		show()
		scroll_enabled = false
		_create_act_label(stage)
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(camera_2d, "position:y", 0.0, 2.0)
		await tween.finished

		scroll_enabled = true
	else:
		pass


func _create_act_label(stage: int) -> void:
	# 创建一个专用的 CanvasLayer，确保 UI 始终在相机之上
	var canvas = CanvasLayer.new()
	canvas.layer = 10   # 比 legend 更高，避免被遮挡
	add_child(canvas)

	var label = Label.new()
	label.text = "ACT " + str(stage)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 80)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)  
	label.modulate.a = 0.0  
	canvas.add_child(label)

	var t = create_tween()
	t.tween_property(label, "modulate:a", 1.0, 0.5)
	t.tween_interval(1.5)   # 在全黑背景下显示 1.5 秒（可调整）
	t.tween_property(label, "modulate:a", 0.0, 0.5)
	t.tween_callback(canvas.queue_free)


func _restore_line_visibility() -> void:
	for line in lines.get_children():
		var room_a = line.get_meta("room_a", null)
		var room_b = line.get_meta("room_b", null)
		if room_a and room_b and room_a.selected and room_b.selected:
			line.modulate.a = 0.9
