extends Control


func _on_button_pressed() -> void:
	Events.incident_exited.emit()
