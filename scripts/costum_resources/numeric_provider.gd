class_name NumericProvider
extends Resource

enum SourceType{
	FIXED,	# 固定值
	PREVIOUS_RESULT, # 上一个effect的结果
	PLAYER_BLOCK, # 根据玩家格挡
	PLAYER_BUFF_STACK,
	CARD_COUNT_BY_NAME, # 根据卡牌数量
	ATTACK_PLAYED_THIS_TURN, # 根据本回合打出的攻击牌
	SKILL_PLAYED_THIS_TURN,
	ENERGY_USED_THIS_TURN,
	PLAYER_MAX_HEALTH, # 玩家最大生命
	ENERGY_COST, # 卡牌消耗的能量
	CARD_PLAYED_THIS_COMBAT, # 这张卡牌在本场战斗的打出次数
	CARD_COUNT_IN_EXHAUST_PILE, # 消耗堆卡牌数量
	HEALTH_LOSE_TIMES_THIS_COMBAT, # 本场战斗失去生命次数
	PLAYER_HAND_COUNT, # 玩家手牌数,
	PLAYER_HIT_THIS_COMBAT, # 本场战斗受到的伤害次数
	CUSTOM, # 自定义（应该不需要这么复杂的东西，暂时不实现
}

@export var type: SourceType = SourceType.FIXED
@export var fixed_value: int = 0
@export var multipiler: float = 1.0
@export var additive: int = 0
@export var extra_params :Dictionary = {}

func _init(fixed_value_: int = 0, multiplier_: float = 1.0, additive_: int = 0, type_: SourceType = SourceType.FIXED, extra_params_ := {}) -> void:
	fixed_value = fixed_value_
	multipiler = multiplier_
	additive = additive_
	type = type_
	extra_params = extra_params_

func get_value(previous_result: Variant = null, context: Dictionary = {}) -> int:
	match type:
		SourceType.FIXED:
			return _get_value(0)
		SourceType.PREVIOUS_RESULT:
			return _get_value(previous_result) if typeof(previous_result) == TYPE_INT else 0
		SourceType.PLAYER_BLOCK:
			var player: Player = context.get("player")
			if player:
				return _get_value(player.get_block())
		SourceType.PLAYER_BUFF_STACK:
			var player: Player = context.get("player")
			if player:
				var buff : Buff = player.get_buff(extra_params.get("player_buff_name", ""))
				return _get_value(buff.stacks) if buff else 0
		SourceType.CARD_COUNT_BY_NAME:
			var player: Player = context.get("player")
			var card: Card = context.get("card")
			if player and card:
				return _get_value(player.get_card_count_by_name(extra_params.get("card_name", ""), card))
		SourceType.ATTACK_PLAYED_THIS_TURN:
			var player: Player = context.get("player")
			if player:
				return _get_value(player.attack_played_this_turn)
		SourceType.SKILL_PLAYED_THIS_TURN:
			var player: Player = context.get("player")
			if player:
				return _get_value(player.skill_played_this_turn)
		SourceType.ENERGY_USED_THIS_TURN:
			var player: Player = context.get("player")
			if player:
				return _get_value(player.energy_used_this_turn)
		SourceType.PLAYER_MAX_HEALTH:
			var player: Player = context.get("player")
			if player:
				return _get_value(player.stats.max_health)
		SourceType.ENERGY_COST:
			var energy_cost: int = context.get("energy_cost")
			if energy_cost:
				return _get_value(energy_cost)
		SourceType.CARD_PLAYED_THIS_COMBAT:
			var card: Card = context.get("card")
			if card:
				return _get_value(card.card_played_this_combat)
		SourceType.CARD_COUNT_IN_EXHAUST_PILE:
			var player: Player = context.get("player")
			if player:
				return _get_value(len(player.stats.get_exhaust_pile()))
		SourceType.HEALTH_LOSE_TIMES_THIS_COMBAT:
			var player: Player = context.get("player")
			if player:
				return _get_value(player.health_lose_times_this_combat)
		SourceType.PLAYER_HAND_COUNT:
			var player: Player = context.get("player")
			if player:
				return _get_value(len(player.get_hand_cards()))
		SourceType.PLAYER_HIT_THIS_COMBAT:
			var player: Player = context.get("player")
			if player:
				return _get_value(player.player_hit_this_combat)
		SourceType.CUSTOM:
			printerr("未实现")
			return 0
	return fixed_value

func _get_value(base_value: int) -> int:
	return fixed_value + int(multipiler * (base_value + additive))
