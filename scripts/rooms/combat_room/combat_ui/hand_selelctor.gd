class_name HandSelector
extends ColorRect

signal card_selected(card: Array[Card])

@onready var peak_button: TextureButton = $PeakButton
@onready var hint_label: Label = $HintLabel
@onready var hand_manager: HandManager = $HandManager
@onready var selected_cards_container: HBoxContainer = $SelectedCardsContainer
@onready var comfirm_button: ComfirmButton = $ComfirmButton
@onready var cancel_button: ComfirmButton = $CancelButton

var current_mode: Enums.SelectionMode = Enums.SelectionMode.NONE
var max_select := 10
var min_select := 0
var selected_cards: Array[Card] = []
var cards_list: Array[CardUI] = []
@export var cards: Array[Card]
func _ready() -> void:
	comfirm_button.pressed.connect(_on_comfirm)
	cancel_button.pressed.connect(_on_cancel)
	comfirm_button.hide()
	cancel_button.hide()
	
func single_select(cards_to_choose: Array[Card], title: String) -> Array[Card]:
	#return await _start_selection(cards_to_choose, title, Enums.SelectionMode.SINGLE)
	max_select = 1
	min_select = 1
	return await _start_selection(cards_to_choose, title, Enums.SelectionMode.MULTI)

func multi_select(cards_to_choose: Array[Card], title: String, min_: int = 0, max_: int = 10) -> Array[Card]:
	max_select = max_
	min_select = min_
	var ret = await _start_selection(cards_to_choose, title, Enums.SelectionMode.MULTI)
	return ret
	
func _start_selection(cards_to_choose: Array[Card], title: String, mode: Enums.SelectionMode) -> Array[Card]:
	current_mode = mode
	# 需要复制吗？
	#cards_list = cards.duplicate()
	selected_cards.clear()
	for child in selected_cards_container.get_children():
		child.queue_free()
	for child in hand_manager.get_children():
		child.queue_free()
	for card: Card in cards_to_choose:
		var card_ui: CardUI = hand_manager.add_cards_for_selection(card)
		if mode == Enums.SelectionMode.SINGLE:
			card_ui.selection_mode = mode
		elif mode == Enums.SelectionMode.MULTI:
			card_ui.selection_mode = mode
		else:
			printerr("hand_selector")	
		card_ui.toggled.connect(_on_card_toggled)
	# 等待节点删除
	await get_tree().process_frame
	hand_manager.set_cards(true)
	hint_label.text = title
	show()
	var ret: Array[Card]
	ret = await card_selected
	hide()
	return ret

func _on_card_toggled(card_ui: CardUI) -> void:
	var length = len(selected_cards)
	if card_ui.card in selected_cards:
		selected_cards.erase(card_ui.card)
		cancel_button.visible = (length - 1 != 0)
		for child: CardUI in selected_cards_container.get_children():
			if card_ui == child:
				child.reparent_requested.emit(child)
				child.disabled = false
				break
	else:
		if length >= max_select:
			return
		selected_cards.append(card_ui.card)
		comfirm_button.visible = length + 1 >= min_select
		cancel_button.visible = true
		if card_ui.movement_tween:
			card_ui.movement_tween.kill()
		if card_ui.tween:
			card_ui.tween.kill()
		card_ui.position = Vector2.ZERO
		card_ui.disabled = true
		card_ui.z_index = 0
		card_ui.reparent(selected_cards_container)
		# 卡牌顺序没什么意义，干脆直接放在尾部
		card_ui.original_index = -1
		hand_manager.set_cards()
		
func _on_cancel() -> void:
	selected_cards.clear()
	for child: CardUI in selected_cards_container.get_children():
		child.reparent_requested.emit(child)
		child.disabled = false
	cancel_button.visible = false

func _on_comfirm() -> void:
	card_selected.emit(selected_cards)
