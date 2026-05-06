class_name HandManager
extends Control

const CARD_UI = preload("res://scenes/rooms/combat_room/combat_ui/card_ui.tscn")

@export var char_stats: CharacterStats

@export var height_curve: Curve
@export var rotation_curve: Curve

@export var max_rotation: float
@export var max_height: int
@export var max_cards_amount: int
@export var offset: int
@export var tween_time: float
@export var max_width: Vector2

func _ready() -> void:
	Events.card_previewed.connect(_on_card_previewed)
	Events.card_drag_started.connect(
	func(_card_ui): set_cards() 
		)

func add_cards_for_selection(card:Card) -> CardUI:
	var new_card_ui: CardUI = CARD_UI.instantiate()
	add_child(new_card_ui)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.char_stats = char_stats
	return new_card_ui

func add_card(card: Card) -> bool:
	if get_child_count() >= 10:
		char_stats.draw_pile.add_card(card)
		return false
	var new_card_ui :CardUI = CARD_UI.instantiate()
	add_child(new_card_ui)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.char_stats = char_stats
	return true

## 使手牌扇形排列
func set_cards(instant: bool = false) -> void: 
	var card_count := get_child_count()
	var card_uis := get_children()
	
	if card_count == 0:
		return 
	elif card_count == 1:
		var tween := create_tween()
		var card_ui: CardUI = card_uis[0]
		card_ui.original_position = max_width / 2
		card_ui.original_position.y -= max_height
		card_ui.original_rotation = 0.0;
		tween.set_parallel(true)
		tween.tween_property(card_ui, "position", card_ui.original_position, tween_time)
		tween.tween_property(card_ui, "rotation_degrees", card_ui.original_rotation, tween_time)
	else:
		var target_position: Vector2
		var target_rotation: float
		var x_position := 0.0
		var x_rotation := 0.0
		var card_ui: CardUI
		for card_index in card_count:
			card_ui = card_uis[card_index]
			# !godot中两个操作数都是整数时执行整数除法
			# 卡牌超出上限时不预留卡牌之间的空间(一般不会出现这种情况
			if card_count > max_cards_amount:
				x_position = float(card_index) / float(card_count)
				x_rotation = float(card_index) / float(card_count - 1)
			else:
				var occupy := float(card_count) / float(max_cards_amount)
				var begin := (1.0 - occupy) / 2
				x_position = float(card_index) / float(card_count) * occupy + begin
				x_rotation = float(card_index) / float(card_count - 1) * occupy + begin
			target_position = max_width * x_position
			target_position.y -= height_curve.sample(x_rotation) * max_height
			target_rotation = rotation_curve.sample(x_rotation) * max_rotation
			card_ui.original_position = target_position
			card_ui.original_rotation = target_rotation
			card_ui.original_index = card_index	
			if instant:
				card_ui.position = target_position
				card_ui.rotation_degrees = target_rotation
			else:
				card_ui.animate_set_card(target_position, target_rotation, tween_time)
			
func _on_card_previewed(pre_card: CardUI, to_preview: bool) -> void:
	if to_preview:
		pre_card.z_index = 1
	else:
		pre_card.z_index = 0
	# to_preview = true时周围卡牌散开，=false复原
	var card_count := get_child_count()
	if card_count == 1:
		pre_card.animate_preview(pre_card.original_position.x, 1.3, 0, to_preview, tween_time)
	if pre_card:
		var element :int = to_preview as int
		for card_ui: CardUI in get_children():
			var movement: float
			var delta = card_ui.original_index - pre_card.original_index
			if abs(delta) > 3:
				movement = 0
			else:
				movement = sign(delta) * (4 - abs(delta)) * element * offset
			#card_ui.animate_to_position(card_ui.original_position + Vector2(movement, 0), tween_time)
			#var tween := get_tree().create_tween()
			#tween.set_parallel(true)
			#tween.tween_property(card_ui, "position:x", card_ui.original_position.x + movement, tween_time)
			if card_ui == pre_card:
				card_ui.animate_preview(card_ui.original_position.x, 1.3, 0, to_preview, tween_time)
			else:
				card_ui.animate_preview(card_ui.original_position.x + movement, 1.3, 0, false, tween_time)
			#card_ui.animate_to_position(card_ui.original_position + Vector2(movement, 0), tween_time)
			
			#card_ui.movement_tween = create_tween()
			#card_ui.movement_tween.tween_property(card_ui, "position:x", card_ui.original_position.x + movement, tween_time)

# TODO: 卡牌消耗/移向弃牌堆动画
func discard_card(card: CardUI) -> void:
	# 从手牌中移出时去掉本回合打出免费的标记
	card.card.first_play_free = false
	card.discarded = true
	Events.card_discarded.emit(card)
	set_cards()
	
func exhaust_card(card: CardUI) -> void:
	Events.card_exhausted.emit(card.card)
	card.queue_free()
	# 等待card.queue_free()
	await get_tree().process_frame
	set_cards()

func find_card_ui(card: Card) -> CardUI:
	for child: CardUI in get_children():
		if child.card == card:
			return child
	return null

func discard_hand() -> void:
	for child: CardUI in get_children():
		child.card.first_play_free = false
		Events.card_discarded.emit(child)

func disable_hand() -> void:
	for card_ui: CardUI in get_children():
		card_ui.disabled = true

func _on_card_ui_reparent_requested(card_ui:CardUI) -> void:
	if card_ui:
		card_ui.disabled = true
		card_ui.reparent(self)
		move_child.call_deferred(card_ui, card_ui.original_index)
		card_ui.set_deferred("disabled", false)
		set_cards.call_deferred()

func update_hand() -> void:
	for child: CardUI in get_children():
		child.set_card(child.card)
		
