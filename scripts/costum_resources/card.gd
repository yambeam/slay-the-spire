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

func play(targets: Array[Node], char_stats: CharacterStats) -> void:
	Events.card_played.emit(self)
	char_stats.energy -= cost
	if is_single_targeted():
		apply_effects(targets)
	else:
		apply_effects(_get_targets(targets))

func apply_effects(_targets) -> void:
	pass

func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets or targets.is_empty():
		printerr("card出错")
		return []
	# 资源没有获取场景树的方法
	var tree := targets[0].get_tree()
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("ui_player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("ui_enemies")
		Target.EVERYONE:
			return tree.get_nodes_in_group("ui_player") + tree.get_nodes_in_group("ui_enemies")
		_:
			# 对于SingleTargeted,使用TargetSelector获取目标
			printerr("card出错")
			return []
