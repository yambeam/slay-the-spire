class_name BesselArrow
extends Node2D

@export var factor1: float
@export var factor2: float
@export var factor3: float
@export var factor4: float
@export var arrow_count: int
@export var arrow_scale_factor: float
@export var arrow_min_scale: float

#箭头和箭身
const TARGETING_ARROW_HEAD = preload("res://images/ui/combat/targeting_arrow_head.png")
const TARGETING_ARROW_SEGMENT = preload("res://images/ui/combat/targeting_arrow_segment.png")

var arrow_array: Array[Sprite2D] = []

func _ready() -> void:
	var sprite: Sprite2D
	for i in range(arrow_count - 1):
		sprite = Sprite2D.new()
		arrow_array.append(sprite)
		sprite.texture = TARGETING_ARROW_SEGMENT
		sprite.offset = Vector2(0, 74)
		sprite.scale = Vector2.ONE * (i as float / arrow_count * arrow_scale_factor + arrow_min_scale)
		add_child(sprite)
	sprite = Sprite2D.new()
	arrow_array.append(sprite)
	sprite.texture = TARGETING_ARROW_HEAD
	sprite.offset = Vector2(0, 101.5) # 箭头的高为203px
	sprite.scale = Vector2.ONE * arrow_scale_factor
	add_child(sprite)
	
		

func reset(start_pos: Vector2, end_pos: Vector2) -> void:
	var mid_point_a : Vector2
	var mid_point_b : Vector2
	mid_point_a.x = start_pos.x + (start_pos.x - end_pos.x) * factor1 
	mid_point_a.y = end_pos.y - (end_pos.y - start_pos.y) * factor2
	mid_point_b.x = start_pos.y - (start_pos.x - end_pos.x) * factor3
	mid_point_b.y = end_pos.y + (end_pos.y - start_pos.y) * factor4
	
	for i in range(arrow_count):
		var t := float(i) / (arrow_count - 1)
		arrow_array[i].position = start_pos.bezier_interpolate(mid_point_a, mid_point_b, end_pos, t)
		#var pos = start_pos * pow((1 - t), 3) + 3 * mid_point_a * t * pow((1 - t), 2) + 3 * mid_point_b * pow(t, 2) * (1 - t) + end_pos * pow(t, 3)
		#arrow_array[i].position = pos
	#_update_angle(start_pos, end_pos)
	for i in range(arrow_count):
		if i == 0:
			arrow_array[i].rotation_degrees = 0
		else:
			var t := float(i) / (arrow_count - 1)
			arrow_array[i].rotation = start_pos.bezier_derivative(mid_point_a, mid_point_b, end_pos, t).angle() + PI / 2

func highlight() -> void:
	pass

func unhightlight() -> void:
	pass
	
var vector: Vector2
func _update_angle(start_pos: Vector2, end_pos: Vector2):
	for i in range(arrow_count):
		if i == 0:
			arrow_array[0].rotation_degrees = 0
		else:
			var current_segment = arrow_array[i]
			var last_segment = arrow_array[i - 1]
			var len_vec: Vector2 = current_segment.position - last_segment.position
			current_segment.rotation = len_vec.angle()
			
		
