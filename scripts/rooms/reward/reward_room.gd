extends Control


func _on_button_pressed() -> void:
	Events.combat_reward_exited.emit()
