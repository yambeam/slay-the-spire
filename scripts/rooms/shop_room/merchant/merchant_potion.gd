extends Control
class_name MerchantPotion

const POTION_UI_SCENE = preload("res://scenes/ui/top_bar/potion_ui.tscn")

signal potion_clicked(shop_item: ShopItem)   # 改为传递 ShopItem
signal hand_hover_requested(card_node: Node)
signal hand_hide_requested()

var shop_item: ShopItem 

var cost_label: Label
var potion_ui_instance: Control
var potion_holder: Control
var run_stats: RunStats
var original_scale: Vector2


func _ready():
	potion_holder = get_node_or_null("PotionHolder") as Control
	cost_label = get_node_or_null("Cost/CostLabel") as Label
	if not potion_holder:
		print("错误：未找到 PotionHolder")
		return
	if shop_item:
		_refresh_display()
	original_scale = scale


func _set_shop_item(new_item: ShopItem) -> void:
	if shop_item == new_item:
		return
	shop_item = new_item
	if is_inside_tree():
		_refresh_display()


func _refresh_display() -> void:
	if not shop_item or not potion_holder:
		return
	
	if not potion_ui_instance:
		potion_ui_instance = POTION_UI_SCENE.instantiate()
		potion_holder.add_child(potion_ui_instance)
		potion_ui_instance.layout_mode = 1
		potion_ui_instance.anchors_preset = Control.PRESET_FULL_RECT
		potion_ui_instance.offset_left = 0
		potion_ui_instance.offset_top = 0
		potion_ui_instance.offset_right = 0
		potion_ui_instance.offset_bottom = 0

		potion_ui_instance.mouse_entered.connect(_on_mouse_entered)
		potion_ui_instance.mouse_exited.connect(_on_mouse_exited)
		potion_ui_instance.gui_input.connect(_on_gui_input)

	if potion_ui_instance.has_method("set_potion"):
		potion_ui_instance.set_potion(shop_item.item_data)   # 传递原始药水数据
	# 防止点击出现potion_popup
	potion_ui_instance.potion_button.disabled = true
	_update_shop_price_display()
	_update_cost_color()


func _on_mouse_entered():
	scale = original_scale * 1.2
	hand_hover_requested.emit(self)


func _on_mouse_exited():
	scale = original_scale
	hand_hide_requested.emit()


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		potion_clicked.emit(shop_item)   # 发射 ShopItem
		accept_event()


func set_run_stats(stats: RunStats):
	run_stats = stats
	_update_shop_price_display()
	_update_cost_color()


func _update_shop_price_display():
	if not shop_item or not cost_label:
		return
	cost_label.text = str(shop_item.shop_price)


func _update_cost_color():
	if not shop_item or not cost_label or not run_stats:
		return
	var can_afford = run_stats.gold >= shop_item.shop_price
	var color: Color
	if shop_item.on_sale:
		color = Color.GREEN
	else:
		color = Color.RED if not can_afford else Color.WHITE
	cost_label.add_theme_color_override("font_color", color)


func update_affordability():
	_update_cost_color()

func get_shop_item() -> ShopItem:
	return shop_item

func set_shop_item(item: ShopItem) -> void:
	shop_item = item
	if is_inside_tree():
		_refresh_display()
