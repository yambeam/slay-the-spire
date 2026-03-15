extends CardState

var played := false

func enter_state() -> void:
	played = false
	if not card_ui.targets.is_empty():
		played = true
		card_ui.play()

func on_input(_event: InputEvent) -> void:
	if played:
		return
	card_state_machine_change_state_requested.emit(self, STATE.BASE)
	
