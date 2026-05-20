class_name RelicHandler
extends GridContainer

signal relics_activated(type: Relic.TriggerType)

const RELIC_APPLY_INTERVAL := 0.1
const RELIC_UI = preload("res://scenes/relichandler/relic_ui.tscn")

var run_stats: RunStats

func initialize(run_stats_: RunStats):
	run_stats = run_stats_
	for relic_ui: RelicUI in get_children():
		relic_ui.queue_free()
	child_exiting_tree.connect(_on_relics_child_exiting_tree)
	run_stats.relic_added.connect(add_relic)
	run_stats.relic_removed.connect(remove_relic)

func activate_relics_by_trigger_type(type: Relic.TriggerType) -> void:
	# 由信号解决
	if type == Relic.TriggerType.NONE:
		return
	
	var relic_queue: Array[Node] = get_children().filter(
		func(relic_ui: RelicUI):
			return relic_ui.relic.trigger_type == type
	)
	
	if relic_queue.is_empty():
		relics_activated.emit(type)
		return
	
	var tween := create_tween()
	for relic_ui: RelicUI in relic_queue:
		tween.tween_callback(relic_ui.relic.activate_relic.bind(relic_ui))
		tween.tween_interval(RELIC_APPLY_INTERVAL)
	tween.finished.connect(func(): relics_activated.emit(type))

func add_relics(relics: Array[Relic]) -> void:
	for relic: Relic in relics:
		add_relic(relic)

func add_relic(relic: Relic) -> void:
	if not relic:
		return
	var new_relic_ui: RelicUI = RELIC_UI.instantiate()
	add_child(new_relic_ui)
	new_relic_ui.set_relic(relic)
	new_relic_ui.relic.initialize_relic(new_relic_ui)

func remove_relic(relic: Relic) -> void:
	if not relic:
		return
	for child: RelicUI in get_children():
		if child.relic.id == relic.id:
			child.queue_free()
			return

func _on_relics_child_exiting_tree(relic_ui: RelicUI) -> void:
	if not relic_ui:
		return 
	
	if relic_ui.relic:
		relic_ui.relic.deactivate_relic(relic_ui)
