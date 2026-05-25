class_name PotionUI
extends MarginContainer

@onready var out_line: TextureRect = $OutLine
@onready var potion_popup: Control = $PotionPopup
@onready var use_button: TextureButton = $PotionPopup/PotionPopupBackground/UseButton
@onready var discard_button: TextureButton = $PotionPopup/PotionPopupBackground/DiscardButton
@onready var potion_button: TextureButton = $PotionButton



const POTION_PLACEHOLDER = preload("res://images/packed/potions/potion_placeholder.png")

var potion: Potion
var targets: Array[Node] = []
var targeting := false
var can_use := false
var used := false

var tween: Tween
# 原位置，为了方便做动画
var original_position

func _ready() -> void:
	#mouse_entered.connect(_on_mouse_entered)
	#mouse_exited.connect(_on_mouse_exited)
	#gui_input.connect(_on_gui_input)
	use_button.pressed.connect(_on_use_button_pressed)
	discard_button.pressed.connect(_on_discard_button_pressed)
	potion_button.pressed.connect(_on_potion_button_pressed)
	potion_button.mouse_entered.connect(_on_mouse_entered)
	potion_button.mouse_exited.connect(_on_mouse_exited)
	

func set_potion(value: Potion):
	original_position = position
	used = false
	if value == null:
		potion = null
		out_line.texture = null
		potion_button.texture_normal = POTION_PLACEHOLDER
	else:
		potion = value
		out_line.texture = value.outline_icon
		potion_button.texture_normal = value.icon

func play() -> void:
	if used:
		return
	used = true
	Events.before_potion_used.emit(self)
	potion.play(get_tree().get_first_node_in_group("ui_player"), targets, self)
	_on_mouse_exited()

func discard() -> void:
	if used:
		return 
	Events.potion_discarded.emit(self)
	_on_mouse_exited()

func set_potion_visible(popup_visible: bool) -> void:
	if popup_visible:
		potion_popup.visible = true
		use_button.disabled = !can_use
	else:
		potion_popup.visible = false
		
func _on_mouse_entered() -> void:
	if can_use:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "position", original_position + Vector2(0, -7), 0.2)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
		tween.chain().tween_property(self, "position", original_position, 0.2)
	Events.tooltip_show_request.emit(self,  _show_keyword_tooltip)
	out_line.show()

func _on_mouse_exited() -> void:
	if can_use:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2.ONE, 0.2)
		tween.tween_property(self, "position", original_position, 0.2)
	Events.tooltip_hide_request.emit()
	out_line.hide()
	
func _on_potion_button_pressed() -> void:
	if potion == null:
		return
	print("test")
	set_potion_visible(!potion_popup.visible)
	#potion_popup.visible = !potion_popup.visible
	
#func _on_gui_input(event: InputEvent) -> void:
	#if not can_use or potion == null:
		#return
	#if event.is_action_pressed("left_mouse"):
		#potion_popup.visible = !potion_popup.visible
	#if event.is_action_pressed("left_mouse"):
		#if potion == null:
			#return
		#if potion.target_type == Potion.TargetType.SELF:
			#targets = get_tree().get_nodes_in_group("ui_player")
			#play()
		#elif potion.target_type == Potion.TargetType.ALL_ENEMY:
			#targets = get_tree().get_nodes_in_group("ui_enemies")
			#play()
		#else:
			#if targeting:
				#_end_aiming()
			#else:
				#_start_aiming()

func _on_use_button_pressed() -> void:
	if not can_use:
		return 
	if potion == null:
		return
	if potion.target_type == Potion.TargetType.SELF:
		targets = get_tree().get_nodes_in_group("ui_player")
		play()
	elif potion.target_type == Potion.TargetType.ALL_ENEMY:
		targets = get_tree().get_nodes_in_group("ui_enemies")
		play()
	else:
		_start_aiming()
	potion_popup.visible = false

func _on_discard_button_pressed() -> void:
	discard()
	potion_popup.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not targeting:
		return	
	if event.is_action_pressed("right_mouse"):
		_end_aiming()
	elif event.is_action_pressed("left_mouse"):
		get_viewport().set_input_as_handled()
		_end_aiming()
		if targets.is_empty():
			return
		play()
	

func _start_aiming() -> void:
	targets.clear()
	targeting = true
	Events.potion_aim_started.emit(self)

func _end_aiming() -> void:
	targeting = false
	Events.potion_aim_ended.emit(self)

func _show_keyword_tooltip() -> void:
	if potion:
		KeywordTooltip.add_keyword(potion.potion_name, potion.description)
		KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 1.4, size.y)
		KeywordTooltip.show()
