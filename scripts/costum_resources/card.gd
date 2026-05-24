class_name Card
extends Resource
# 卡牌类型(攻击，技能，能力)

enum Type {
	ATTACK = 0b00001, 
	SKILL = 0b00010, 
	POWER = 0b00100, 
	STATUS = 0b01000, 
	CURSE = 0b10000
	}
# 卡牌目标类型
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}
# 卡牌稀有度
enum Rarity {
	COMMON = 0b00001, 
	UNCOMMON = 0b00010, 
	RARE = 0b00100, 
	CURSED = 0b01000, 
	STATUS = 0b10000
	}
# 卡牌所属卡牌池
enum COLOR {
	RED = 0b0000001,	# 铁甲战士
	GREEN = 0b0000010,	# 静默猎手
	ORANGE = 0b0000100, # 储君
	PINK = 0b0001000,	# 亡灵契约师
	BLUE = 0b0010000,	# 故障机器人
	CURSE = 0b0100000,  # 诅咒
	COLORLESS = 0b1000000, # 无色
}

## TODO: 使用表格而不是使用资源文件存储数据
@export_group("卡牌属性")
## 卡牌名称
@export var id: String
## 卡牌类型
@export var type: Type = Type.ATTACK
## 目标类型
@export var base_target: Target
## 卡牌属于那个角色池，详情见COLOR枚举
@export var card_color: COLOR = COLOR.RED
@export var is_x_cost: bool = false
@export var base_cost: int
@export var rarity: Rarity = Rarity.COMMON
# 是否可以被发现
@export var discoverable: bool = true
# 是否可作为卡牌奖励
@export var draftable: bool = true
@export var enchantment: Enchantment = null
# 卡牌效果列表
@export var effects: Array[Effect]
@export_group("卡牌描述")
@export var portrait: Texture
@export_multiline var base_description: String
@export var base_numeric_entries: Array[NumericEntry]
# 注意这两个可以动态生成的词条不能在卡牌描述中写死
# 是否带“消耗“词条
@export var exhaust: bool
# 是否带”虚无“词条
@export var ethereal: bool
# 是否带有"奇巧"词条
@export var sly: bool
# 是否带有“永恒”词条
@export var eternal: bool = false
@export var playable : bool = true
# 升级后
@export_group("升级后")
@export var upgraded_target: Target
@export var upgraded_cost: int
@export_multiline var upgraded_description: String
@export var upgraded_numeric_entries: Array[NumericEntry]
# 升级后卡牌效果列表
@export var upgraded_effects: Array[Effect]
@export var upgraded: bool = false
@export var upgradable: bool = true

var first_play_free := false

var card_played_this_combat: int = 0

func get_final_values(source_: Creature, target_: Creature) -> Dictionary:
	var ret = {}
	for entry: NumericEntry in get_numeric_entries():
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
		if enchantment:
			modifiers = NumericHelper.combine_modifiers(modifiers, enchantment.get_modifiers_by_type(entry.numeric_type))
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
	targets = _get_targets(source, targets) if get_target() != Target.SINGLE_ENEMY else targets
	var energy_cost = 0 if first_play_free else get_cost()
	if is_x_cost:
		energy_cost = source.stats.energy
	var card_context := {
		"player": source,
		"card": self,
		"targets": targets,
		"energy_cost": energy_cost
	}
	#CombatResolver.push_card(self,  card_context)
	#var previous_result = null
	#for effect:Effect in get_effects():
		#previous_result = await effect.execute(source, card_context, previous_result)
	#if enchantment:
		#enchantment.on_play(source, targets)
	#Events.card_played.emit(self)
	#CombatResolver.push_card(self, card_context)
	Events.before_card_played.emit(self, card_context)
	if no_callback:
		source.combat_resolver.execute(ResolutionEntry.new(self, get_effects(), card_context, func(): 
			on_played(source, targets)
			)
		)
	else:
		source.combat_resolver.execute(ResolutionEntry.new(self, get_effects(), card_context, \
		func(): 
			Events.card_played.emit(self, card_context)
			on_played(source, targets)
			)
		)
		source.use_energy(energy_cost)
	first_play_free = false

func on_played(source: Player, targets: Array[Node]) -> void:
	card_played_this_combat += 1
	if enchantment:
		enchantment.on_play(source, targets)

func apply_effects(_source: Player, _targets: Array[Node]) -> void:
	pass

func is_single_targeted() -> bool:
	return get_target() == Target.SINGLE_ENEMY

func _get_targets(source: Player, targets: Array[Node]) -> Array[Node]:
	var ret: Array[Node] = targets
	if not targets or targets.is_empty():
		printerr("card出错")
		return []
	# 资源没有获取场景树的方法
	var tree := targets[0].get_tree()
	match get_target():
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
	var ret: String = _get_default_description()
	for placeholder: String in numeric_dict.keys():
		final_value = numeric_dict[placeholder]
		replacement = str(final_value)
		for numeric_entry in get_numeric_entries():
			if numeric_entry.placeholder == placeholder:
				if numeric_entry.get_base_value({"card": self}) == final_value:
					continue
				elif numeric_entry.get_base_value({"card": self}) > final_value:
					color = "red"
					replacement = "[color={0}]{1}[/color]".format([color, final_value])
				elif numeric_entry.get_base_value({"card": self}) < final_value:
					color = "green"
					replacement = "[color={0}]{1}[/color]".format([color, final_value])
				ret = ret.replace("{" + placeholder + "}", replacement)
	return append_features(ret).format(numeric_dict)
	
func get_default_description() -> String:
	var dict := {}
	for entry: NumericEntry in get_numeric_entries():
		dict[entry.placeholder] = entry.get_base_value({"card": self})
		
	return append_features(_get_default_description()).format(dict)

func get_title() -> String:
	return "[color=green]" + id + "+[/color]" if upgraded else id

func append_features(desc: String) -> String:
	if exhaust:
		desc += "[p][center][color=gold]消耗。[/color][/center]"
	if ethereal:
		desc += "[p][center][color=gold]虚无。[/color][/center]"
	if eternal:
		desc += "[p][center][color=gold]永恒。[/color][/center]"
	if enchantment:
		desc += enchantment.get_additional_card_description()
	return desc

func upgrade() -> void:
	if upgradable:
		upgraded = true

func get_numeric_entries() -> Array[NumericEntry]:
	return upgraded_numeric_entries if upgraded else base_numeric_entries

func get_effects() -> Array[Effect]:
	return upgraded_effects if upgraded else effects

func _get_numeric_value(entry: NumericEntry, player: Player = null, target: Creature = null) -> int:
	var card_context := {
		"player": player,
		"card": self,
		"target": target
	}
	var value = entry.numeric_provider.get_value(null, card_context)
	if entry.numeric_formula:
		value += entry.numeric_formula.calculate(target)
	return value
	

func get_numeric_value(entries: NumericEntry, player: Player = null, targets: Creature = null) -> int:
	return _get_numeric_value(entries, player, targets)

func get_enchantment_modifiers(entry: NumericEntry) -> Array:
	if has_enchantment():
		return enchantment.get_modifiers_by_type(entry.type)
	return []

func _get_default_description() -> String:
	return upgraded_description if upgraded else base_description

func get_cost() -> int:
	return upgraded_cost if upgraded else base_cost

func get_target() -> Target:
	return upgraded_target if upgraded else base_target

func has_enchantment() -> bool:
	return !(enchantment == null)

func set_echantment(enchantment_: Enchantment) -> void:
	enchantment = enchantment_
	enchantment.on_enchant_set(self)

func can_be_upgraded() -> bool:
	return upgradable and !upgraded

func can_be_removed() -> bool:
	return !eternal
	
func has_highlight_condition(player: Node, target: Node) -> bool:
	for effect: Effect in effects:
		if effect is ConditionalEffect:
			return effect.is_condition_met(player, target)
	return false

func has_attack_effect() -> bool:
	return _has_attack_effect(get_effects())

func _has_attack_effect(card_effects: Array[Effect]) -> bool:
	for effect in card_effects:
		if effect is AttackEffect:
			return true
		if effect is IterationEffect:
			if _has_attack_effect(effect.effects):
				return true
		if effect is ConditionalEffect:
			if _has_attack_effect(effect.if_effects) or _has_attack_effect(effect.else_effects):
				return true
		# 不管while_effect
		# foreach是卡牌相关的，也不需要管
	return false

func has_block_effect() -> bool:
	return _has_block_effect(get_effects())

func _has_block_effect(card_effects: Array[Effect]) -> bool:
	for effect in card_effects:
		if effect is BlockEffect:
			return true
		if effect is IterationEffect:
			if _has_block_effect(effect.effects):
				return true
		if effect is ConditionalEffect:
			if _has_block_effect(effect.if_effects) or _has_block_effect(effect.else_effects):
				return true
		# 不管while_effect
		# foreach是卡牌相关的，也不需要管
	return false



##卡牌数据序列化
func serialize() -> Dictionary:
	return {
		"resource_path": resource_path,  
		"id": id,
		"upgraded": upgraded,
		"upgradable": upgradable,
		"card_color": card_color,
		"first_play_free": first_play_free,
		"card_played_this_combat": card_played_this_combat,
	}

static func deserialize(data: Dictionary) -> Card:
	var card_id: String = data.get("id", "")
	if card_id.is_empty():
		push_error("Card.deserialize: id missing")
		return null

	# 从 ItemPool（全局单例）获取原型
	var base: Card = ItemPool.cards_by_id.get(card_id, null)
	if not base:
		push_error("Card.deserialize: card not found for id " + card_id)
		return null

	var card: Card = base.duplicate()
	card.upgraded = data.get("upgraded", false)
	card.upgradable = data.get("upgradable", true)
	card.card_color = data.get("card_color", Card.COLOR.RED)
	card.first_play_free = data.get("first_play_free", false)
	card.card_played_this_combat = data.get("card_played_this_combat", 0)
	return card
