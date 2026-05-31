extends Control
class_name MerchantCard

var cost_label: Label
var run_stats: RunStats  

const CARD_MENU_UI_SCENE = preload("res://scenes/ui/card_menu_ui.tscn")

signal card_clicked(shop_item: ShopItem)   # 改为传递 ShopItem
signal hand_hover_requested(card_node: Node)
signal hand_hide_requested()

var shop_item: ShopItem # 使用 ShopItem 替代 card_data

var card_ui_instance: CardMenuUI
var card_holder: Control
var hover_tween: Tween
var sale_visual: Sprite2D

func _ready():
	card_holder = get_node_or_null("CardHolder") as Control
	cost_label = get_node_or_null("Cost/CostLabel") as Label
	sale_visual = get_node_or_null("SaleVisual") as Sprite2D   
	if not card_holder:
		printerr("错误：未找到 CardHolder")
		return
	if shop_item:
		_refresh_display()

func _set_shop_item(new_item: ShopItem) -> void:
	if shop_item == new_item:
		return
	shop_item = new_item
	if is_inside_tree():
		_refresh_display()

func _refresh_display() -> void:
	if not shop_item or not card_holder:
		return

	if not card_ui_instance:
		card_ui_instance = CARD_MENU_UI_SCENE.instantiate()
		card_holder.add_child(card_ui_instance)

		card_ui_instance.layout_mode = 1
		card_ui_instance.anchors_preset = Control.PRESET_FULL_RECT
		card_ui_instance.offset_left = 0
		card_ui_instance.offset_top = 0
		card_ui_instance.offset_right = 0
		card_ui_instance.offset_bottom = 0
		card_ui_instance.scale = Vector2(1.3, 1.3)

		card_ui_instance.mouse_entered.connect(_on_custom_mouse_entered)
		card_ui_instance.mouse_exited.connect(_on_custom_mouse_exited)

		if not card_ui_instance.inspect_card_requested.is_connected(_on_card_clicked):
			card_ui_instance.inspect_card_requested.connect(_on_card_clicked)

	card_ui_instance.card = shop_item.item_data   # 传递原始卡牌数据
	
	_update_shop_price_display()
	_update_cost_color()

func _on_custom_mouse_entered() -> void:
	if card_ui_instance.tween and card_ui_instance.tween.is_valid():
		card_ui_instance.tween.kill()
	
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_SPRING)
	hover_tween.tween_property(card_ui_instance, "scale", Vector2(1.4, 1.4), 0.15)

	hand_hover_requested.emit(self)

func _on_custom_mouse_exited() -> void:
	if card_ui_instance.tween and card_ui_instance.tween.is_valid():
		card_ui_instance.tween.kill()
	
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
	hover_tween = create_tween().set_trans(Tween.TRANS_SPRING)
	hover_tween.tween_property(card_ui_instance, "scale", Vector2(1.3, 1.3), 0.15)

	hand_hide_requested.emit()

func _on_card_clicked(card: Card) -> void:
	# 忽略参数，直接发射 shop_item
	card_clicked.emit(shop_item)

func set_run_stats(stats: RunStats):
	run_stats = stats
	_update_shop_price_display()
	_update_cost_color()

func _update_cost_color():
	if not shop_item or not cost_label:
		return
	if not run_stats:
		return
	var can_afford = run_stats.gold >= shop_item.shop_price
	var color: Color
	if not can_afford:
		color = Color.RED
	elif shop_item.on_sale:
		color = Color.GREEN
	else:
		color = Color.WHITE
	cost_label.add_theme_color_override("font_color", color)
		
func _update_shop_price_display():
	if not shop_item or not cost_label:
		return
	cost_label.text = str(shop_item.shop_price)
	if sale_visual:
		sale_visual.visible = shop_item.on_sale 

func update_affordability():
	_update_cost_color()

func set_shop_item(item: ShopItem) -> void:
	shop_item = item
	if is_inside_tree():
		_refresh_display()


func get_shop_item() -> ShopItem:
	return shop_item
