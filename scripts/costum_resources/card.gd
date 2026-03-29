class_name Card
extends Resource
# 卡牌类型(攻击，技能，能力)
enum Type {ATTACK, SKILL, POWER}
# 卡牌目标类型
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}
# 卡牌稀有度
enum Rarity {COMMON, UNCOMMON, RARE, CURSED, STATUS}
# 卡牌所属卡牌池
enum COLOR {
	RED,	# 铁甲战士
	GREEN,	# 静默猎手
	ORANGE, # 储君
	PINK,	# 亡灵契约师
	BLUE,	# 故障机器人
	CURSE,  # 诅咒
	COLORLESS, # 无色
}

## TODO: 使用表格而不是使用资源文件存储数据
@export_group("卡牌属性")
## 卡牌名称
@export var id: String
## 卡牌类型
@export var type: Type
## 目标类型
@export var base_target: Target
## 卡牌属于那个角色池，详情见COLOR枚举
@export var card_color: COLOR
# TODO: X费
@export var base_cost: int
@export var rarity: Rarity
@export_group("卡牌描述")
@export var portrait: Texture
@export_multiline var base_description: String
@export var sound: AudioStream
@export var base_numeric_entries: Array[NumericEntry]
# 注意这两个可以动态生成的词条不能在卡牌描述中写死
# 是否带“消耗“词条
@export var exhaust: bool
# 是否带”虚无“词条
@export var ethereal: bool
# 升级后
@export_group("升级后")
@export var upgraded_target: Target
@export var upgraded_cost: int
@export_multiline var upgraded_description: String
@export var upgraded_numeric_entries: Array[NumericEntry]
@export var upgraded: bool = false


func get_final_values(source_: Creature, target_: Creature) -> Dictionary:
	var ret = {}
	for entry: NumericEntry in get_numeric_entries():
		var base_value := _get_numeric_value(entry, source_)
		var modifiers := []
		match entry.affected_by:
			# 这里感觉有问题
			NumericEntry.AFFECTED_BY.SELF:
				modifiers = source_.get_modifiers_by_type(entry.type, Buff.AFFECT.SELF)
			NumericEntry.AFFECTED_BY.TARGET:
				if target_:
					modifiers = target_.get_modifiers_by_type(entry.type, Buff.AFFECT.TARGET)
			NumericEntry.AFFECTED_BY.BOTH:
				if target_:
					modifiers = NumericHelper.combine_modifiers(source_.get_modifiers_by_type(entry.type, Buff.AFFECT.SELF), target_.get_modifiers_by_type(entry.type, Buff.AFFECT.TARGET))
				else:
					modifiers = source_.get_modifiers_by_type(entry.type, Buff.AFFECT.SELF)
			NumericEntry.AFFECTED_BY.NONE:
				modifiers = []
			_:
				printerr("未知的NumericEntry")
		var final_value = NumericHelper.apply_modifiers(base_value, modifiers)
		ret[entry.placeholder] = final_value
	return ret

func play(context: Context, char_stats: CharacterStats) -> void:
	Events.card_played.emit(self)
	char_stats.energy -= get_cost()
	if is_single_targeted():
		apply_effects(context)
	else:
		apply_effects(_get_targets(context))

func apply_effects(_context: Context) -> void:
	pass

func is_single_targeted() -> bool:
	return get_target() == Target.SINGLE_ENEMY

func _get_targets(context: Context) -> Context:
	var targets := context.targets
	if not targets or targets.is_empty():
		printerr("card出错")
		context.targets = []
		return context
	# 资源没有获取场景树的方法
	var tree := targets[0].get_tree()
	match get_target():
		Target.SELF:
			context.targets = tree.get_nodes_in_group("ui_player")
		Target.ALL_ENEMIES:
			context.targets = tree.get_nodes_in_group("ui_enemies")
		Target.EVERYONE:
			context.targets = tree.get_nodes_in_group("ui_player") + tree.get_nodes_in_group("ui_enemies")
		_:
			# 对于SingleTargeted,使用TargetSelector获取目标
			printerr("card出错")
			context.targets = []
	return context

func get_description(source_: Creature, target_: Creature) -> String:
	var numeric_dict := get_final_values(source_, target_)
	var final_value: int
	var color: String
	var replacement: String
	var ret: String = _get_default_description()
	for placeholder: String in numeric_dict.keys():
		final_value = numeric_dict[placeholder]
		replacement = str(final_value)
		for numeric_entry in get_numeric_entries():
			if numeric_entry.placeholder == placeholder:
				if numeric_entry.base_value == final_value:
					continue
				elif numeric_entry.base_value > final_value:
					color = "red"
					replacement = "[color={0}]{1}[/color]".format([color, final_value])
				elif numeric_entry.base_value < final_value:
					color = "green"
					replacement = "[color={0}]{1}[/color]".format([color, final_value])
				ret = ret.replace("{" + placeholder + "}", replacement)
	return append_features(ret).format(numeric_dict)
	
func get_default_description() -> String:
	var dict := {}
	for entry: NumericEntry in get_numeric_entries():
		dict[entry.placeholder] = entry.base_value
	return append_features(_get_default_description()).format(dict)

func get_title() -> String:
	return "[color=green]" + id + "+[/color]" if upgraded else id

func append_features(desc: String) -> String:
	if exhaust:
		desc += "[p][center][color=gold]消耗。[/color][/center]"
	if ethereal:
		desc += "[p][center][color=gold]虚无。[/color][/center]"
	return desc

func upgrade() -> void:
	upgraded = true

func get_numeric_entries() -> Array[NumericEntry]:
	return upgraded_numeric_entries if upgraded else base_numeric_entries

func _get_numeric_value(entry: NumericEntry, player: Player = null) -> int:
	match entry.source:
		NumericEntry.Source.FIXED:
			return entry.base_value
		NumericEntry.Source.PLAYER_BLOCK:
			return player.get_block()
		NumericEntry.Source.PLAYER_STRENGTH:
			# 暂时没做
			return 0
		_:
			print("未实现")
			return 0

func get_numeric_value(entries: Array[NumericEntry], index: int, player: Player = null) -> int:
	return _get_numeric_value(entries[index], player)

func _get_default_description() -> String:
	return upgraded_description if upgraded else base_description

func get_cost() -> int:
	return upgraded_cost if upgraded else base_cost

func get_target() -> Target:
	return upgraded_target if upgraded else base_target
