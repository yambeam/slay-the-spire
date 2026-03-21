class_name Creature
extends Area2D

@warning_ignore_start("unused_signal")
signal turn_started(creature: Creature)
signal turn_ended(creature: Creature)
signal before_take_damage(context: Context)
signal before_lose_health(context: Context)
@warning_ignore_restore("unused_signal")
# offset: 根据贴图大小调整各个组件

const BUFF_UI = preload("res://scenes/combat_ui/buff_ui.tscn")

@onready var buff_container: GridContainer = $BuffContainer
@onready var buff_manager: BuffManager = $BuffManager
@onready var reticles: Node2D = $Reticles
@onready var health_bar: HealthBar = $HealthBar
@onready var spine_manager: SpineManager = $SpineManager

var spine_anim_state: SpineAnimationState

func add_buff(buff_context: ApplyBuffContext) -> void:
	buff_context.buff_node.stacks = buff_context.amount	
	buff_manager.add_buff(buff_context)
	var buff_ui := BUFF_UI.instantiate()
	buff_ui.buff = buff_context.buff_node
	buff_container.add_child(buff_ui)

func get_modifiers_by_type(type: Enums.NumericType) -> Array:
	var ret := []
	for child: Buff in buff_manager.get_children():
		ret += child.get_modifiers_on_type(type)
	return ret

func start_turn() -> void:
	turn_started.emit(self)

func end_turn() -> void:
	turn_ended.emit(self)
	
func lose_health(_context: Context) -> void:
	pass
	
func gain_block(_context: Context):
	pass

func take_damage(_context: Context) -> void:
	pass

func die() -> void:
	pass
