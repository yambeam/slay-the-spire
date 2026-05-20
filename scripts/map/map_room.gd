class_name MapRoom
extends Area2D

const COLLISION_SCALE := 0.7

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal selected(room: Room)

var ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.MONSTER: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/icons/map_monster.tres"), Vector2.ONE],
	Room.Type.TREASURE: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/icons/map_chest.tres"), Vector2.ONE],
	Room.Type.CAMPFIRE: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/icons/map_rest.tres"), Vector2(0.6, 0.6)],
	Room.Type.SHOP: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/icons/map_shop.tres"), Vector2(0.6, 0.6)],
	# todo vantom.tres
	Room.Type.BOSS: {
		"vantom": [preload("res://images/map/placeholder/vantom_boss_icon.png"), Vector2(1.25, 1.25)],
		"lagavulin_matriarch":[preload("res://images/map/placeholder/lagavulin_matriarch_boss_icon.png"), Vector2(1.25, 1.25)],
		"knowledge_demon": [preload("res://images/map/placeholder/knowledge_demon_boss_icon.png"), Vector2(1.25, 1.25)]   # 你的新图标
	},
	Room.Type.ANCIENT: {
		1: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/ancients/ancient_node_neow.tres"), Vector2.ONE],
		2: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/ancients/ancient_node_orobas.tres"), Vector2.ONE]   # 奥罗巴斯图标
	},
	Room.Type.ELITE: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/icons/map_elite.tres"), Vector2.ONE],
	Room.Type.UNKNOWN: [ResourceLoader.load("res://images/atlases/ui_atlas.sprites/map/icons/map_unknown.tres"), Vector2.ONE],
}

@onready var highlight_sprite: Sprite2D = $Visuals/highlight
@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var Select_Circle: Node2D = $Select_Circle
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var original_modulate: Color
var original_scale: Vector2
var target_alpha := 0.6

func _ready():
	original_modulate = modulate
	original_scale = scale

var available := false : set = set_available
var room : Room : set = set_room

func set_available(new_value: bool) -> void:
	available = new_value
	if available:
		# 古代房不播放 highlight 动画
		if room.type != Room.Type.ANCIENT:
			animation_player.play("highlight")
		if not room.selected:
			sprite_2d.modulate.a = target_alpha
	elif not room.selected:
		if room.type != Room.Type.ANCIENT:
			animation_player.play("RESET")
		sprite_2d.modulate.a = target_alpha

func set_room(new_data: Room) -> void:
	
	room = new_data
	
	position = room.position
	Select_Circle.rotation_degrees = randi_range(0, 360)

	# 获取房间的阶段，默认为1
	var run = _get_run_node()
	
	var stage := 1
	if run and run.stats:
		stage = run.stats.current_stage
	
	var type_data
	# 从 ICONS 字典中取出对应类型的图标数据
	if room.type == Room.Type.BOSS:
		match room.enemy_encounter.encounter_name:
			"vantom":
				type_data = ICONS[room.type]["vantom"]
			"lagavulin_matriarch":
				type_data = ICONS[room.type]["lagavulin_matriarch"]
			"knowledge_demon":
				type_data = ICONS[room.type]["knowledge_demon"]
			_:
				type_data = ICONS[room.type]["vantom"]
	else:
		type_data = ICONS[room.type]
	var entry: Array

	# 判断是数组（单一阶段）还是字典（多阶段）
	if typeof(type_data) == TYPE_ARRAY:
		entry = type_data
	else:  # 字典，根据 stage 选择
		entry = type_data.get(stage, type_data.get(1, [null, Vector2.ONE]))

	sprite_2d.texture = entry[0]
	sprite_2d.scale = entry[1]
	original_scale = scale

	# 古代房始终保持完全不透明
	if room.selected or room.type == Room.Type.ANCIENT:
		target_alpha = 1.0
	else:
		target_alpha = 0.6
	sprite_2d.modulate.a = target_alpha

	# 控制选中圆圈的显示（古代房和Boss房永远不显示圆圈）
	if room.type == Room.Type.ANCIENT or room.type == Room.Type.BOSS:
		Select_Circle.modulate.a = 0.0
		for child in Select_Circle.get_children():
			child.modulate.a = 0.0
	else:
		# 普通房间的圆圈透明度由 selected 状态决定
		if room.selected:
			Select_Circle.modulate.a = 1.0
			for child in Select_Circle.get_children():
				child.modulate.a = 1.0
		else:
			Select_Circle.modulate.a = 0.0
			for child in Select_Circle.get_children():
				child.modulate.a = 0.0

	# 如果房间已经被选中，停止可能残余的动画
	if room.selected and animation_player and animation_player.is_playing():
		animation_player.stop()
	#print("Room type: ", Room.Type.keys()[room.type], " texture: ", entry[0]) 
		
		
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_mouse"):
		return

	room.selected = true
	target_alpha = 1.0
	sprite_2d.modulate.a = target_alpha

	# 古代房与 Boss 房：直接发射信号，不播放 select 动画
	if room.type == Room.Type.ANCIENT or room.type == Room.Type.BOSS:
		selected.emit(room)
	else:
		Select_Circle.modulate.a = 1.0 
		animation_player.speed_scale = 2.0
		animation_player.play("select")

# 正常房间的 select 动画结束后回调
func _on_map_room_selected() -> void:
	
	selected.emit(room)

func set_highlight(highlight: bool):
	# 古代房与 Boss 房不参与高亮
	if room.type == Room.Type.ANCIENT or room.type == Room.Type.BOSS:
		return

	if highlight:
		sprite_2d.modulate.a = 1.0
		modulate = Color(1, 1, 0.5, 1.0)
		if room.type == Room.Type.UNKNOWN:
			highlight_sprite.modulate.a = 1.0
		if room.type == Room.Type.ELITE or room.type == Room.Type.MONSTER:
			scale = original_scale * 1.5
		else:
			scale = original_scale * 1.2
	else:
		sprite_2d.modulate.a = target_alpha
		modulate = Color.WHITE
		scale = original_scale
		highlight_sprite.modulate.a = 0.0
	#_update_collision_scale()

func show_selected() -> void:
	# 如果节点还未初始化，直接返回
	if not sprite_2d:
		return
	
	# 图标完全不透明
	sprite_2d.modulate.a = 1.0
	target_alpha = 1.0
	
	# 古代房和 Boss 房不显示 Select_Circle（保持透明）
	if room.type == Room.Type.ANCIENT or room.type == Room.Type.BOSS:
		Select_Circle.modulate.a = 0.0
		for child in Select_Circle.get_children():
			child.modulate.a = 0.0
	else:
		# 其他房间显示圆圈
		Select_Circle.modulate.a = 1.0
		for child in Select_Circle.get_children():
			child.modulate.a = 1.0
	
	# 停止可能残余的动画
	if animation_player and animation_player.is_playing():
		animation_player.stop()

func _update_collision_scale() -> void:
	if scale.x == 0 or scale.y == 0:
		return
	collision_shape.scale = Vector2(COLLISION_SCALE/ scale.x, COLLISION_SCALE / scale.y)


func _get_run_node():
	var current = self
	while current:
		if current is Run:
			return current
		current = current.get_parent()
	return null
