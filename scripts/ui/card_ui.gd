class_name CardUI
extends Control

@export var card: Card: set = _set_card
# 暂时
@export var char_stats: CharacterStats: set = _set_char_stats

@onready var drop_point_area: Area2D = $DropPointArea
@onready var card_state_machine: CardStateMachine = $CardStateMachine
@onready var visuals: Control = $Visuals
@onready var card_portrait: TextureRect = %CardPortrait
@onready var card_frame: TextureRect = %CardFrame
@onready var title_label: Label = %TitleLabel
@onready var energy_label: Label = %EnergyLabel
@onready var type_label: Label = %TypeLabel

var disabled: bool = false : set = _set_playable
var playable: bool = true

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
	Events.card_aim_started.connect(_on_card_drag_or_aiming_started)
	Events.card_aim_ended.connect(_on_card_drag_or_aiming_ended)
	Events.card_drag_started.connect(_on_card_drag_or_aiming_started)
	Events.card_drag_ended.connect(_on_card_drag_or_aiming_ended)
	card_state_machine.init()

func play() -> void:
	if not card:
		return
	card.play(targets, char_stats)
	# TODO: 在删除前做出消耗/去弃牌堆的动画
	queue_free()
	
func animate_to_position(new_position: Vector2, duration: float) -> void:
	movement_tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	movement_tween.tween_property(self, "global_position", new_position, duration)

func animate_start_preview() -> void:
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	movement_tween = create_tween().set_trans(Tween.TRANS_SINE)
	movement_tween.tween_property(self, "position:y", original_position.y - 175, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "rotation_degrees", 0, 0.1).set_trans(Tween.TRANS_SINE)

func animate_end_preview() -> void:
	tween = create_tween().set_trans(Tween.TRANS_SINE).set_parallel(true)
	movement_tween = create_tween().set_trans(Tween.TRANS_SINE)
	movement_tween.tween_property(self, "position:y", original_position.y, 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	tween.tween_property(self, "rotation_degrees", original_rotation, 0.1).set_trans(Tween.TRANS_SINE)

func animate_scale(to: Vector2, duration: float) -> void:
	tween = create_tween()
	tween.tween_property(self, "scale", to, duration)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(_on_char_stats_changed)

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	card_portrait.texture = card.portrait
	title_label.text = card.id
	energy_label.text = str(card.cost)
	var type_text: String
	# TODO: 诅咒，状态
	# TODO: 根据类型修改卡牌外观
	match card.type:
		card.Type.ATTACK:
			type_text = "攻击"
		card.Type.SKILL:
			type_text = "技能"
		card.Type.POWER:
			type_text = "能力"
		_:
			type_text = "出错"
			
	type_label.text = type_text

func _set_playable(value: bool) -> void:
	playable = value
	# TODO:改变卡牌外观


func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()

func _on_card_drag_or_aiming_started(card_ui: CardUI) -> void:
		if card_ui == self:
			return
		disabled = true
		
func _on_card_drag_or_aiming_ended(_card_ui: CardUI) -> void:
	disabled = false
	self.playable = char_stats.can_play_card(card)

func _on_drop_point_area_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_area_area_exited(area: Area2D) -> void:
	targets.erase(area)

func _on_char_stats_changed() -> void:
	self.playable = char_stats.can_play_card(card)
