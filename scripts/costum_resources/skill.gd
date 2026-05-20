class_name Skill
extends Resource

@warning_ignore("unused_signal")
signal skill_stats_changed()

# 技能目标类型
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}
# 技能所属卡牌池
enum COLOR {
	RED = 0b0000001,	# 铁甲战士
	GREEN = 0b0000010,	# 静默猎手
	ORANGE = 0b0000100, # 储君
	PINK = 0b0001000,	# 亡灵契约师
	BLUE = 0b0010000,	# 故障机器人
}

## TODO: 使用表格而不是使用资源文件存储数据
@export_group("技能属性")
## 技能名称
@export var id: String
## 目标类型
@export var target: Target
## 技能属于哪个个角色池，详情见COLOR枚举
@export var card_color: COLOR = COLOR.RED
## 释放技能所需充能
#@export var charge_cost: int
# 技能效果列表
@export var effects: Array[Effect]
@export_group("技能描述")
@export var portrait: Texture
@export_multiline var description: String
@export var numeric_entries: Array[NumericEntry]

## 技能暂时不考虑升级
## 升级后
#@export_group("升级后")
#@export var upgraded_target: Target
#@export var upgraded_cost: int
#@export_multiline var upgraded_description: String
#@export var upgraded_numeric_entries: Array[NumericEntry]
## 升级后卡牌效果列表
#@export var upgraded_effects: Array[Effect]
#@export var upgraded: bool = false
#@export var upgradable: bool = true

func available() -> bool:
	return false

func get_final_values(source_: Creature, target_: Creature) -> Dictionary:
	var ret = {}
	for entry: NumericEntry in numeric_entries:
		var base_value := _get_numeric_value(entry, source_, target_)
		var modifiers := []
		match entry.affected_by:
			# 这里感觉有问题
			NumericEntry.AFFECTED_BY.SELF:
				modifiers = source_.get_modifiers_by_type(entry.numeric_type, BuffResource.AFFECT.SELF)
			NumericEntry.AFFECTED_BY.TARGET:
				if target_:
					modifiers = target_.get_modifiers_by_type(entry.numeric_type, BuffResource.AFFECT.TARGET)
			NumericEntry.AFFECTED_BY.BOTH:
				if target_:
					modifiers = NumericHelper.combine_modifiers(source_.get_modifiers_by_type(entry.numeric_type, BuffResource.AFFECT.SELF), target_.get_modifiers_by_type(entry.numeric_type, BuffResource.AFFECT.TARGET))
				else:
					modifiers = source_.get_modifiers_by_type(entry.numeric_type, BuffResource.AFFECT.SELF)
			NumericEntry.AFFECTED_BY.NONE:
				modifiers = []
			_:
				printerr("未知的NumericEntry")
		var final_value = NumericHelper.apply_modifiers(base_value, modifiers)
		ret[entry.placeholder] = final_value
	return ret
#
#func play(source: Player, targets: Array[Node], char_stats: CharacterStats) -> void:
	#if first_play_free:
		#first_play_free = false
	#else:
		#char_stats.energy -= get_cost()
	#if is_single_targeted():
		#apply_effects(source, targets)
	#else:
		#apply_effects(source, _get_targets(source, targets))
	#if enchantment:
		#enchantment.on_play(source, targets)
	#Events.card_played.emit(self)

func play(source: Player, targets: Array[Node], no_callback: bool = false) -> void:
	targets = _get_targets(source, targets) if target != Target.SINGLE_ENEMY else targets
	var card_context := {
		"player": source,
		"skill": self,
		"targets": targets
	}
	Events.before_card_played.emit(self, card_context)
	if no_callback:
		source.combat_resolver.execute(ResolutionEntry.new(self, effects, card_context, func(): return))
	else:
		source.combat_resolver.execute(ResolutionEntry.new(self, effects, card_context, \
		func(): 
			Events.skill_played.emit(self)
			on_played(source, targets)
			)
		)

func on_played(_source: Player, _targets: Array[Node]) -> void:
	pass
	# e.g.暴走:每打出一次伤害提高5

func apply_effects(_source: Player, _targets: Array[Node]) -> void:
	pass

func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

func _get_targets(source: Player, targets: Array[Node]) -> Array[Node]:
	var ret: Array[Node] = targets
	if not targets or targets.is_empty():
		printerr("skill出错")
		return []
	# 资源没有获取场景树的方法
	var tree := targets[0].get_tree()
	match target:
		Target.SELF:
			ret = [source]
		Target.ALL_ENEMIES:
			ret = tree.get_nodes_in_group("ui_enemies")
		Target.EVERYONE:
			ret = [source] + tree.get_nodes_in_group("ui_enemies")
		_:
			# 对于SingleTargeted,使用TargetSelector获取目标
			printerr("card出错")
			ret = []
	return ret

func get_description(source_: Creature, target_: Creature) -> String:
	var numeric_dict := get_final_values(source_, target_)
	var final_value: int
	var color: String
	var replacement: String
	var ret: String = description
	for placeholder: String in numeric_dict.keys():
		final_value = numeric_dict[placeholder]
		replacement = str(final_value)
		for numeric_entry in numeric_entries:
			if numeric_entry.placeholder == placeholder:
				if numeric_entry.get_base_value() == final_value:
					continue
				elif numeric_entry.get_base_value() > final_value:
					color = "red"
					replacement = "[color={0}]{1}[/color]".format([color, final_value])
				elif numeric_entry.get_base_value() < final_value:
					color = "green"
					replacement = "[color={0}]{1}[/color]".format([color, final_value])
				ret = ret.replace("{" + placeholder + "}", replacement)
	return ret.format(numeric_dict)
	
func get_default_description() -> String:
	var dict := {}
	for entry: NumericEntry in numeric_entries:
		dict[entry.placeholder] = entry.numeric_provider.fixed_value
		
	return description.format(dict)



func _get_numeric_value(entry: NumericEntry, player: Player = null, target_: Creature = null) -> int:
	var card_context := {
		"player": player,
		"card": self,
		"target": target_
	}
	var value = entry.numeric_provider.get_value(null, card_context)
	if entry.numeric_formula:
		value += entry.numeric_formula.calculate(target_)
	return value
	
func get_numeric_value(entries: NumericEntry, player: Player = null, targets: Creature = null) -> int:
	return _get_numeric_value(entries, player, targets)
