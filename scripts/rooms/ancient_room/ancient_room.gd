class_name AncientRoom
extends Control

## 当前先古阶段 (1: Neow, 2: Orobas)
@export var current_stage: int = 1

const RELIC_PILES = {
	1: preload("res://entities/ancient/neow_relics.tres"),
	2: preload("res://entities/ancient/orobas_relics.tres")
}

const ANCIENT_ICONS = {
	1: preload("res://images/ui/run_history/neow.png"),
	2: preload("res://images/ui/run_history/orobas.png")
}

const OPENING_LINES = {
	1: [
		"啊...你醒了。选一件[shake freq=20]先古遗物[/shake]，然后继续你的旅程。",
		"又见面了，旅人。挑一件[shake freq=20]恩赐[/shake]吧。",
		"命运之轮再次转动...选择一件[shake freq=20]远古遗物[/shake]，它将与你同行。"
	],
	2: [
		"哈哈！来挑一个礼物吧，小家伙！",
		"虹光与我做主，你运气不错！",
		"选一个，然后看看它会怎么改变你的道路！"
	]
}

const AFTER_CHOICE_LINES = {
	1: [
		"明智的选择。愿这份力量守护你。",
		"很好。它会陪伴你走过下一段路。",
		"一切早已注定。去吧，前方还有很长的路。"
	],
	2: [
		"有趣的选择...看看会发生什么！",
		"噢，那个可是我的最爱！",
		"旅途愉快，记得回来玩！"
	]
}

const RELIC_UI_SCENE = preload("res://scenes/relichandler/relic_ui.tscn")

@export var relic_spacing: int = 100
@onready var spine_sprite: SpineSprite = get_node_or_null("SpineSprite") as SpineSprite
@onready var relic_container: Control = $Control
@onready var return_button: Button = $Button

var relic_buttons: Array[Control] = []
var dialogue_container: HBoxContainer
var ancient_icon: TextureRect
var dialogue_label: RichTextLabel

# 存档数据
var relic_options: Array[Relic] = []
var has_chosen: bool = false


func _ready() -> void:
	# 播放 Spine 的 idle 动画
	if spine_sprite:
		spine_sprite.get_animation_state().set_animation("idle_loop", true, 0)

	# 返回按钮基础设置
	return_button.visible = false
	return_button.pressed.connect(_on_return_pressed)
	return_button.mouse_entered.connect(_on_button_entered)
	return_button.mouse_exited.connect(_on_button_exited)

	# 只创建空的对话 UI，不填充内容
	_create_dialogue_ui()
	


func initialize_new() -> void:
	_show_random_opening()
	_create_relic_options()



func restore_state(state: Dictionary) -> void:
	if state.has("has_chosen"):
		has_chosen = state["has_chosen"]

	if state.has("dialogue_text"):
		dialogue_label.text = state["dialogue_text"]
		dialogue_label.scroll_active = false   
	if has_chosen:
		# 已经选择过遗物：显示返回按钮，台词已恢复
		return_button.visible = true
	else:
		# 未选择：恢复遗物选项（如果存档中有）
		if state.has("relic_options"):
			var paths: Array = state["relic_options"]
			relic_options.clear()
			for path in paths:
				var relic: Relic = load(path) as Relic
				if relic:
					relic_options.append(relic)
				else:
					print("[Load] Failed to load relic at: ", path)

		# 如果遗物选项非空则创建 UI，否则随机生成（安全回退）
		if relic_options.is_empty():
			_create_relic_options()
		else:
			_create_relic_ui(relic_options)


#
func _create_dialogue_ui() -> void:
	dialogue_container = HBoxContainer.new()
	dialogue_container.position = Vector2(700, 650)
	dialogue_container.custom_minimum_size.x = 700
	dialogue_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_container.z_index = 10
	add_child(dialogue_container)

	# 先古头像
	ancient_icon = TextureRect.new()
	ancient_icon.texture = ANCIENT_ICONS.get(current_stage, ANCIENT_ICONS[1])
	ancient_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ancient_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	ancient_icon.custom_minimum_size = Vector2(48, 48)
	dialogue_container.add_child(ancient_icon)

	# 对话文本
	dialogue_label = RichTextLabel.new()
	dialogue_label.add_theme_font_size_override("normal_font_size", 24)
	dialogue_label.bbcode_enabled = true
	dialogue_label.scroll_active = false
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_container.add_child(dialogue_label)

	var shake_effect = load("res://entities/ancient/neow_rich_text_effect.tres")
	if shake_effect:
		dialogue_label.custom_effects.append(shake_effect)


# 
func _show_random_opening() -> void:
	var pool = OPENING_LINES.get(current_stage, OPENING_LINES[1])
	dialogue_label.text = pool[randi() % pool.size()]


func _show_random_after_choice() -> void:
	var pool = AFTER_CHOICE_LINES.get(current_stage, AFTER_CHOICE_LINES[1])
	dialogue_label.text = pool[randi() % pool.size()]


func _on_return_pressed() -> void:
	Events.ancient_exited.emit()


#
func _create_relic_options() -> void:
	var choices := _pick_random_relics(3)
	if choices.is_empty():
		return
	relic_options = choices
	_create_relic_ui(choices)


func _pick_random_relics(amount: int) -> Array[Relic]:
	var pile: RelicPile = RELIC_PILES.get(current_stage, RELIC_PILES[1])
	if not pile or not pile.relics:
		printerr("无法加载阶段 %d 的遗物堆" % current_stage)
		return []

	var stats: RunStats = null
	var run = _get_run_node()
	if run:
		stats = run.stats

	# 过滤已拥有的遗物
	var available = pile.relics.duplicate()
	if stats:
		available = available.filter(func(r: Relic): return not stats.has_relic(r.id))

	if available.is_empty():
		print("阶段 %d 所有先古遗物均已拥有" % current_stage)
		return []
	
	RandomSetting.array_shuffle(available)

	var result: Array[Relic] = []
	for relic in available:
		result.append(relic)
		if result.size() >= amount:
			break
	return result


## 
func _create_relic_ui(relics: Array[Relic]) -> void:
	# 清空旧的选项
	for child in relic_container.get_children():
		child.queue_free()
	relic_buttons.clear()

	var hbox = HBoxContainer.new()
	hbox.name = "RelicOptions"
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.custom_minimum_size = relic_container.size
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", relic_spacing)
	hbox.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	relic_container.add_child(hbox)

	for relic in relics:
		var relic_ui = RELIC_UI_SCENE.instantiate() as RelicUI
		relic_ui.custom_minimum_size = Vector2(140, 140)
		relic_ui.mouse_filter = Control.MOUSE_FILTER_STOP
		relic_ui.set_relic(relic)

		# 悬浮缩放特效
		relic_ui.mouse_entered.connect(
			func(): create_tween().tween_property(relic_ui, "scale", Vector2(1.1, 1.1), 0.1)
		)
		relic_ui.mouse_exited.connect(
			func(): create_tween().tween_property(relic_ui, "scale", Vector2(1.0, 1.0), 0.1)
		)

		# 悬浮显示关键词提示
		relic_ui.mouse_entered.connect(_on_relic_mouse_entered.bind(relic_ui, relic))
		relic_ui.mouse_exited.connect(_on_relic_mouse_exited)

		# 点击选择
		relic_ui.gui_input.connect(_on_relic_ui_input.bind(relic_ui, relic))

		hbox.add_child(relic_ui)
		relic_buttons.append(relic_ui)


#
func _on_relic_ui_input(event: InputEvent, relic_ui: Control, relic: Relic) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_relic(relic_ui, relic)


func _select_relic(relic_ui: Control, relic: Relic) -> void:
	has_chosen = true
	relic_options.clear()   

	for btn in relic_buttons:
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE


	Events.ancient_relic_selected.emit(relic)

	# 清理选项并显示离开按钮
	for child in relic_container.get_children():
		child.queue_free()
	relic_buttons.clear()

	_show_random_after_choice()
	return_button.visible = true


func _on_relic_mouse_entered(relic_ui: Control, relic: Relic) -> void:
	KeywordTooltip.add_keyword(relic.relic_name, relic.description)
	KeywordTooltip.show()


func _on_relic_mouse_exited() -> void:
	KeywordTooltip.hide()


func _on_button_entered():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(return_button, "scale", Vector2(1.1, 1.1), 0.15)


func _on_button_exited():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(return_button, "scale", Vector2(1.0, 1.0), 0.15)


func _get_run_node():
	var current = self
	while current:
		if current is Run:
			return current
		current = current.get_parent()
	return null


# 
func get_save_state() -> Dictionary:
	var paths := []
	for relic in relic_options:
		paths.append(relic.resource_path)   # 保存遗物资源路径
	return {
		"relic_options": paths,
		"dialogue_text": dialogue_label.text,
		"has_chosen": has_chosen
	}


func set_save_state(state: Dictionary) -> void:
	restore_state(state)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event() 
