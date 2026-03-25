class_name Enemy
extends Creature

@export var stats: EnemyStats : set = _set_enemy_stats

@onready var intents: Intents = $Intents
@onready var hitbox: CollisionShape2D = $Hitbox

var enemy_ai: EnemyAI
#var current_action: EnemyAction : set = _set_current_action
var current_intent: Intent: set = _set_current_intent

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	after_applied_buff.connect(_on_after_applied_buff)

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
	stats.block += context.amount

func do_turn() -> void:
	start_turn()
	stats.block = 0
	
	if not current_intent:
		return
		
	execute_intent()
	spine_anim_state.set_animation(current_intent.anim_name, true, 0)
	spine_anim_state.add_animation("idle_loop", 0, true, 0)
	await spine_manager.animation_completed
	Events.enemy_action_completed.emit(self)	
	turn_ended.emit(self)
	update_intent()

func execute_intent() -> void:
	if not current_intent:
		return
	var player: Player = get_tree().get_first_node_in_group("ui_player")
	for sub_intent: SubIntent in current_intent.sub_intents:
		sub_intent.execute(self, [player])
	intents.hide_intent()
		
func _set_current_intent(value: Intent) -> void:
	current_intent = value
	if not current_intent:
		return
	current_intent.calc_final_values(self, get_tree().get_first_node_in_group("ui_player"))
	intents.update_intent(current_intent)

func _set_enemy_stats(value: EnemyStats) -> void:
	if not value:
		return
		
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(_update_stats):
		stats.stats_changed.connect(_update_stats)
	
	_update_enemy()

func _setup_ai() -> void:
	if enemy_ai:
		enemy_ai.queue_free()
	enemy_ai = stats.ai
	
func start_turn() -> void:
	turn_started.emit(self)

func end_turn() -> void:
	turn_ended.emit(self)

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
	if not is_inside_tree():
		await ready
	
	spine_manager.skeleton_data_res = stats.animation
	_setup_ai()
	# 不等一帧的话get_animation_state返回的是null
	await get_tree().process_frame
	spine_anim_state = spine_manager.get_animation_state()
	spine_anim_state.set_animation("idle_loop", true, 0)
	_update_stats()
	
func die() -> void:
	intents.hide()
	health_bar.hide()
	reticles.hide()
	buff_container.hide()
	spine_anim_state.set_animation("die", true, 0)
	spine_manager.animation_completed.connect(
		func (_x, _y, _z): queue_free()
	)
	
func lose_health(context: Context) -> void:
	if stats.health <= 0:
		return
	
	before_lose_health.emit(context)
	stats.health -= context.amount

	if stats.health <= 0:
		die()
	else:
		spine_anim_state.set_animation("hurt", true, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)

func take_damage(context: Context) -> void:
	if stats.health <= 0:
		return
	
	var hurt := stats.take_damage(context.amount)
	
	if stats.health <= 0:
		die()
	elif hurt:
		spine_anim_state.set_animation("hurt", true, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)


func _on_area_entered(_area: Area2D) -> void:
	reticles.visible = true

func _on_area_exited(_area: Area2D) -> void:
	reticles.visible = false

func _on_mouse_entered() -> void:
	Events.tooltip_show_request.emit(self)

func _on_mouse_exited() -> void:
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

func _on_after_applied_buff(context: Context) -> void:
	current_intent.calc_final_values(self, context.source)
	intents.update_intent(current_intent)
