extends Control
class_name MerchantCardRemoval

signal removal_clicked(price: int)
signal hand_hover_requested(card_node: Node)
signal hand_hide_requested()

# 由于可以无限删除且不涨价，改为125
@export var removal_price: int = 125

var cost_label: Label
var run_stats: RunStats
var animation_player: AnimationPlayer

var original_scale: Vector2   # 新增


func _ready():
	cost_label = get_node_or_null("Cost/CostLabel") as Label
	animation_player = get_node_or_null("Animation") as AnimationPlayer
	
	mouse_filter = MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	_update_display()
	
	if animation_player and animation_player.has_animation("Available"):
		animation_player.play("Available")
	
	original_scale = scale   # 记录原始缩放


func _update_display():
	if cost_label:
		cost_label.text = str(removal_price)
	_update_cost_color()

func set_run_stats(stats: RunStats):
	run_stats = stats
	_update_cost_color()

func _update_cost_color():
	if not cost_label or not run_stats:
		return
	var can_afford = run_stats.gold >= removal_price
	var color = Color.RED if not can_afford else Color.WHITE
	cost_label.set("theme_override_colors/font_color", color)
	cost_label.queue_redraw()

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#print("MerchantCardRemoval 被点击")
		
		removal_clicked.emit(removal_price)
		accept_event()

func _on_mouse_entered():
	scale = original_scale * 1.2   # 悬停放大
	hand_hover_requested.emit(self)

func _on_mouse_exited():
	scale = original_scale        # 恢复原始大小
	hand_hide_requested.emit()
