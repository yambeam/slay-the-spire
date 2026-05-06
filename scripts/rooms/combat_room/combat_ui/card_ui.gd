class_name CardUI
extends Control

# 处理选择卡牌逻辑
signal toggled(card: CardUI)

@export var card: Card: set = set_card
@export var char_stats: CharacterStats: set = _set_char_stats

@onready var drop_point_area: Area2D = $DropPointArea
@onready var card_state_machine: CardStateMachine = $CardStateMachine
@onready var visuals: CardVisuals = $Visuals

var disabled: bool = false : set = _set_disabled
var playable: bool = true : set = _set_playable

var targets: Array[Node]

var original_index: int = -1
var original_position: Vector2
var original_rotation: float

var parent : Control
var tween: Tween
# 专门负责移动的tween
var movement_tween: Tween
# 选择状态

var selection_mode: Enums.SelectionMode = Enums.SelectionMode.NONE

# 玩家(不考虑多人
var player: Player

# 在dragging/aiming下，卡牌会脱离handmanger
@warning_ignore("unused_signal")
signal reparent_requested(card_ui: CardUI)

func _ready() -> void:
	Events.card_aim_started.connect(_on_card_click_or_drag_or_aiming_started)
	Events.card_aim_ended.connect(_on_card_click_or_drag_or_aiming_ended)
	Events.card_click_started.connect(_on_card_click_or_drag_or_aiming_started)
	Events.card_click_ended.connect(_on_card_click_or_drag_or_aiming_ended)
	Events.card_drag_started.connect(_on_card_click_or_drag_or_aiming_started)
	Events.card_drag_ended.connect(_on_card_click_or_drag_or_aiming_ended)
	Events.target_selected.connect(_on_target_selected)
	Events.target_unselected.connect(_on_target_unselected)
	
	card_state_machine.init()
	player = get_tree().get_first_node_in_group("ui_player")
	Events.card_played.connect(func(_card: Card, _card_context: Dictionary): visuals.set_hightlight(playable, card.has_highlight_condition(player, null)))

func play() -> void:
	if not card:
		return
	card.play(get_tree().get_first_node_in_group("ui_player"), targets)
	# TODO: 在删除前做出消耗/去弃牌堆的动画
	queue_free()

func animate_reset() -> void:
	if tween:
		tween.kill()
	if movement_tween:
		movement_tween.kill()
	self.rotation_degrees = 0
	self.scale = Vector2.ONE
	self.position = original_position
	
func animate_set_card(target_position: Vector2, target_rotation_degrees: float, duration: float) -> void:
	if movement_tween:
		movement_tween.kill()
	disabled = true
	movement_tween = create_tween().set_parallel(true)
	movement_tween.tween_property(self, "position", target_position, duration)
	movement_tween.tween_property(self, "rotation_degrees", target_rotation_degrees, duration)
	movement_tween.finished.connect(func(): disabled = false)
		
func animate_to_position(new_position: Vector2, duration: float) -> void:
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	movement_tween.tween_property(self, "position", new_position, duration)

func animate_preview(new_position_x, new_scale, new_rotation, to_preview, tween_time) -> void:
	if movement_tween:
		movement_tween.kill()
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	movement_tween = create_tween().set_trans(Tween.TRANS_SINE)
	if to_preview:
		movement_tween.tween_property(self, "position", Vector2(new_position_x, original_position.y - 175), tween_time)
		tween.tween_property(self, "scale", Vector2(new_scale, new_scale), tween_time)
		tween.tween_property(self, "rotation_degrees", new_rotation, tween_time)
	else:
		movement_tween.tween_property(self, "position", Vector2(new_position_x, original_position.y), tween_time)
		tween.tween_property(self, "scale", Vector2.ONE, tween_time)
		tween.tween_property(self, "rotation_degrees", original_rotation, tween_time)

# 弃用
func animate_start_preview() -> void:
	if movement_tween:
		movement_tween.kill()
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	movement_tween = create_tween().set_trans(Tween.TRANS_SINE)
	movement_tween.tween_property(self, "position:y", original_position.y - 175, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "rotation_degrees", 0, 0.1).set_trans(Tween.TRANS_SINE)
# 弃用
func animate_end_preview() -> void:
	if movement_tween:
		movement_tween.kill()
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	movement_tween = create_tween().set_trans(Tween.TRANS_SINE)
	movement_tween.tween_property(self, "position:y", original_position.y, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	tween.tween_property(self, "rotation_degrees", original_rotation, 0.1).set_trans(Tween.TRANS_SINE)

func animate_scale(to: Vector2, duration: float) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", to, duration)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(_on_char_stats_changed)
	_on_char_stats_changed()

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	visuals.card = value
	if char_stats:
		visuals.set_hightlight(playable, card.has_highlight_condition(player, null))

func _set_playable(value: bool) -> void:
	if card.playable:
		playable = value
		visuals.set_hightlight(playable, card.has_highlight_condition(player, null))

func _set_disabled(value: bool) -> void:
	disabled = value
		
func _input(event: InputEvent) -> void:
	if disabled:
		return
	if selection_mode == Enums.SelectionMode.NONE:
		card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	if selection_mode == Enums.SelectionMode.NONE and not disabled:
		card_state_machine.on_gui_input(event)
	elif selection_mode != Enums.SelectionMode.NONE and (event.is_action_pressed("left_mouse") or event.is_action_pressed("right_mouse")):
		toggled.emit(self)
	

func _on_mouse_entered() -> void:
	if disabled: 
		return
	if selection_mode == Enums.SelectionMode.NONE:
		card_state_machine.on_mouse_entered()
		if card.get_target() == card.Target.SELF or card.get_target() == card.Target.SINGLE_ENEMY:
			set_description(get_tree().get_first_node_in_group("ui_player"), null)
		elif card.get_target() == card.Target.EVERYONE or card.get_target() == card.Target.ALL_ENEMIES:
			set_description(get_tree().get_first_node_in_group("ui_player"), get_tree().get_first_node_in_group("ui_enemies"))
	else:
		Events.card_previewed.emit(self, true)
		animate_start_preview()
	Events.tooltip_show_request.emit(self, show_keyword_tooltip)
	
func show_keyword_tooltip() -> void:
	var keywords = KeywordTooltip.extract_keyword(card.get_default_description())
	
	if card.has_enchantment():
		KeywordTooltip.add_keyword(card.enchantment.enchantment_name, card.enchantment.get_description())
	
	for keyword:String in keywords:
		var keyword_name: String = BuffLibrary.get_keyword_name(keyword)
		var desc: String = BuffLibrary.get_keyword_description(keyword)
		KeywordTooltip.add_keyword(keyword_name, desc)
	# preview时会scale到1.3，同时向上移动175px(显示tooltip需要0.2s,此时tween已经完成)
	KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 1.4, 0)
	KeywordTooltip.show()

func _on_mouse_exited() -> void:
	if disabled:
		return
	if selection_mode == Enums.SelectionMode.NONE:
		card_state_machine.on_mouse_exited()
	else:
		Events.card_previewed.emit(self, false)
		animate_end_preview()
	Events.tooltip_hide_request.emit()
	
func _on_card_click_or_drag_or_aiming_started(card_ui: CardUI) -> void:
	if card_ui == self:
		return
	disabled = true
		
func _on_card_click_or_drag_or_aiming_ended(_card_ui: CardUI) -> void:
	disabled = false
	playable = char_stats.can_play_card(card)

func set_description(source_: Creature, target_: Creature) -> void:
	if selection_mode == Enums.SelectionMode.NONE:
		visuals.set_description(card.get_description(source_, target_))
	else:
		visuals.set_description(card.get_default_description())

func _on_drop_point_area_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_area_area_exited(area: Area2D) -> void:
	targets.erase(area)

func _on_char_stats_changed() -> void:
	playable = char_stats.can_play_card(card)
	#visuals.set_hightlight(self.playable, card.has_highlight_condition(player, null))

func _on_target_selected(target: Creature, card_: Card) -> void:
	# 如果更改目标的卡牌不是自身，不修改描述
	if card_ == card:
		set_description(get_tree().get_first_node_in_group("ui_player"), target)
		visuals.set_hightlight(playable, card.has_highlight_condition(player, target))
	
func _on_target_unselected(card_) -> void:
	if card_ == card:
		set_description(get_tree().get_first_node_in_group("ui_player"), null)
		visuals.set_hightlight(playable, card.has_highlight_condition(player, null))
