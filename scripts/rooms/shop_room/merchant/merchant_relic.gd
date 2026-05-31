extends Control
class_name MerchantRelic

const RELIC_UI_SCENE = preload("res://scenes/relichandler/relic_ui.tscn")

signal relic_clicked(shop_item: ShopItem)   # 改为传递 ShopItem
signal hand_hover_requested(card_node: Node)
signal hand_hide_requested()

var shop_item: ShopItem

var cost_label: Label
var relic_ui_instance: RelicUI
var relic_holder: Control
var run_stats: RunStats
var original_scale: Vector2


func _ready():
	relic_holder = get_node_or_null("RelicHolder") as Control
	cost_label = get_node_or_null("Cost/CostLabel") as Label
	if not relic_holder:
		printerr("错误：未找到 RelicHolder")
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
	if not shop_item or not relic_holder:
		return

	if not relic_ui_instance:
		relic_ui_instance = RELIC_UI_SCENE.instantiate()
		relic_holder.add_child(relic_ui_instance)
		relic_ui_instance.layout_mode = 1
		relic_ui_instance.anchors_preset = Control.PRESET_FULL_RECT
		relic_ui_instance.offset_left = 0
		relic_ui_instance.offset_top = 0
		relic_ui_instance.offset_right = 0
		relic_ui_instance.offset_bottom = 0

		relic_ui_instance.mouse_entered.connect(_on_relic_ui_mouse_entered)
		relic_ui_instance.mouse_exited.connect(_on_relic_ui_mouse_exited)
		relic_ui_instance.gui_input.connect(_on_relic_ui_gui_input)

	relic_ui_instance.set_relic(shop_item.item_data)   # 传递原始遗物数据
	_update_shop_price_display()
	_update_cost_color()


func _on_relic_ui_mouse_entered() -> void:
	scale = original_scale * 1.2
	hand_hover_requested.emit(self)


func _on_relic_ui_mouse_exited() -> void:
	scale = original_scale
	hand_hide_requested.emit()


func _on_relic_ui_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		relic_clicked.emit(shop_item)   # 发射 ShopItem
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


#保存相关setter_getter(merchant_card,merchant_potion中类似)
func set_shop_item(item: ShopItem) -> void:
	shop_item = item
	if is_inside_tree():
		_refresh_display()

func get_shop_item() -> ShopItem:
	return shop_item
