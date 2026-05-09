class_name Settings
extends Control

signal settings_exited






func _on_button_pressed() -> void:
	settings_exited.emit()

	
