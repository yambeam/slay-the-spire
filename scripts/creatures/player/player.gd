class_name Player
extends Creature

# 玩家专属信号
signal before_draw_card(context: DrawCardContext)
signal after_draw_card(context: DrawCardContext)

@export var stats: CharacterStats : set = _set_char_stats
@export var hand_selector: HandSelector
@export var deck_view: DeckView
@export var discover_view: DiscoverCardView
@export var agent: PlayerHandler
@export var combat_resolver: CombatResolver

@onready var hitbox: CollisionShape2D = $CollisionShape2D

var visuals: CreatureVisuals
var spine_manager: SpineManager

# 本回合打出攻击牌的数量
var attack_played_this_turn := 0
var skill_played_this_turn := 0
var energy_used_this_turn := 0
var health_lost_times_this_turn := 0
var card_exhausted_this_turn := 0
var health_lose_times_this_combat := 0
var player_hit_this_combat := 0


var dead := false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	Events.card_played.connect(_on_card_played)
	Events.player_talked.connect(speech)
	Events.card_exhausted.connect(func(_card: Card):card_exhausted_this_turn += 1)
	
func speech(text: String, time: float = 2.5) -> void:
	speech_bubble.set_text(text, time)
	# speech_bubble是一个control没有offset属性，所以只能硬编码了
	speech_bubble.global_position = visuals.speech_point.global_position + Vector2(84, -81) * spine_manager.scale * 2
	#speech_bubble.global_position = hitbox.global_position + Vector2(hitbox.shape.size.x, -hitbox.shape.size.y / 2)
#func add_buff(buff_context: ApplyBuffContext) -> void:
	#buff_context.buff_node.stacks = buff_context.amount	
	#buff_manager.add_buff(buff_context)
	#var buff_ui := BUFF_UI.instantiate()
	#buff_ui.buff = buff_context.buff_node
	#buff_container.add_child(buff_ui)

func choice_for_cards(cards_to_choose: Array[Card], duplicate_card: bool = true) -> Card:
	var card: Card = await discover_view.select(cards_to_choose, false, false, false, duplicate_card)
	return card
	
func discover_card(context: DiscoverContext) -> void:
	var availabel_cards := ItemPool.get_discoverable_cards(context.color, context.type, context.rarity)
	availabel_cards.shuffle()
	# 随机三张
	var discovered_cards := availabel_cards.slice(0, 3)
	var card: Card = await discover_view.select(discovered_cards, context.can_skip, context.upgraded, context.first_play_free)
	if card:
		put_card_in_hand(card)
	
## 弃用
func choose_hand(context: ChooseCardContext) -> int:
	var selected: Array[Card]
	agent.hide_hand()
	agent.disable_hand()
	if context.max_select > 1:
		selected = await hand_selector.multi_select(context.cards as Array[Card], context.title, context.min_select, context.max_select)
	else:
		selected = await hand_selector.single_select(context.cards as Array[Card], context.title)
	for card: Card in selected:
		context.callback.call(card)
	agent.update_hand()
	agent.disable_hand(false)
	agent.show_hand()
	return len(selected)

func select_hand(context: SelectCardContext) -> Array[Card]:
	var selected: Array[Card]
	agent.hide_hand()
	agent.disable_hand()
	if context.max_select > 1:
		selected = await hand_selector.multi_select(context.cards as Array[Card], context.title, context.min_select, context.max_select)
	else:
		selected = await hand_selector.single_select(context.cards as Array[Card], context.title)
	agent.update_hand()
	agent.disable_hand(false)
	agent.show_hand()
	return selected
	
## 弃用
func chooose_deck(context: ChooseCardContext) -> int:
	var selected: Array[Card]
	selected = await deck_view.select_card_pile(context.cards, context.min_select, context.max_select, context.title, context.selection_mode)
	for card: Card in selected:
		context.callback.call(card)
	return len(selected)

func select_deck(context: SelectCardContext) -> Array[Card]:
	var selected: Array[Card]
	selected = await deck_view.select_card_pile(context.cards, context.min_select, context.max_select, context.title, context.selection_mode)
	return selected

func gain_block(context: Context) -> void:
	before_gain_block.emit(context)
	stats.block += context.get_final_value()

func get_block() -> int:
	return stats.block
	
func die() -> void:
	dead = true
	health_bar.hide()
	buff_container.hide()
	spine_anim_state.set_animation("die", false, 0)
	await spine_manager.animation_completed
	Events.player_died.emit()

func draw_card(context: DrawCardContext) -> Variant:
	before_draw_card.emit(context)
	var card: Card = null
	if context.amount != 0:
		card = agent.draw_card()
		context.card = card
		after_draw_card.emit(context)
		agent.add_card_to_hand(context.card)
	return card
	
#func draw_cards(context: DrawCardContext) -> void:
	#before_draw_cards.emit(context)
	#if context.amount > 0:
		#var tween = create_tween()
		#for i in range(context.amount):
			#tween.tween_callback(draw_card)
			#tween.tween_interval(0.2)
		#await tween.finished
		
func heal(context: HealContext) -> int:
	return context.target.gain_health(context)

func gain_health(context: HealContext) -> int:
	return stats.heal(context.amount)

func gain_max_health(context: GainMaxHealthContext) -> int:
	stats.max_health += context.amount
	gain_health(HealContext.new(context.source, context.target, context.amount))
	return context.amount
	
func gain_energy(context: GainEnergyContext) -> void:
	stats.energy += context.amount
	
	
func lose_health(context: Context) -> int:
	if stats.health <= 0:
		return 0
	
	before_lose_health.emit(context)
	stats.health -= context.amount
	after_lose_health.emit(context)
	if context.amount > 0:
		health_lost_times_this_turn += 1
		health_lose_times_this_combat += 1
	damage_number_spawner.spawn_damage_label(context.amount, false)

	if stats.health <= 0:
		die()
	else:
		Events.player_hit.emit()
		player_hit_this_combat += 1
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
	
	return context.amount

func take_damage(context: Context) -> int:
	if stats.health <= 0:
		return 0
	before_take_damage.emit(context)
	var final_value :int = context.get_final_value()
	var actual_damage := stats.take_damage(final_value)
	damage_number_spawner.spawn_damage_label(actual_damage, actual_damage == 0 and final_value != 0)
	after_take_damage.emit(context)
	if stats.health <= 0:
		die()
	elif actual_damage != 0:
		Events.player_hit.emit()
		player_hit_this_combat += 1
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
	return actual_damage

func take_damage_without_signals(amount: int) -> int:
	if stats.health <= 0:
		return 0
	var actual_damage := stats.take_damage(amount)
	damage_number_spawner.spawn_damage_label(actual_damage, actual_damage == 0 and amount != 0)
	if stats.health <= 0:
		die()
	elif actual_damage != 0:
		health_lost_times_this_turn += 1
		Events.player_hit.emit()
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
	return actual_damage


func put_card_in_discard_pile(card: Card) -> void:
	agent.put_card_in_discard_pile(card)

func put_card_in_draw_pile(card: Card, top:bool = false) -> void:
	agent.put_card_in_draw_pile(card, top)
	
func put_card_in_hand(card: Card) -> void:
	agent.put_card_in_hand(card)

func remove_card_in_discard_pile(card: Card) -> void:
	agent.remove_card_in_discard_pile(card)

func remove_card_in_draw_pile(card: Card) -> void:
	agent.remove_card_in_draw_pile(card)
	
func remove_card_in_hand(card: Card) -> void:
	agent.remove_card_in_hand(card)
	
func get_hand_cards() -> Array[Card]:
	return agent.get_hand()

func get_draw_pile() -> Array[Card]:
	return stats.get_draw_pile()

func get_discard_pile() -> Array[Card]:
	return stats.get_discard_pile()

func get_exhaust_pile() -> Array[Card]:
	return stats.get_exhaust_pile()

func get_card_count_by_name(card_name: String, base_card: Card) -> int:
	var all_cards: Array[Card] = get_hand_cards()
	all_cards.append_array(get_draw_pile())
	all_cards.append_array(get_discard_pile())
	# 将所有卡牌加起来，用filter函数筛选出id有name字符串卡牌然后获取数组长度
	
	return len(all_cards.filter(func(card: Card): 
		if card != base_card:
			return card.id.contains(card_name)
		else:
			return false
		)
	)

func discard_card(card: Card) -> void:
	agent.discard_card(card)
	
func exhaust_hand_card(card: Card) -> void:
	agent.exhaust_hand_card(card)

# TODO: 实现这两个方法
func exhaust_draw_pile_card(exhaust_card: Card) -> void:
	for card: Card in stats.get_draw_pile():
		if card == exhaust_card:
			stats.draw_pile.remove_card(card)
			stats.exhaust_pile.add_card(card)
			Events.card_exhausted.emit(card)
			return
			 
func exhaust_discard_pile_card(exhaust_card: Card) -> void:
	for card: Card in stats.get_discard_pile():
		if card == exhaust_card:
			stats.discard_pile.remove_card(card)
			stats.exhaust_pile.add_card(card)
			Events.card_exhausted.emit(card)
			return

func start_turn() -> void:
	before_turn_started.emit(self)
	stats.block = 0
	stats.energy = stats.max_energy
	
	health_lost_times_this_turn = 0
	attack_played_this_turn = 0
	skill_played_this_turn = 0
	energy_used_this_turn = 0
	card_exhausted_this_turn = 0
	
	after_turn_started.emit(self)

func end_turn() -> void:
	turn_ended.emit(self)
	
		
func _set_char_stats(value: CharacterStats) -> void:
	stats = value
	if stats == null:
		return
	# 导入变量的setter会在运行游戏时调用一次
	if not stats.stats_changed.is_connected(_update_stats):
		stats.stats_changed.connect(_update_stats)
	
	if visuals == null:
		visuals = stats.visuals_scene.instantiate()
		add_child(visuals)
		await visuals.ready
		spine_manager = visuals.get_spine_manager()

	_update_player()

func _update_stats() -> void:
	health_bar.update_stats(stats)
	
func _update_player() -> void:
	if stats is not CharacterStats:
		printerr("player出现出错")
		return
	if not is_node_ready():
		await ready	
	set_hitbox()
	spine_anim_state = spine_manager.get_animation_state()
	spine_anim_state.set_animation("idle_loop", true, 0)
	_update_stats()
	name_label.text = stats.character_name

func use_energy(amount: int) -> void:
	stats.energy -= amount
	energy_used_this_turn += amount

func _on_card_played(card: Card, _card_context: Dictionary) -> void:
	
	if card.type == Card.Type.ATTACK:
		attack_played_this_turn += 1
		#spine_anim_state.set_animation("attack", false, 0)
		#spine_anim_state.add_animation("idle_loop", 0, true, 0)
	elif card.type == Card.Type.SKILL:
		skill_played_this_turn += 1
		#spine_anim_state.set_animation("cast", false, 0)
		#spine_anim_state.add_animation("idle_loop", 0, true, 0)

func animate_attack() -> void:
	spine_anim_state.set_animation("attack", false, 0)
	spine_anim_state.add_animation("idle_loop", 0, true, 0)
	
func animate_cast() -> void:
	spine_anim_state.set_animation("cast", false, 0)
	spine_anim_state.add_animation("idle_loop", 0, true, 0)

func animate_player(anim_name: String) -> void:
	spine_anim_state.set_animation(anim_name, false, 0)
	spine_anim_state.add_animation("idle_loop", 0, true, 0)
	
func _on_mouse_entered() -> void:
	show_name()
	Events.tooltip_show_request.emit(self, show_keyword_tooltip)

func _on_mouse_exited() -> void:
	hide_name()
	Events.tooltip_hide_request.emit()

func show_keyword_tooltip() -> void:
	#if buff_manager.get_child_count() == 0:
		#return
	for child: Buff in buff_manager.get_children():
		KeywordTooltip.add_keyword(child.buff_name, child.get_description())
	if stats.has_block():
		KeywordTooltip.add_keyword(BuffLibrary.keyword_info["格挡"]["name"], BuffLibrary.keyword_info["格挡"]["description"])
	elif buff_manager.get_child_count() == 0:
		return
	KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(hitbox.shape.size.x / 2, -hitbox.shape.size.y / 2)
	KeywordTooltip.show()

func set_hitbox() -> void:
	var bound_size = visuals.get_size()
	var center_point = visuals.get_center_point()
	hitbox.shape.size = bound_size
	hitbox.position = center_point
	
	damage_number_spawner.position = center_point
	# 将damage_number_spawner生成的对象添加到SFXLayer中
	damage_number_spawner.agent = get_node("../SFXLayer")
	
	set_recticles([
		center_point - bound_size / 2,
		center_point + Vector2(bound_size.x / 2, -bound_size.y / 2),
		center_point + Vector2(-bound_size.x / 2, bound_size.y / 2),
		center_point + bound_size / 2
	], visuals.get_visual_scale() * 2)
	
	var hp_bar_position = center_point + Vector2(-bound_size.x / 2, bound_size.y / 2)
	health_bar.position = hp_bar_position
	health_bar.set_length(visuals.get_size().x)
	health_bar.position = hp_bar_position
	
	buff_container.size.x = bound_size.x
	buff_container.position = hp_bar_position + Vector2(0, 40)
	
	name_plate.size.x = bound_size.x
	name_plate.position = hp_bar_position + Vector2(0, 10)
