extends Control

const RELIC_UI_SCENE = preload("res://scenes/relichandler/relic_ui.tscn")

@export var relic_common_weight := 6.0
@export var relic_uncommon_weight := 3.0
@export var relic_rare_weight := 1.0

@export var gold_min := 50
@export var gold_max := 150

@onready var chest: Control = $Chest
@onready var line_2d: Line2D = $Chest/Line2D
@onready var hands_container: Control = $HandsContainer
@onready var label: Label = $HandsContainer/Label
@onready var color_rect: ColorRect = $ColorRect
@onready var proceed_button: Button = $Button
@onready var relic_display: Control = $HandsContainer/Control
@onready var light: PointLight2D = $Chest/PointLight2D

@onready var sparkles: CPUParticles2D = $Chest/Sparkles

var is_opened: bool = false


func _ready():
	line_2d.modulate.a = 0.0
	hands_container.visible = false
	label.modulate.a = 0.0

	chest.mouse_filter = Control.MOUSE_FILTER_STOP
	chest.mouse_entered.connect(_on_chest_mouse_entered)
	chest.mouse_exited.connect(_on_chest_mouse_exited)
	chest.gui_input.connect(_on_chest_gui_input)

	proceed_button.visible = false
	proceed_button.pressed.connect(_on_proceed_pressed)
	proceed_button.mouse_entered.connect(_on_button_entered)
	proceed_button.mouse_exited.connect(_on_button_exited)


func _on_chest_mouse_entered():
	if is_opened:
		return
	var tween = create_tween()
	tween.tween_property(line_2d, "modulate:a", 1.0, 0.3)


func _on_chest_mouse_exited():
	var tween = create_tween()
	tween.tween_property(line_2d, "modulate:a", 0.0, 0.0)


func _on_chest_gui_input(event: InputEvent):
	if is_opened:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_open_chest()


func _open_chest():
	is_opened = true

	_on_chest_mouse_exited()
	if sparkles:
		sparkles.emitting = false

	hands_container.visible = true
	label.modulate.a = 1.0
	color_rect.color.a = 1.0

	if chest.get_global_rect().has_point(get_global_mouse_position()):
		var hide_tween = create_tween()
		hide_tween.tween_property(line_2d, "modulate:a", 0.0, 0.0)
	light.energy = 0.0
	#await get_tree().create_timer(1.0).timeout
	%GoldExplosion.emitting = true
	_give_reward()
	proceed_button.visible = true


func _give_reward():
	var run_node = _get_run_node()
	if not run_node or not run_node.stats:
		return

	var gold_amount =  RandomSetting.instance.randi_range(gold_min, gold_max)
	run_node.stats.gold += gold_amount
	print("获得金币：", gold_amount)

	var relic = _get_random_weighted_relic(run_node.stats)
	if relic:
		run_node.stats.add_relic(relic)
		_show_relic_visual(relic)
		ItemPool.remove_relic(relic)


func _show_relic_visual(relic: Relic):
	for child in relic_display.get_children():
		child.queue_free()

	var relic_ui = RELIC_UI_SCENE.instantiate() as RelicUI
	relic_display.add_child(relic_ui)
	relic_ui.size = relic_display.size
	relic_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	relic_ui.z_index = 2
	relic_ui.set_relic(relic)


func _on_proceed_pressed():
	Events.treasure_room_exited.emit()


func _on_button_entered():
	_create_scale_tween(proceed_button, Vector2(1.1, 1.1))


func _on_button_exited():
	_create_scale_tween(proceed_button, Vector2.ONE)


func _create_scale_tween(node: Control, target_scale: Vector2):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(node, "scale", target_scale, 0.15)


func _get_run_node() -> Node:
	var current = self
	while current:
		if current is Run:
			return current
		current = current.get_parent()
	return null


func _get_random_weighted_relic(stats: RunStats) -> Relic:
	var pool = ItemPool.get_current_relic_pool()
	if not pool or pool.is_empty():
		return null

	var available := pool.duplicate()
	if stats:
		available = available.filter(func(r: Relic): return not stats.has_relic(r.id))

	if available.is_empty():
		return null

	var total_weight = relic_common_weight + relic_uncommon_weight + relic_rare_weight
	var roll = randf() * total_weight

	var target_rarity: int
	if roll < relic_common_weight:
		target_rarity = Relic.Rarity.COMMON
	elif roll < relic_common_weight + relic_uncommon_weight:
		target_rarity = Relic.Rarity.UNCOMMON
	else:
		target_rarity = Relic.Rarity.RARE

	var candidates := available.filter(func(r: Relic): return r.rarity == target_rarity)
	if candidates.is_empty():
		candidates = available

	return RandomSetting.array_pick_random(candidates).duplicate()


func get_save_state() -> Dictionary:
	return {"is_opened": is_opened}

func set_save_state(state: Dictionary) -> void:
	if state.is_empty():
		return
	is_opened = state.get("is_opened", false)
	if is_opened:
		# 恢复宝箱已开启的界面
		if sparkles:
			sparkles.emitting = false
		hands_container.visible = true
		label.modulate.a = 1.0
		color_rect.color.a = 1.0
		light.energy = 0.0
		proceed_button.visible = true
		line_2d.modulate.a = 0.0

		# 直接从已保存的遗物列表中取最后一个（就是宝箱给的）
		var run_node = _get_run_node()
		if run_node and run_node.stats and run_node.stats.relics.size() > 0:
			var last_relic = run_node.stats.relics[-1]
			_show_relic_visual(last_relic)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event() 
