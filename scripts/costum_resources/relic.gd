class_name Relic
extends Resource

# 只管战斗中的触发,其他信号在脚本中实现
enum TriggerType {
	NONE,
	START_OF_TURN,
	START_OF_COMBAT,
	END_OF_TURN,
	END_OF_COMBAT,
}

enum COLOR {
	RED = 0b000001,	# 铁甲战士
	GREEN = 0b000010,	# 静默猎手
	ORANGE = 0b000100, # 储君
	PINK = 0b001000,	# 亡灵契约师
	BLUE = 0b010000,	# 故障机器人
	COLORLESS = 0b100000, # 无色
}
enum Rarity{
	COMMON = 0b0000001,
	UNCOMMON = 0b0000010,
	RARE = 0b0000100,
	STARTER_RELIC = 0b0001000,
	SHOP_RELIC = 0b0010000,
	ANCIENT_RELIC = 0b0100000,
	EVENT = 0b1000000
}
@export var relic_name: String
@export var id: String
@export var icon: Texture
@export_multiline var description: String
@export var trigger_type: TriggerType
@export var relic_color: COLOR = COLOR.COLORLESS
@export var rarity: Rarity = Rarity.COMMON

@export var effects: Array[Effect]

# 计数器(保存计数器防止继续游戏再次刷新)
@export var count: int = 0

func initialize_relic(_owner: RelicUI) -> void:
	pass

func on_picked_up(_run_stats: RunStats, _char_stats: CharacterStats, _select_deck_view: DeckView) -> void:
	pass

func activate_relic(owner: RelicUI) -> void:
	var player = owner.get_tree().get_first_node_in_group("ui_player")
	# 没有指向性的遗物，所以targets为空
	var relic_context = {"player": player, "targets": []}
	(player as Player).combat_resolver.execute(ResolutionEntry.new(self, effects, relic_context, func(): owner.flash()))
	
# 只有基于事件的遗物需要实现这个方法
# 方法的目的是解除绑定的信号
# 事实上每次新增遗物时会复制一份遗物资源,relicUI被清除时资源也会被清除
# 所以这个函数至少为了保险
func deactivate_relic(_owner: RelicUI) -> void:
	pass

#func can_appear_as_reward(character: CharacterStats, drop_type: Relic.RelicType) -> bool:
	#if (drop_type & relic_type) == 0:
		#return false
	## 有点丑陋
	#match character.character_name:
		#"铁甲战士":
			#return (relic_type == CharacterType.IRON_CLAD) or (relic_type == CharacterType.COLORLESS)
		#"静默猎手":
			#return (relic_type == CharacterType.SILENT) or (relic_type == CharacterType.COLORLESS)
		#_:
			#return false 
	
#debug
func can_appear_as_reward(character: CharacterStats, drop_type: Relic.Rarity) -> bool:
	#print("检查遗物: ", relic_name)
	#print("  relic_type = ", relic_type, " (二进制: ", ("%04b" % relic_type), ")")
	#print("  drop_type  = ", drop_type, " (二进制: ", ("%04b" % drop_type), ")")
	#print("  位与结果   = ", drop_type & relic_type)
	
	if (drop_type & rarity) == 0:
		#print("  -> 失败：遗物不包含 SHOP_RELIC 标记")
		return false
	
	#print("  character_type = ", character_type)
	#print("  当前角色: ", character.character_name)

	match character.color:
		CharacterStats.COLOR.RED:
			var valid = (relic_color == COLOR.RED) or (relic_color == COLOR.COLORLESS)
			#print("  -> 角色匹配结果: ", valid)
			return valid
		CharacterStats.COLOR.GREEN:
			var valid = (relic_color == COLOR.RED) or (relic_color == COLOR.COLORLESS)
			#print("  -> 角色匹配结果: ", valid)
			return valid
		_:
			#print("  -> 未知角色，默认返回 false")
			return false
