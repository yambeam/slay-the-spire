extends CardState

func enter_state() -> void:
	if card_ui.movement_tween:
		card_ui.movement_tween.kill()
	card_ui.drop_point_area.monitoring = true
	card_ui.original_index = card_ui.get_index()
	Events.card_click_started.emit(card_ui)

func exit_state() -> void:
	Events.card_click_ended.emit(card_ui)
	
func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		card_state_machine_change_state_requested.emit(self, STATE.DRAGGING)
