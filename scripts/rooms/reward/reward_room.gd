class_name BattleReward
extends Control

#relic暂时不删
enum Type {GOLD, NEW_CARD, RELIC}

const CARD_REWARDS=preload("res://scenes/rooms/reward/card_rewards.tscn")

const CARD_MENU_UI = preload("res://scenes/ui/card_menu_ui.tscn")

const REWARD_BUTTON=preload("res://scenes/rooms/reward/reward_button.tscn")
const GOLD_ICON:= preload("res://images/ui/reward_screen/reward_icon_money.png")
const GOLD_TEXT := "%s gold"
const CARD_ICON:= preload("res://images/ui/reward_screen/reward_icon_card.png")
const CARD_TEXT :="Add New Card"

@export var run_stats: RunStats
@export var character_stats:CharacterStats

@onready var rewards:VBoxContainer =%rewards
@onready var return_button := $Loot/Button

# 遗物稀有度权重（总和影响概率分布）
@export var relic_common_weight := 6.0
@export var relic_uncommon_weight := 3.0
@export var relic_rare_weight := 1.0

# 药水稀有度权重（若药水无稀有度可删除）
@export var potion_common_weight := 6.0
@export var potion_uncommon_weight := 3.0
@export var potion_rare_weight := 1.0

var card_reward_total_weight :=8.8
var card_rarity_weights :={
	Card.Rarity.COMMON:0.0,
	Card.Rarity.UNCOMMON: 0.0,
	Card.Rarity.RARE:0.0
}


func _ready()->void:
	for node:Node in rewards.get_children():
		node.queue_free()

	if run_stats:
		run_stats.gold_changed.connect(func(): print("gold:%s" % run_stats.gold))
	return_button.mouse_entered.connect(_on_return_button_entered)
	return_button.mouse_exited.connect(_on_return_button_exited)
	
	#add_gold_reward(77)
	#add_card_reward()

func add_rewards(room: Room, context: RewardContext) -> void:
	if room.enemy_encounter.type == EnemyEncounter.Type.BOSS:
		context.all_rare = true
		context.extra_relic_count += 1
	elif room.enemy_encounter.type == EnemyEncounter.Type.ELITE:
		context.extra_relic_count += 1
	
	
	_randomize_extra_potion_rewards(room,context)
	print("额外遗物数量: ", context.extra_relic_count)
	print("额外药水数量: ", context.extra_potion_count)	
	print("相关金币数量: ",context.extra_gold)
	print("相关卡牌数量: ",context.extra_card_count)
	add_gold_reward(room.enemy_encounter.roll_gold_reward())
	add_card_reward(context)

	# 额外卡牌
	for i in range(context.extra_card_count):
		add_card_reward(context)

	# 额外药水
	for i in range(context.extra_potion_count):
		var potion = _get_random_weighted_potion()
		if potion:
			add_potion_reward(potion)

	# 额外遗物
	for i in range(context.extra_relic_count):
		var relic = _get_random_weighted_relic()
		if relic:
			add_relic_reward(relic)

	# 额外金币
	for extra_gold in context.extra_gold:
		add_gold_reward(extra_gold)
		

	

func _on_return_button_entered():
	return_button.scale = Vector2(1.1, 1.1)

func _on_return_button_exited():
	return_button.scale = Vector2(1, 1)
	
func add_gold_reward(amount: int) -> void:
	var gold_reward := REWARD_BUTTON.instantiate() as RewardButton
	gold_reward.reward_icon = GOLD_ICON
	gold_reward.reward_text = GOLD_TEXT % amount
	gold_reward.pressed.connect(_on_gold_reward_taken.bind(gold_reward, amount))
	# 保存数据
	gold_reward.set_meta("reward_type", "gold")
	gold_reward.set_meta("amount", amount)
	rewards.add_child.call_deferred(gold_reward)


func add_potion_reward(potion: Potion) -> void:
	var potion_reward := REWARD_BUTTON.instantiate() as RewardButton
	potion_reward.reward_icon = potion.icon
	potion_reward.reward_text = potion.potion_name
	potion_reward.pressed.connect(
		func():
			if _is_potion_slot_full():
				_play_shake_feedback(potion_reward)
			else:
				if run_stats: run_stats.add_potion(potion)
				potion_reward.queue_free()
	)
	# add_potion_reward
	potion_reward.set_meta("reward_type", "potion")
	potion_reward.set_meta("potion_name", potion.potion_name) 
	rewards.call_deferred("add_child", potion_reward)

func add_relic_reward(relic: Relic) -> void:
	var relic_reward := REWARD_BUTTON.instantiate() as RewardButton
	relic_reward.reward_icon = relic.icon
	relic_reward.reward_text = relic.relic_name
	relic_reward.pressed.connect(
		func():
			if run_stats: run_stats.add_relic(relic)
			relic_reward.queue_free()
	)
	relic_reward.set_meta("reward_type", "relic")
	relic_reward.set_meta("relic_id", relic.id)
	rewards.call_deferred("add_child", relic_reward)
	
func _on_gold_reward_taken(gold_reward:RewardButton,amount: int) -> void:
	if not run_stats:
		return
	run_stats.gold += amount
	gold_reward.queue_free()

#回退
func _on_button_pressed() -> void:
	Events.combat_reward_exited.emit()

func add_card_reward(context: RewardContext) -> void:
	var card_reward := REWARD_BUTTON.instantiate() as RewardButton
	card_reward.reward_icon = CARD_ICON
	card_reward.reward_text = CARD_TEXT
	card_reward.pressed.connect(_show_card_rewards.bind(card_reward, context))
	# 保存 context 的关键信息
	card_reward.set_meta("reward_type", "card")
	card_reward.set_meta("context", {
		"all_rare": context.all_rare,
		"all_uncommon": context.all_uncommon,
		"all_common": context.all_common,
		"upgrade_all": context.upgrade_all,
		"upgrade_attack": context.upgrade_attack,
		"upgrade_skill": context.upgrade_skill,
		"upgrade_power": context.upgrade_power,
		# 如果有其他字段也一并保存
	})
	rewards.add_child.call_deferred(card_reward)
	
func _show_card_rewards(card_reward:RewardButton,context: RewardContext)->void:
	if not run_stats or not character_stats:
		return
	var card_rewards := CARD_REWARDS.instantiate() as CardRewards
	add_child(card_rewards)
	card_rewards.card_reward_selected.connect(_on_card_reward_taken)
	card_reward.queue_free()
	
	var card_reward_array:Array[Card]=[]
	#var available_cards:Array[Card]=character_stats.draftable_cards.cards.duplicate(true)
	var available_cards: Array[Card]
	if context.all_colorless:
		available_cards = ItemPool.get_draftable_cards_by_color(Card.COLOR.COLORLESS)
	else:
		available_cards = ItemPool.current_card_pool
	if context.all_rare:
		for i in run_stats.card_rewards:
			var picked_card:=_get_random_available_card(available_cards, Card.Rarity.RARE)
			available_cards.erase(picked_card)
			picked_card = picked_card.duplicate()
			match picked_card.type:
				Card.Type.ATTACK:
					if context.upgrade_all or context.upgrade_attack:
						picked_card.upgrade()
				Card.Type.SKILL:
					if context.upgrade_all or context.upgrade_skill:
						picked_card.upgrade()
				Card.Type.POWER:
					if context.upgrade_all or context.upgrade_power:
						picked_card.upgrade()
						
			card_reward_array.append(picked_card)
	elif context.all_uncommon:
		for i in run_stats.card_rewards:
			var picked_card:=_get_random_available_card(available_cards, Card.Rarity.UNCOMMON)
			available_cards.erase(picked_card)
			picked_card = picked_card.duplicate()	
			match picked_card.type:
				Card.Type.ATTACK:
					if context.upgrade_all or context.upgrade_attack:
						picked_card.upgrade()
				Card.Type.SKILL:
					if context.upgrade_all or context.upgrade_skill:
						picked_card.upgrade()
				Card.Type.POWER:
					if context.upgrade_all or context.upgrade_power:
						picked_card.upgrade()
						
			card_reward_array.append(picked_card)
	elif context.all_common:
		_modify_weights(Card.Rarity.RARE)
		for i in run_stats.card_rewards:
			var picked_card:=_get_random_available_card(available_cards, Card.Rarity.COMMON)
			available_cards.erase(picked_card)
			picked_card = picked_card.duplicate()
			match picked_card.type:
				Card.Type.ATTACK:
					if context.upgrade_all or context.upgrade_attack:
						picked_card.upgrade()
				Card.Type.SKILL:
					if context.upgrade_all or context.upgrade_skill:
						picked_card.upgrade()
				Card.Type.POWER:
					if context.upgrade_all or context.upgrade_power:
						picked_card.upgrade()
						
			card_reward_array.append(picked_card)	
	else:	
		for i in run_stats.card_rewards:
			_setup_card_chances()
			var roll:=RandomSetting.instance.randf_range(0.0,card_reward_total_weight)
			for rarity:Card.Rarity in card_rarity_weights:
				if card_rarity_weights[rarity]>roll:
					_modify_weights(rarity)
					var picked_card:=_get_random_available_card(available_cards,rarity)
					available_cards.erase(picked_card)
					picked_card = picked_card.duplicate()
					match picked_card.type:
						Card.Type.ATTACK:
							if context.upgrade_all or context.upgrade_attack:
								picked_card.upgrade()
						Card.Type.SKILL:
							if context.upgrade_all or context.upgrade_skill:
								picked_card.upgrade()
						Card.Type.POWER:
							if context.upgrade_all or context.upgrade_power:
								picked_card.upgrade()
					
					card_reward_array.append(picked_card)
					break
	card_rewards.rewards=card_reward_array
	card_rewards.show()

func _setup_card_chances()->void:

	card_reward_total_weight=run_stats.common_weight +run_stats.uncommon_weight+run_stats.rare_weight
	card_rarity_weights[Card.Rarity.COMMON]=run_stats.common_weight
	card_rarity_weights[Card.Rarity.UNCOMMON]=run_stats.common_weight+run_stats.uncommon_weight
	card_rarity_weights[Card.Rarity.RARE]=card_reward_total_weight
	
	
func _modify_weights(rarity_rolled:Card.Rarity)->void:
	if rarity_rolled== Card.Rarity.RARE:
		run_stats.rare_weight =RunStats.BASE_RARE_WEIGHT
	else:
		run_stats.rare_weight=clampf(run_stats.rare_weight+0.3,run_stats.BASE_RARE_WEIGHT,5.0)
		

func _get_random_available_card(available_cards:Array[Card],with_rarity:Card.Rarity)->Card:
	var all_possible_cards := available_cards.filter(
		func(card: Card) -> bool:
			return card.rarity == with_rarity
	)
	if all_possible_cards.is_empty():
		printerr("No card of rarity %s available" % Card.Rarity.keys()[with_rarity])
		# 降级：如果可用卡牌非空，返回任意一张卡牌（可选）
		if not available_cards.is_empty():
			return RandomSetting.array_pick_random(available_cards)
		return null
	return RandomSetting.array_pick_random(all_possible_cards)
	
func _on_card_reward_taken(card:Card)->void:
	if not character_stats or not card:
		return
	#print("DeckBefore:\n%s\n" % character_stats.deck)
	character_stats.add_card_to_deck(card)
	#print("DeckAfter:\n%s" % character_stats.deck)

func _get_random_weighted_relic() -> Relic:
	#if not ItemPool.current_relic_pool or ItemPool.current_relic_pool.is_empty():
		#return null

	# 计算总权重
	var total_weight = relic_common_weight + relic_uncommon_weight + relic_rare_weight
	var roll = randf() * total_weight

	var target_rarity: int
	if roll < relic_common_weight:
		target_rarity = Relic.Rarity.COMMON
	elif roll < relic_common_weight + relic_uncommon_weight:
		target_rarity = Relic.Rarity.UNCOMMON
	else:
		target_rarity = Relic.Rarity.RARE

	# 从当前池中筛选出该稀有度的遗物
	var candidates := ItemPool.current_relic_pool.filter(
		func(r: Relic): return r.rarity == target_rarity
	)
	if candidates.is_empty():
		# 降级：如果没有该稀有度的遗物，从整个池随机
		candidates = ItemPool.get_current_relic_pool()
	return candidates.pick_random().duplicate()

func _get_random_weighted_potion() -> Potion:
	if not ItemPool.current_potion_pool or ItemPool.current_potion_pool.is_empty():
		return null

	var total_weight = potion_common_weight + potion_uncommon_weight + potion_rare_weight
	var roll = randf() * total_weight

	var target_rarity: int
	if roll < potion_common_weight:
		target_rarity = Potion.Rarity.COMMON
	elif roll < potion_common_weight + potion_uncommon_weight:
		target_rarity = Potion.Rarity.UNCOMMON
	else:
		target_rarity = Potion.Rarity.RARE

	var candidates := ItemPool.current_potion_pool.filter(
		func(p: Potion): return p.rarity == target_rarity
	)
	if candidates.is_empty():
		candidates = ItemPool.current_potion_pool
	return candidates.pick_random().duplicate()

func _randomize_extra_potion_rewards(room: Room, context: RewardContext) -> void:
	var chance: float = 0.0
	var bonus_amount: int = 0

	match room.enemy_encounter.type:
		EnemyEncounter.Type.WEAK:
			chance = 0.3       # 10% 概率
			bonus_amount = 1
		EnemyEncounter.Type.STRONG:
			chance = 0.5       # 30% 概率
			bonus_amount = 1
		EnemyEncounter.Type.ELITE:
			chance = 0.7
			bonus_amount = 1
		EnemyEncounter.Type.BOSS:
			chance = 1.0
			bonus_amount = 2

	# 可在此处考虑遗物加成（如“药水腰带”使概率翻倍等），暂时省略

	if randf() < chance:
		context.extra_potion_count += bonus_amount
		print("幸运！额外获得药水 x%d" % bonus_amount)


func _play_shake_feedback(btn: Control) -> void:
	var orig_x = btn.position.x
	var t := create_tween()
	t.tween_property(btn, "position:x", orig_x - 8, 0.05)
	t.tween_property(btn, "position:x", orig_x + 8, 0.05)
	t.tween_property(btn, "position:x", orig_x, 0.05)
	# 可同时加短暂红色闪烁
	btn.modulate = Color.RED
	t.tween_callback(func(): btn.modulate = Color.WHITE)

func _is_potion_slot_full() -> bool:
	return run_stats.potions.back() != null;


func get_save_state() -> Dictionary:
	var state := {"rewards": []}
	for btn in rewards.get_children():
		if btn is RewardButton:
			var r_type = btn.get_meta("reward_type", "")
			var r_data = {}
			match r_type:
				"gold":
					r_data["amount"] = btn.get_meta("amount", 0)
				"potion":
					r_data["potion_name"] = btn.get_meta("potion_name", "")
				"relic":
					r_data["relic_id"] = btn.get_meta("relic_id", "")
				"card":
					r_data["context"] = btn.get_meta("context", {})
			state["rewards"].append({"type": r_type, "data": r_data})
	return state

func set_save_state(state: Dictionary) -> void:
	# 清除现有奖励（_ready 已经清过，但以防万一）
	for node in rewards.get_children():
		node.queue_free()
	# 等待一帧让节点释放
	await get_tree().process_frame
	
	for r in state.get("rewards", []):
		var r_type = r["type"]
		var data = r["data"]
		match r_type:
			"gold":
				add_gold_reward(data["amount"])
			"potion":
				var potion = _get_potion_by_name(data.get("potion_name", ""))
				if potion: add_potion_reward(potion)
			"relic":
				var relic = _get_relic_by_id(data.get("relic_id", ""))
				if relic: add_relic_reward(relic)
			"card":
				# 从字典重建 RewardContext
				var ctx = RewardContext.new()
				ctx.all_rare = data["context"].get("all_rare", false)
				ctx.all_uncommon = data["context"].get("all_uncommon", false)
				ctx.all_common = data["context"].get("all_common", false)
				ctx.upgrade_all = data["context"].get("upgrade_all", false)
				ctx.upgrade_attack = data["context"].get("upgrade_attack", false)
				ctx.upgrade_skill = data["context"].get("upgrade_skill", false)
				ctx.upgrade_power = data["context"].get("upgrade_power", false)
				# 其他字段如有需要同样赋值
				add_card_reward(ctx)


func _get_relic_by_id(relic_id: String) -> Relic:
	for r in ItemPool.current_relic_pool:
		if r.id == relic_id:
			return r
	return null

func _get_potion_by_name(potion_name: String) -> Potion:
	for p in ItemPool.current_potion_pool:
		if p.potion_name == potion_name:
			return p
	return null


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event() 
