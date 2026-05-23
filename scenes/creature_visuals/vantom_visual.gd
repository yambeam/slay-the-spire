class_name VantomVisuals
extends CreatureVisuals

@onready var mega_tail: SpineBoneNode = $Visuals/MegaTail
var tail_tween: Tween
var scale_tween: Tween
var normal_scale: = Vector2(0.20, 0.20)
@onready var mega_tail_point: Marker2D = $MegaTailPoint

func show_mega_tail(self_global_position: Vector2, player_global_position: Vector2) -> void:
	if tail_tween:
		tail_tween.kill()
	tail_tween = create_tween()
	tail_tween.tween_property(mega_tail, "position", Vector2(-self_global_position.x + player_global_position.x - mega_tail_point.position.x + 500, 600), 2.0)

func hide_mega_tail() -> void:
	if tail_tween:
		tail_tween.kill()
	tail_tween = create_tween()
	tail_tween.tween_property(mega_tail, "position:y", -1600, 2.0)
	await tail_tween.finished

func heavy_attack_down() -> void:
	if tail_tween:
		tail_tween.kill()
	tail_tween = create_tween()
	tail_tween.tween_property(mega_tail, "position:y", 1500, 0.1)
	tail_tween.tween_property(mega_tail, "position:y", -1600, 0.3)
	await tail_tween.finished

func scale_up() -> void:
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(visuals, "scale", visuals.scale + Vector2(0.07, 0.07), 0.3)
	
func scale_back() -> void:
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(visuals, "scale", normal_scale, 0.3)
	await scale_tween.finished
	
