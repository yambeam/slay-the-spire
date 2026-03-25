class_name CardUI
extends Control


@export var card: Card: set = _set_card
@export var char_stats: CharacterStats: set = _set_char_stats

@onready var drop_point_area: Area2D = $DropPointArea
@onready var card_state_machine: CardStateMachine = $CardStateMachine
@onready var visuals: Control = $Visuals

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

func play() -> void:
	if not card:
		return
	card.play(Context.new(get_tree().get_first_node_in_group("ui_player"), targets, 0), char_stats)
	# TODO: 在删除前做出消耗/去弃牌堆的动画
	queue_free()
	
func animate_to_position(new_position: Vector2, duration: float) -> void:
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	movement_tween.tween_property(self, "global_position", new_position, duration)

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

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	visuals.card = value

func _set_playable(value: bool) -> void:
	playable = value
	# TODO:改变卡牌外观

func _set_disabled(value: bool) -> void:
	disabled = value
	

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()
	Events.tooltip_show_request.emit(self)
	if card.target == card.Target.SELF or card.target == card.Target.SINGLE_ENEMY:
		set_description(get_tree().get_first_node_in_group("ui_player"), null)
	elif card.target == card.Target.EVERYONE or card.target == card.Target.ALL_ENEMIES:
		set_description(get_tree().get_first_node_in_group("ui_player"), get_tree().get_first_node_in_group("ui_enemies"))
	
func show_keyword_tooltip() -> void:
	var keywords = KeywordTooltip.extract_keyword(card.description)
	if keywords.is_empty():
		return
	for keyword:String in keywords:
		var keyword_name: String = BuffLibrary.get_keyword_name(keyword)
		var desc: String = BuffLibrary.get_keyword_description(keyword)
		KeywordTooltip.add_keyword(keyword_name, desc)
	# preview时会scale到1.3，同时向上移动175px(显示tooltip需要0.2s,此时tween已经完成)
	KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 1.4, 0)
	KeywordTooltip.show()

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()
	Events.tooltip_hide_request.emit()
	
func _on_card_click_or_drag_or_aiming_started(card_ui: CardUI) -> void:
	if card_ui == self:
		return
	disabled = true
		
func _on_card_click_or_drag_or_aiming_ended(_card_ui: CardUI) -> void:
	disabled = false
	self.playable = char_stats.can_play_card(card)

func set_description(source_: Creature, target_: Creature) -> void:
	visuals.set_description(card.get_description(source_, target_))

func _on_drop_point_area_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_area_area_exited(area: Area2D) -> void:
	targets.erase(area)

func _on_char_stats_changed() -> void:
	self.playable = char_stats.can_play_card(card)

func _on_target_selected(target: Creature) -> void:
	set_description(get_tree().get_first_node_in_group("ui_player"), target)
	
func _on_target_unselected() -> void:
	set_description(get_tree().get_first_node_in_group("ui_player"), null)
