extends CardState

const DRAG_MININUM_THRESHHOLD := 0.05
var minimum_drag_time_elapsed := false
var offset : Vector2

func enter_state() -> void:
	var ui_layer := get_tree().get_first_node_in_group("ui_layer")
	if ui_layer:
		card_ui.reparent(ui_layer)
	#offset = card_ui.get_global_mouse_position() - card_ui.position
	offset = card_ui.size / 2
	Events.card_drag_started.emit(card_ui)
	minimum_drag_time_elapsed = false
	var threshhold_timer := get_tree().create_timer(DRAG_MININUM_THRESHHOLD, false)
	threshhold_timer.timeout.connect(
		func(): minimum_drag_time_elapsed = true
	)

func exit_state() -> void:
	# 已知bug:在选择卡牌到瞄准的瞬间可能触发其他卡牌的preview
	# 可能原因: dragging->aiming中间释放了card_drag_ended
	# 导致卡牌一瞬间disabled被设置为false,与其他卡牌进行互动
	Events.card_drag_ended.emit(card_ui)

func on_input(event: InputEvent) -> void:
	var single_targetd := card_ui.card.is_single_targeted()
	var mouse_motion := event is InputEventMouseMotion
	var cancel := event.is_action_pressed("right_mouse")
	# 点击后再点击释放，拖拽后释放
	var comfirm := event.is_action_pressed("left_mouse") or event.is_action_released("left_mouse")
	
	if not card_ui.playable:
		card_state_machine_change_state_requested.emit(self, STATE.BASE)
		Events.player_talked.emit("没有足够的能量", 2.5)
		return
	
	if single_targetd and mouse_motion and card_ui.targets.size() > 0:
		card_state_machine_change_state_requested.emit(self, STATE.AIMING)
		return
	
	if mouse_motion:
		card_ui.position = card_ui.get_global_mouse_position() - offset
	elif cancel:
		card_state_machine_change_state_requested.emit(self, STATE.BASE)
	elif minimum_drag_time_elapsed and comfirm and not single_targetd:
		get_viewport().set_input_as_handled()
		card_state_machine_change_state_requested.emit(self, STATE.RELEASED)
