class_name Buff
extends Node

var agent: Creature

signal stack_changed

var stacks: int = 1 : set = _set_stacks
var buff_resource: BuffResource

var buff_id: String
var buff_name: String
var description: String
var icon: Texture2D
var buff_type: BuffResource.BuffType
var affect: BuffResource.AFFECT
var stackable: bool = true
var max_stack: int = 999
var min_stack: int = 0

func _ready():
	if buff_resource:
		buff_id = buff_resource.buff_id
		buff_name = buff_resource.buff_name
		description = buff_resource.description
		icon = buff_resource.icon
		affect = buff_resource.affect
		stackable = buff_resource.stackable
		max_stack = buff_resource.max_stack
		min_stack = buff_resource.min_stack
		initialize()

func initialize() -> void:
	pass
		
func add_stack(amount: int):
	if not stackable and stacks > 0:
		return
	elif amount < 0:
		remove_stack(-amount)
		return
	stacks = clampi(stacks + amount, min_stack, max_stack)
	if stacks == 0:
		queue_free()
	
func remove_stack(amount: int):
	stacks = clampi(stacks - amount, min_stack, max_stack)
	if stacks == 0:
		queue_free()
	
func get_description() -> String:
	return description

func is_debuff() -> bool:
	return buff_type == BuffResource.BuffType.DEBUFF

func is_buff() -> bool:
	return buff_type == BuffResource.BuffType.BUFF

func get_modifier() -> Array[Modifier]:
	return []

func get_modifiers_by_type(type_: Enums.NumericType) -> Array:
	var result := []
	for modifier: Modifier in get_modifier():
		if modifier.type == type_:
			result.append(modifier)
	return result	

func _set_stacks(value: int) -> void:
	#if stackable:
		#stacks = value
	#else:
		#stacks = clampi(value, 0, 1)
	stacks = value
	stack_changed.emit()


##buff数据序列化
func serialize() -> Dictionary:
	return {
		"buff_name": buff_resource.buff_name,   # 改用 buff_name
		"stacks": stacks,
	}

static func deserialize(data: Dictionary) -> Buff:
	var buff_name_: String = data.get("buff_name", "")
	if buff_name_.is_empty():
		push_error("Buff.deserialize: buff_name missing")
		return null

	var resource: BuffResource = BuffLibrary.get_buff_resource_by_name(buff_name_)
	if not resource:
		push_error("Buff.deserialize: no BuffResource found for " + buff_name_)
		return null

	var buff := Buff.new()
	buff.buff_resource = resource
	return buff
