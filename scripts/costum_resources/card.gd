class_name Card
extends Resource
# TODO: 诅咒,状态
# 卡牌类型(攻击，技能，能力)
enum Type {ATTACK, SKILL, POWER}
# 卡牌目标类型
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

## TODO: 使用表格而不是使用资源文件存储数据
@export_group("卡牌属性")
@export var id: String
@export var type: Type
@export var target: Target
# TODO: X费
@export var cost: int
@export_group("卡牌描述")
@export var portrait: Texture
@export_multiline var description: String
@export var sound: AudioStream
@export var numeric_entries: Array[NumericEntry]


func get_final_values(source_: Creature, target_: Creature) -> Dictionary:
	var ret = {}
	for entry: NumericEntry in numeric_entries:
		var base_value := entry.base_value
		var modifiers := []
		match entry.affected_by:
			NumericEntry.AFFECTED_BY.SELF:
				modifiers = source_.get_modifiers_by_type(entry.type)
			NumericEntry.AFFECTED_BY.TARGET:
				if target_:
					modifiers = target_.get_modifiers_by_type(entry.type)
			NumericEntry.AFFECTED_BY.BOTH:
				if target_:
					modifiers = NumericHelper.combine_modifiers(source_.get_modifiers_by_type(entry.type), target_.get_modifiers_by_type(entry.type))
				else:
					modifiers = source_.get_modifiers_by_type(entry.type)
			NumericEntry.AFFECTED_BY.NONE:
				modifiers = []
			_:
				printerr("未知的NumericEntry")
		var final_value = NumericHelper.apply_modifers(base_value, modifiers)
		ret[entry.placeholder] = final_value
	return ret

func play(context: Context, char_stats: CharacterStats) -> void:
	Events.card_played.emit(self)
	char_stats.energy -= cost
	if is_single_targeted():
		apply_effects(context)
	else:
		apply_effects(_get_targets(context))

func apply_effects(_context: Context) -> void:
	pass

func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

func _get_targets(context: Context) -> Context:
	var targets := context.targets
	if not targets or targets.is_empty():
		printerr("card出错")
		context.targets = []
		return context
	# 资源没有获取场景树的方法
	var tree := targets[0].get_tree()
	match target:
		Target.SELF:
			context.targets = tree.get_nodes_in_group("ui_player")
		Target.ALL_ENEMIES:
			context.targets = tree.get_nodes_in_group("ui_emeies")
		Target.EVERYONE:
			context.targets = tree.get_nodes_in_group("ui_player") + tree.get_nodes_in_group("ui_enemies")
		_:
			# 对于SingleTargeted,使用TargetSelector获取目标
			printerr("card出错")
			context.targets = []
	return context

func get_description(source_: Creature, target_: Creature) -> String:
	return description.format(get_final_values(source_, target_))

func get_default_description() -> String:
	var dict := {}
	for entry: NumericEntry in numeric_entries:
		dict[entry.placeholder] = entry.base_value
	return description.format(dict)
		
