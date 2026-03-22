class_name Creature
extends Area2D

@warning_ignore_start("unused_signal")
signal turn_started(creature: Creature)
signal turn_ended(creature: Creature)
signal before_take_damage(context: Context)
signal before_lose_health(context: Context)
signal before_attack(context: Context)
signal before_gain_block(context: Context)
signal before_applied_buff(context: Context)
signal after_applied_buff(context: Context)
@warning_ignore_restore("unused_signal")
# offset: 根据贴图大小调整各个组件

const BUFF_UI = preload("res://scenes/rooms/combat_room/combat_ui/buff_ui.tscn")

@onready var buff_container: GridContainer = $BuffContainer
@onready var buff_manager: BuffManager = $BuffManager
@onready var reticles: Node2D = $Reticles
@onready var health_bar: HealthBar = $HealthBar
@onready var spine_manager: SpineManager = $SpineManager

var spine_anim_state: SpineAnimationState

func attack(context: Context) -> void:
	before_attack.emit(context)
	for child: Creature in context.targets:
		var damage_context = DamageContext.new(self, [child], context.amount)
		child.before_take_damage.emit(damage_context)
		child.take_damage(damage_context)

func gain_block(_context: Context) -> void:
	pass

func add_buff(buff_context: ApplyBuffContext) -> void:
	buff_context.buff_node.stacks = buff_context.amount	
	if buff_manager.add_buff(buff_context):
		var buff_ui := BUFF_UI.instantiate()
		buff_ui.buff = buff_context.buff_node
		buff_container.add_child(buff_ui)

func get_modifiers_by_type(type: Enums.NumericType, affect: Buff.AFFECT) -> Array:
	var ret := []
	for child: Buff in buff_manager.get_children():
		if child.affect == affect or child.affect == Buff.AFFECT.ALL:
			ret += child.get_modifiers_on_type(type)
	return ret

func start_turn() -> void:
	turn_started.emit(self)

func end_turn() -> void:
	turn_ended.emit(self)
	
func lose_health(_context: Context) -> void:
	pass
	
func take_damage(_context: Context) -> void:
	pass

func die() -> void:
	pass
