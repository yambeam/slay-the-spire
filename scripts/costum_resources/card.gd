class_name Card
extends Resource

# 卡牌类型(攻击，技能，能力)
enum Type {ATTACK, SKILL, POWER}
# 卡牌目标类型
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

## TODO: 使用表格而不是使用资源文件存储数据
@export_group("卡牌属性")
@export var id: String
@export var type: Type
@export var target: Target
@export var cost: int
@export_group("卡牌描述")
@export var portrait: Texture
@export_multiline var description: String

func is_single_targetd() -> bool:
	return target == Target.SINGLE_ENEMY
