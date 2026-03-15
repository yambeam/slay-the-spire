extends CardState

func enter_state() -> void:
	card_ui.drop_point_area.monitoring = true
	card_ui.original_index = card_ui.get_index()
	
func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		card_state_machine_change_state_requested.emit(self, STATE.DRAGGING)
