class_name CreatureVisuals
extends Node2D

@onready var visuals: SpineManager = $Visuals
@onready var bounds: Control = $Bounds
@onready var intent_point: Marker2D = $IntentPoint
@onready var speech_point: Marker2D = $SpeechPoint

func get_size() -> Vector2:
	return bounds.size

func get_center_point() -> Vector2:
	return bounds.position + bounds.size / 2
	
func get_intent_point() -> Vector2:
	return intent_point.position

func get_spine_manager() -> SpineManager:
	return visuals

func get_visual_scale() -> Vector2:
	return visuals.scale
