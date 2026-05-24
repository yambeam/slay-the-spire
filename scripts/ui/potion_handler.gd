class_name PotionHandler
extends MarginContainer

@onready var potion_place_holder: HBoxContainer = $MarginContainer/PotionPlaceHolder
const POTION_UI = preload("res://scenes/ui/top_bar/potion_ui.tscn")

var run_stats: RunStats
var max_potion_slots: int = 3

var _rebuilding: bool = false

func initialize(run_stats_: RunStats) -> void:
	run_stats = run_stats_
	Events.combat_won.connect(_on_combat_ended)
	Events.player_turn_ended.connect(_on_player_turn_ended)
	Events.player_turn_started.connect(_on_player_turn_started)
	Events.before_potion_used.connect(_on_before_potion_used)
	Events.after_potion_used.connect(_on_after_potion_used)
	run_stats.potion_added.connect(add_potion)
	run_stats.potion_removed.connect(remove_potion)
	run_stats.potion_slots_changed.connect(update_potion_slot)
	update_potion_slot()

func update_potion_slot() -> void:
	
	_rebuilding = true
	
	max_potion_slots = run_stats.max_potion_slots
	for child in potion_place_holder.get_children():
		child.queue_free()
	for i in range(max_potion_slots):
		var potion_ui = POTION_UI.instantiate() as PotionUI
		potion_place_holder.add_child(potion_ui)
	await get_tree().process_frame
	set_potions()
	
	_rebuilding = false
		
#func set_potions() -> void:
	#var potions = run_stats.get_potions()
	#for i in range(potions.size()):
		#potion_place_holder.get_child(i).set_potion(potions[i])

func set_potions() -> void:
	var potions = run_stats.get_potions()
	var slot_count = potion_place_holder.get_child_count()
	for i in range(min(potions.size(), slot_count)):
		var slot = potion_place_holder.get_child(i)
		if slot is PotionUI:
			slot.set_potion(potions[i])

## 这里也许可以优化一下
func add_potion(_potion: Potion):
	if _rebuilding:
		return
	set_potions()

func remove_potion(_index: int):
	if _rebuilding:
		return
	set_potions()

func _on_before_potion_used(_potion_ui: PotionUI) -> void:
	for child: PotionUI in potion_place_holder.get_children():
		child.can_use = false

func _on_after_potion_used(potion_ui: PotionUI) -> void:
	for child: PotionUI in potion_place_holder.get_children():
		if potion_ui == child:
			run_stats.remove_potion(child.get_index())
		child.can_use = true
		

func _on_player_turn_started() -> void:
	for child: PotionUI in potion_place_holder.get_children():
		child.can_use = true

func _on_player_turn_ended() -> void:
	for child: PotionUI in potion_place_holder.get_children():
		child.can_use = false
		
func _on_combat_ended(_context: RewardContext) -> void:
	for child: PotionUI in potion_place_holder.get_children():
		child.can_use = false
