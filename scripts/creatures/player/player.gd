class_name Player
extends Creature


@export var stats: CharacterStats : set = _set_char_stats

@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var hint_sprite: TextureRect = $Hint
@onready var hint_lable: Label = $Hint/HintLable
@onready var hint_timer: Timer = $Timer

func _ready() -> void:
	spine_manager.scale = Vector2(0.3, 0.3)
	hitbox.shape.size *= Vector2(0.3, 0.3)
	hitbox.position = Vector2(0, - hitbox.shape.size.y / 2)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	Events.player_hited.connect(_hint)
	Events.card_played.connect(_on_card_played)
	hint_timer.timeout.connect(
		func(): hint_sprite.visible = false
	)
	
func _hint(hint_text: String) -> void:
	hint_sprite.visible = true
	hint_lable.text = hint_text
	hint_timer.start(2.5)

#func add_buff(buff_context: ApplyBuffContext) -> void:
	#buff_context.buff_node.stacks = buff_context.amount	
	#buff_manager.add_buff(buff_context)
	#var buff_ui := BUFF_UI.instantiate()
	#buff_ui.buff = buff_context.buff_node
	#buff_container.add_child(buff_ui)
	
func gain_block(context: Context) -> void:
	before_gain_block.emit(context)
	stats.block += context.amount

	
func die() -> void:
	health_bar.hide()
	buff_container.hide()
	spine_anim_state.set_animation("die", false, 0)
	await spine_manager.animation_completed
	Events.player_died.emit()
	
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

	var hurt := stats.take_damage(context.amount)
	
	if stats.health <= 0:
		die()
	elif hurt:
		Events.player_hit.emit()
		spine_anim_state.set_animation("hurt", false, 0)
		spine_anim_state.add_animation("idle_loop", 0, true, 0)

func start_turn() -> void:
	turn_started.emit(self)

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
