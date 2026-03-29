class_name Player
extends Creature

# 玩家专属信号
signal before_draw_cards(context: DrawCardContext)
signal after_draw_card(card: Card)


@export var stats: CharacterStats : set = _set_char_stats
@export var hand_selector: HandSelector
@export var agent: PlayerHandler

@onready var hitbox: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	spine_manager.scale = Vector2(0.3, 0.3)
	hitbox.shape.size *= Vector2(0.3, 0.3)
	hitbox.position = Vector2(0, - hitbox.shape.size.y / 2)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	Events.card_played.connect(_on_card_played)
	Events.player_talked.connect(speech)

func speech(text: String, time: float = 2.5) -> void:
	speech_bubble.set_text(text, time)
	speech_bubble.global_position = hitbox.global_position + Vector2(hitbox.shape.size.x, -hitbox.shape.size.y / 2)
	speech_bubble.scale = spine_manager.scale * 2
#func add_buff(buff_context: ApplyBuffContext) -> void:
	#buff_context.buff_node.stacks = buff_context.amount	
	#buff_manager.add_buff(buff_context)
	#var buff_ui := BUFF_UI.instantiate()
	#buff_ui.buff = buff_context.buff_node
	#buff_container.add_child(buff_ui)

func select(context: ChooseCardContext) -> void:
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
		
func gain_block(context: Context) -> void:
	before_gain_block.emit(context)
	stats.block += context.get_final_value()

func get_block() -> int:
	return stats.block
	
func die() -> void:
	health_bar.hide()
	buff_container.hide()
	spine_anim_state.set_animation("die", false, 0)
	await spine_manager.animation_completed
	Events.player_died.emit()

func draw_card() -> void:
	var card: Card = agent.draw_card()
	after_draw_card.emit(card)

func draw_cards(context: DrawCardContext) -> void:
	before_draw_cards.emit(context)
	if context.amount > 0:
		var tween = create_tween()
		for i in range(context.amount):
			tween.tween_callback(draw_card)
			tween.tween_interval(0.2)
		await tween.finished

func gain_energy(context: GainEnergyContext) -> void:
	stats.energy += context.amount
	
	
func lose_health(context: Context) -> void:
	if stats.health <= 0:
		return
	
	before_lose_health.emit(context)
	stats.health -= context.amount

	if stats.health <= 0:
		die()
	else:
		Events.player_hit.emit()
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
		
func take_damage(context: Context) -> void:
	
	if stats.health <= 0:
		return
	before_take_damage.emit(context)
	var hurt := stats.take_damage(context.get_final_value())
	
	if stats.health <= 0:
		die()
	elif hurt:
		Events.player_hit.emit()
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)

func put_card_in_discard_pile(card: Card) -> void:
	agent.put_card_in_discard_pile(card)

func put_card_in_draw_pile(card: Card, top:bool = false) -> void:
	agent.put_card_in_draw_pile(card, top)
	

func get_hand_cards() -> Array[Card]:
	return agent.get_hand()

func get_draw_pile() -> Array[Card]:
	return stats.get_draw_pile()

func get_discard_pile() -> Array[Card]:
	return stats.get_discard_pile()

func get_exhaust_pile() -> Array[Card]:
	return stats.get_exhaust_pile()

func get_card_count_by_name(name: String) -> int:
	var all_cards: Array[Card] = get_hand_cards()
	all_cards.append_array(get_draw_pile())
	all_cards.append_array(get_discard_pile())
	# 将所有卡牌加起来，用filter函数筛选出id有name字符串卡牌然后获取数组长度
	return len(all_cards.filter(func(card: Card): card.id.contains(name)))

func discard_card(card: Card) -> void:
	agent.discard_card(card)
	
func exhaust_card(card: Card) -> void:
	agent.exhaust_card(card)

func start_turn() -> void:
	before_turn_started.emit(self)
	stats.block = 0
	stats.energy = stats.max_energy
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
	
	_update_player()

func _update_stats() -> void:
	health_bar.update_stats(stats)
	
func _update_player() -> void:
	if stats is not CharacterStats:
		printerr("player出现出错")
		return
	if not is_inside_tree():
		await ready
	
	spine_manager.skeleton_data_res = stats.animation
	await get_tree().process_frame
	spine_anim_state = spine_manager.get_animation_state()
	spine_anim_state.set_animation("idle_loop", true, 0)
	_update_stats()

func _on_card_played(card: Card) -> void:
	if card.type == Card.Type.ATTACK:
		spine_anim_state.set_animation("attack", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
	else:
		spine_anim_state.set_animation("cast", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)
	
func _on_mouse_entered() -> void:
	Events.tooltip_show_request.emit(self)

func _on_mouse_exited() -> void:
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
