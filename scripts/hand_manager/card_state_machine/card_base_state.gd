extends CardState

var original_card_position: Vector2

## TODO: tween动画有点混乱

func enter_state() -> void:
	card_ui.reparent_requested.emit(card_ui)
	#card_ui.animate_scale(Vector2.ONE, 0.2)
	#card_ui.tween = create_tween()
	#card_ui.tween.tween_property(card_ui.visuals, "scale", Vector2.ONE, 0.2)
	# 在clicked z_index会设为1以在其他卡上方展示
	card_ui.z_index = 0
	original_card_position = card_ui.position

func on_gui_input(event: InputEvent) -> void:
	if card_ui.disabled:
		return
	if event.is_action_pressed("left_mouse"):
		card_state_machine_change_state_requested.emit(self, STATE.CLICKED)
		

func exit_state() -> void:
	#card_ui.tween = create_tween()
	#card_ui.tween.tween_property(card_ui.visuals, "position:y", original_card_position.y, 1.0).set_trans(Tween.TRANS_SINE)
	#Events.card_previewed.emit(card_ui, false)
	pass
	
func on_mouse_entered() -> void:
	if card_ui.disabled:
		return
	Events.card_previewed.emit(card_ui, true)
	#card_ui.animate_start_preview()
	#card_ui.tween.kill()
	#card_ui.tween = create_tween()
	#card_ui.tween.set_parallel(true)
	#card_ui.tween.tween_property(card_ui.visuals, "position:y", original_visual_position.y - 150, 0.2).set_trans(Tween.TRANS_SINE)
	#card_ui.tween.tween_property(card_ui.visuals, "scale", Vector2(1.3, 1.3), 0.2)
	#card_ui.tween.tween_property(card_ui, "rotation_degrees", 0, 0.2).set_trans(Tween.TRANS_SINE)

func on_mouse_exited() -> void:
	if card_ui.disabled:
		return
	Events.card_previewed.emit(card_ui, false)
	#card_ui.animate_end_preview()
	#card_ui.tween.kill()
	#card_ui.tween = create_tween()
	#card_ui.tween.set_parallel(true)
	#card_ui.tween.tween_property(card_ui.visuals, "position:y", original_visual_position.y, 0.2).set_trans(Tween.TRANS_SINE)
	#card_ui.tween.tween_property(card_ui.visuals, "scale", Vector2.ONE, 0.2)
	#card_ui.tween.tween_property(card_ui, "rotation_degrees", card_ui.original_rotation, 0.2).set_trans(Tween.TRANS_SINE)
