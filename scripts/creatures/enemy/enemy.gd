class_name Enemy
extends Creature

@export var stats: EnemyStats : set = _set_enemy_stats

@onready var intents: Intents = $Intents
@onready var hitbox: CollisionShape2D = $Hitbox

var enemy_ai: EnemyAI
#var current_action: EnemyAction : set = _set_current_action
var current_intent: Intent: set = _set_current_intent

var visuals: CreatureVisuals
var spine_manager: SpineManager
var dead: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

#func add_buff(buff_context: ApplyBuffContext) -> void:
	#before_applied_buff.emit(buff_context)
	#buff_context.buff_node.stacks = buff_context.amount	
	#if buff_manager.add_buff(buff_context):
		#var buff_ui := BUFF_UI.instantiate()
		#buff_ui.buff = buff_context.buff_node
		#buff_container.add_child(buff_ui)
	#after_applied_buff.emit(buff_context)

func gain_block(context: Context) -> void:
	before_gain_block.emit(context)
	stats.block += context.get_final_value()

func do_turn() -> void:
	start_turn()
	
	if not current_intent:
		return
	
	if dead:
		Events.enemy_action_completed.emit(self)	
		return		
	
	# 在这个函数中设置了动画名称，必须在动画开始前调用
	execute_intent()
	
	var track_entry := spine_anim_state.set_animation(current_intent.anim_name, true, 0)
	spine_anim_state.add_animation(enemy_ai.get_idle_animation_name(), 0, true, 0)

	# 使用await spine_manager.animation_completed有时会出现等待idle_animation结束才发出信号的情况，干脆等待动画时间
	await get_tree().create_timer(track_entry.get_animation_end()).timeout
	
	Events.enemy_action_completed.emit(self)	
	turn_ended.emit(self)
	update_intent()
	

func execute_intent() -> void:
	var player: Player = get_tree().get_first_node_in_group("ui_player")
	intents.hide_intent()
	enemy_ai.execute_intent(self, player, current_intent)
	
		
func _set_current_intent(value: Intent) -> void:
	current_intent = value
	if not current_intent:
		return
	intents.update_intent(current_intent)

func _set_enemy_stats(value: EnemyStats) -> void:
	if not value:
		return
		
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(_update_stats):
		stats.stats_changed.connect(_update_stats)
	
	if visuals == null:
		visuals = stats.visuals_scene.instantiate()
		add_child(visuals)
		await visuals.ready
		spine_manager = visuals.get_spine_manager()
	_update_enemy()

func _setup_ai() -> void:
	if enemy_ai:
		enemy_ai.queue_free()
	# 主要是不同怪物intent里source不同，也许修改一下就不需要深拷贝了
	enemy_ai = stats.ai.duplicate_deep()
	var player : Player = get_tree().get_first_node_in_group("ui_player")
	enemy_ai.set_up_intents(self, player)
	buff_changed.connect(
		func():
			# 只有带有攻击的意图需要动态显示
			if current_intent and current_intent.has_attack_sub_intent():
				intents.update_display(current_intent)
	)
	player.buff_changed.connect(
		func():
			if current_intent and current_intent.has_attack_sub_intent():
				intents.update_display(current_intent)
	)
	
	
func start_turn() -> void:
	before_turn_started.emit(self)
	stats.block = 0
	after_turn_started.emit(self)

func update_intent() -> void:
	if not enemy_ai:
		return
	if not current_intent:
		# TODO:修改	
		current_intent = enemy_ai.choose_intent(self, get_tree().get_first_node_in_group("ui_player"))
		return

	
func _update_stats() -> void:
	health_bar.update_stats(stats)

func _update_enemy() -> void:
	if not stats is Stats:
		printerr("enemy出错")
		return
	if not is_node_ready():
		await ready
	set_hitbox()
	_setup_ai()
	var skeleton := spine_manager.get_skeleton()
	var skin := enemy_ai.get_skin(spine_manager)
	if skin:
		skeleton.set_skin(skin)
	spine_anim_state = spine_manager.get_animation_state()
	spine_anim_state.set_animation(enemy_ai.get_idle_animation_name(), true, 0)
	name_label.text = stats.enemy_name
	_update_stats()
	
func die() -> void:
	dead = true
	intents.hide()
	health_bar.hide()
	reticles.hide()
	buff_container.hide()
	spine_anim_state.set_animation(enemy_ai.get_die_animation_name(), true, 0)
	Events.enemy_died.emit()
	spine_manager.animation_completed.connect(
		func (_x, _y, _z): queue_free()
	)

func heal(context: HealContext) -> int:
	return context.target.gain_health(context)

func gain_health(context: HealContext) -> int:
	return stats.heal(context.amount)

func gain_max_health(context: GainMaxHealthContext) -> int:
	stats.max_health += context.amount
	gain_health(HealContext.new(context.source, context.target, context.amount))
	return context.amount
	
func lose_health(context: Context) -> int:
	if stats.health <= 0:
		return 0
	
	before_lose_health.emit(context)
	stats.health -= context.amount
	after_lose_health.emit(context)
	damage_number_spawner.spawn_damage_label(context.amount, false)

	if stats.health <= 0:
		die()
	else:
		spine_anim_state.set_animation(enemy_ai.get_hurt_animation_name(), true, 0)
		spine_anim_state.add_animation(enemy_ai.get_idle_animation_name(), 0, true, 0)
	
	return context.amount

func take_damage(context: Context) -> int:
	if stats.health <= 0:
		return 0
	before_take_damage.emit(context)
	var final_value: int = context.get_final_value()
	var actual_damage := stats.take_damage(final_value)
	damage_number_spawner.spawn_damage_label(actual_damage, actual_damage == 0 and final_value != 0)
	after_take_damage.emit(context)
	
	if stats.health <= 0:
		die()
	elif actual_damage > 0:
		spine_anim_state.set_animation(enemy_ai.get_hurt_animation_name(), true, 0)
		spine_anim_state.add_animation(enemy_ai.get_idle_animation_name(), 0, true, 0)
	return actual_damage

func take_damage_without_signals(amount: int) -> int:
	if stats.health <= 0:
		return 0
	var actual_damage := stats.take_damage(amount)
	damage_number_spawner.spawn_damage_label(actual_damage, actual_damage == 0 and amount != 0)
	
	if stats.health <= 0:
		die()
	elif actual_damage > 0:
		spine_anim_state.set_animation(enemy_ai.get_hurt_animation_name(), true, 0)
		spine_anim_state.add_animation(enemy_ai.get_idle_animation_name(), 0, true, 0)
	return actual_damage

	
func _on_area_entered(_area: Area2D) -> void:
	reticles.visible = true

func _on_area_exited(_area: Area2D) -> void:
	reticles.visible = false

func _on_mouse_entered() -> void:
	show_name()
	Events.tooltip_show_request.emit(self, show_keyword_tooltip)

func _on_mouse_exited() -> void:
	hide_name()
	Events.tooltip_hide_request.emit()

func show_keyword_tooltip() -> void:
	#if buff_manager.get_child_count() == 0:
		#return
	if current_intent:
		for sub_intent: SubIntent in current_intent.sub_intents:
			KeywordTooltip.add_keyword(sub_intent.get_intent_name(), sub_intent.get_intent_description())
	if stats.has_block():
		KeywordTooltip.add_keyword(BuffLibrary.keyword_info["格挡"]["name"], BuffLibrary.keyword_info["格挡"]["description"])
	for child: Buff in buff_manager.get_children():
		KeywordTooltip.add_keyword(child.buff_name, child.get_description())
	
	KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(hitbox.shape.size.x / 2, -hitbox.shape.size.y / 2)
	KeywordTooltip.show()

func set_hitbox() -> void:
	var bound_size = visuals.get_size()
	var center_point = visuals.get_center_point()
	
	hitbox.shape.size = bound_size
	hitbox.position = center_point
	
	damage_number_spawner.position = center_point
	damage_number_spawner.agent = get_node("../../SFXLayer")
	
	set_recticles([
		center_point - bound_size / 2,
		center_point + Vector2(bound_size.x / 2, -bound_size.y / 2),
		center_point + Vector2(-bound_size.x / 2, bound_size.y / 2),
		center_point + bound_size / 2
	], visuals.get_visual_scale() * 2)
	
	intents.position = visuals.get_intent_point() - intents.size / 2
	
	var hp_bar_position = center_point + Vector2(-bound_size.x / 2, bound_size.y / 2)
	health_bar.set_length(visuals.get_size().x)
	health_bar.position = hp_bar_position
	health_bar.set_length(visuals.get_size().x)
	health_bar.position = hp_bar_position
	
	buff_container.size.x = bound_size.x
	buff_container.position = hp_bar_position + Vector2(0, 40)
	
	name_plate.size.x = bound_size.x
	name_plate.position = hp_bar_position + Vector2(0, 10)
