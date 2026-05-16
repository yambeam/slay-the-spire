extends Control

const CARD_MENU_UI_SCENE = preload("res://scenes/ui/card_menu_ui.tscn")
#const RELIC_PILE_PATH = "res://entities/merchant/relic/shop_relics.tres"
#const POTION_PILE_PATH = "res://entities/merchant/potions/shop_potions.tres"

# 商品价格随机区间
const RELIC_PRICE_MIN := 200
const RELIC_PRICE_MAX := 400

const POTION_PRICE_MIN := 40
const POTION_PRICE_MAX := 80
#删除卡牌固定费用为75（基础金币设置为75）
const CARD_REMOVAL_PRICE := 75

# 折扣概率
const DISCOUNT_CHANCE := 0.3
const DISCOUNT_FACTOR_MIN := 0.3
const DISCOUNT_FACTOR_MAX := 0.9

@onready var inventory := %MerchantInventory
@onready var return_button := %Reback
@onready var merchant_button := $SceneContainer/MerchantButton
@onready var highlight_polygon := $SceneContainer/MerchantButton/HighlightPolygon as Line2D

#merchant_inventory下的节点
var slots_container: Control
var back_button: Control
var backstop: ColorRect
var is_hovered := false
var back_button_hovered := false

# 商人手部
var merchant_hand: SpineSprite
var hand_hide_timer: Timer
var hand_shake_timer: Timer
var base_hand_pos: Vector2
var current_shake_tween: Tween
var hand_move_tween: Tween

# 游戏运行数据
var run_stats: RunStats
var cards_populated := false

#删除卡牌Ui节点
var card_removal_node: MerchantCardRemoval

#控制ui是否响应
var is_exiting := false

# 商人对话气泡
const DIALOGUE_SCENE = preload("res://scenes/rooms/shop_room/merchant/merchant_rug_dialogue.tscn")
var dialogue_bubble: Node2D   # 类型根据实际根节点而定
# 商人台词库
const LINES = {
	"purchase_success": [
		"成交！",
		"又一笔买卖......嚯嚯嚯！有得赚！",
		"祝你顺利哦！",
		"概不退换。",
        "谢啦~"
	],
	"purchase_fail": [
		"没钱啦？",
		"哎呀呀，这点金币可不够啊。",
		"等你多挣一点金币再来。",
		"我这儿不是做慈善的。",
		"嘿兄弟，你没钱啊！",
        "你的金币不够。"
	],
	"potion_full": [
        "你没有空间存放。"
	],
	"card_removal_success": [
		"卸下负担，轻装上阵！",
		"明智的取舍。",
        "少即是多，对吧？"
	],
	"card_removal_cancel": [
		"改变主意了吗？随时欢迎。",
        "不想移除了？没关系。"
	]
}


func _ready() -> void:
	
	_initialize_merchant_animation()
	_initialize_hand_timers()
	_initialize_highlight()
	_initialize_inventory_nodes()
	_initialize_run_stats()
	_initialize_card_removal()
	_initialize_dialogue()
	
	# 连接商人按钮信号
	if merchant_button.has_signal("shop_requested"):
		merchant_button.shop_requested.connect(_show_inventory)
	
	# 连接返回地图按钮
	if not return_button.pressed.is_connected(_on_return_map_pressed):
		return_button.pressed.connect(_on_return_map_pressed)
	
#	进入房间识别所有事件输入
	is_exiting = true

# ============================================
# 初始化
# ============================================
func _initialize_merchant_animation() -> void:
	#商人初始动画	
	$SceneContainer/MerchantButton/MerchantVisual.get_animation_state().set_animation("idle_loop", true, 0)

func _initialize_hand_timers() -> void:
	#当停止悬停后手部归位计时器(这里设为1s)	
	hand_hide_timer = Timer.new()
	hand_hide_timer.one_shot = true
	hand_hide_timer.wait_time = 1.0
	hand_hide_timer.timeout.connect(_on_hand_hide_timeout)
	add_child(hand_hide_timer)
	
	#设置商人手部悬停后的颤动定时器(可选)	
	hand_shake_timer = Timer.new()
	hand_shake_timer.wait_time = 0.03
	hand_shake_timer.timeout.connect(_apply_hand_shake)
	add_child(hand_shake_timer)

#商人按钮悬停的高亮效果设置
func _initialize_highlight() -> void:
	if highlight_polygon:
		highlight_polygon.modulate.a = 0.0

#初始化商人的仓库
func _initialize_inventory_nodes() -> void:
	if not inventory:
		return
		
	backstop = inventory.get_node("Backstop") as ColorRect
#slots_container内部包含三种商品
	slots_container = inventory.get_node("SlotsContainer") as Control
	back_button = inventory.get_node("BackButton") as Control
	merchant_hand = inventory.get_node_or_null("MerchantHandContainer") as SpineSprite
	card_removal_node = slots_container.get_node_or_null("MerchantCardRemoval") as MerchantCardRemoval

	if back_button:
		back_button.visible = false
		back_button.mouse_filter = Control.MOUSE_FILTER_STOP
		# 双重保障：gui_input 信号直接处理点击
		if not back_button.gui_input.is_connected(_on_back_button_gui_input):
			back_button.gui_input.connect(_on_back_button_gui_input)
			
	if slots_container:
		_set_slots_initial_position(slots_container)
	else:
		print("错误：未找到 SlotsContainer 节点！")

#获取runstats
func _initialize_run_stats() -> void:
	var current = self
	while current:
		if current is Run:
			run_stats = current.stats
			break
		current = current.get_parent()
		
		
	if run_stats:
		run_stats.gold_changed.connect(_update_all_affordability)
	else:
		print("警告：无法获取 RunStats，购买和颜色更新功能将不可用")

#删除卡牌的信号连接
func _initialize_card_removal() -> void:
	if not card_removal_node or not run_stats:
		return
	card_removal_node.set_run_stats(run_stats)
	card_removal_node.removal_clicked.connect(_on_card_removal_purchased)
	_connect_hand_signals(card_removal_node)

#商人聊天气泡初始位置设置
func _initialize_dialogue() -> void:
	dialogue_bubble = DIALOGUE_SCENE.instantiate()
	dialogue_bubble.z_index = 5
	# 设置一个合适的初始位置（也可在 say 时动态调整）
	dialogue_bubble.position = Vector2(400, 50)
	add_child(dialogue_bubble)


# ============================================
# 聊天气泡前的随机台词
# ============================================
func _say_random(key: String, duration: float = 2.0) -> void:
	if not LINES.has(key):
		return
	var lines = LINES[key]
	if lines.is_empty():
		return
	say(lines[randi() % lines.size()], duration)

func say(message: String, duration: float = 2.0) -> void:
	if dialogue_bubble and dialogue_bubble.has_method("say"):
		dialogue_bubble.say(message, duration)

# ============================================
# 商品填充（卡牌/遗物/药水）(均复用了相关ui)
# ============================================
func _populate_cards() -> void:
	if not slots_container:
		return
	var char_name = _get_character_name()
	if char_name == "":
		return

	var character_color = _get_character_color_mask(char_name)
	if character_color == 0:
		return

	var shop_rarity_mask = Card.Rarity.COMMON | Card.Rarity.UNCOMMON | Card.Rarity.RARE

	# 从全局卡池获取卡牌数组（而不是 CardPile 资源）
	var character_cards: Array = ItemPool.get_draftable_cards(character_color,ItemPool.card_type_mask, shop_rarity_mask)
	var colorless_cards: Array = ItemPool.get_draftable_cards(Card.COLOR.COLORLESS, ItemPool.card_type_mask, shop_rarity_mask)


	var fill_region = func(container: Node, cards_array: Array, region_name: String):
		if not container:
			return
		var slots: Array[MerchantCard] = []
		for child in container.get_children():
			if child is MerchantCard:
				slots.append(child)
		_clear_slots(slots, "shop_item")
		if slots.is_empty() or cards_array.is_empty():
			print(region_name + "：无槽位或牌库为空")
			return

		var available = cards_array.duplicate()
		available.shuffle()
		var count = min(slots.size(), available.size())
		for i in range(count):
			#卡牌复制
			var card_data: Card = available[i] as Card
			var shop_item = _create_card_shop_item(card_data)
			var slot = slots[i]
			slot.visible = true
			slot.set_shop_item(shop_item)
			if run_stats:
				slot.set_run_stats(run_stats)
			_connect_card_signals(slot)
		# print(region_name + "填充完成，数量：", count)

	fill_region.call(slots_container.get_node_or_null("CharacterCards"), character_cards, "角色卡牌")
	fill_region.call(slots_container.get_node_or_null("ColorlessCards"), colorless_cards, "无色卡牌")
	
func _populate_relics() -> void:
	if not slots_container:
		return
	var relics_container = slots_container.get_node_or_null("Relics")
	if not relics_container:
		return
	
	var char_name = _get_character_name()
	if char_name == "":
		return
	var character_color = _get_character_color_mask(char_name)
	if character_color == 0:
		return


	var maskColor = character_color | Relic.COLOR.COLORLESS
	var maskRarity = Relic.Rarity.COMMON | Relic.Rarity.UNCOMMON | Relic.Rarity.SHOP_RELIC | Relic.Rarity.RARE | Relic.Rarity.EVENT
	
	
	var all_relics = ItemPool.get_relics(maskColor,maskRarity)
	for i in all_relics:
		print("预备遗物:",i.relic_name,",color:",i.relic_color,",rarity:",i.rarity)
	#var character_relic_pile: Array = ItemPool.get_relics_by_color(character_color)
	#var colorless_relic_pile: Array = ItemPool.get_relics_by_color(Card.COLOR.COLORLESS)

	
	
	if not all_relics:
		return

	var character_stats = _get_character_stats()
	if not character_stats:
		return

	var available_relics: Array[Relic] = []
	for relic in all_relics:
		#if not relic.can_appear_as_reward(character_stats, Relic.Rarity.SHOP_RELIC):
			#continue
		## 过滤已拥有的遗物
		if run_stats.has_relic(relic.id):
			continue
		available_relics.append(relic)
	available_relics.shuffle()

	var slots: Array[Control] = _find_slots(relics_container, "merchant_relic.gd", "set_relic_data", "MerchantRelic")
	_clear_slots(slots, "relic_data")
	var count = min(slots.size(), available_relics.size())
	for i in range(count):
		var relic = available_relics[i]
		var shop_item = _create_relic_shop_item(relic)    # 创建 ShopItem
		var slot = slots[i]
		slot.visible = true
		slot.set_shop_item (shop_item)                     # 改为 set_shop_item
		slot.set_run_stats(run_stats)
		_connect_click_signal(slot, "relic_clicked", _on_relic_purchased)
		_connect_hand_signals(slot)
	# print("遗物填充完成，实际显示数量：", count)
	
func _populate_potions() -> void:
	if not slots_container:
		return
	var potions_container = slots_container.get_node_or_null("Potions")
	if not potions_container:
		return

	#var potion_pile = load(POTION_PILE_PATH) as PotionPile
	#if not potion_pile:
		#return
		
	var char_name = _get_character_name()
	if char_name == "":
		return
	var character_color = _get_character_color_mask(char_name)
	if character_color == 0:
		return

#	获取相应药剂
	var mask = character_color | Card.COLOR.COLORLESS
	var available_potions = ItemPool.get_potions_by_color(mask)
	available_potions.shuffle()

	var slots: Array[Control] = _find_slots(potions_container, "merchant_potion.gd", "set_potion_data", "MerchantPotion")
	_clear_slots(slots, "potion_data")
	var count = min(slots.size(), available_potions.size())
	for i in range(count):
		var potion = available_potions[i]
		var shop_item = _create_potion_shop_item(potion)   # 创建 ShopItem
		var slot = slots[i]
		slot.visible = true
		slot.set_shop_item ( shop_item )                     # 改为 set_shop_item
		slot.set_run_stats(run_stats)
		_connect_click_signal(slot, "potion_clicked", _on_potion_purchased)
		_connect_hand_signals(slot)
	#print("药水填充完成，实际显示数量：", count)

# ============================================
# 槽位查找与数据设置辅助函数
# ============================================
func _find_slots(container: Node, script_name: String, method_name: String, class_hint: String) -> Array[Control]:
	var slots: Array[Control] = []
	for child in container.get_children():
		if child.get_script() and child.get_script().resource_path.ends_with(script_name):
			slots.append(child)
		elif child.has_method(method_name):
			slots.append(child)
		elif class_hint in child.name or child.is_class(class_hint):
			slots.append(child)
	return slots

func _clear_slots(slots: Array, data_property: String) -> void:
	for slot in slots:
		slot.visible = false
		_set_data(slot, data_property, null)

func _set_data(node: Object, property: String, value) -> void:
	if property in node:
		node.set(property, value)
	elif node.has_method("set_" + property):
		node.call("set_" + property, value)

func _connect_click_signal(slot: Control, signal_name: String, callback: Callable) -> void:
	if slot.has_signal(signal_name):
		var sig = slot.get(signal_name)
		if not sig.is_connected(callback):
			sig.connect(callback.bind(slot))

func _connect_hand_signals(node: Object, hover_offset: Vector2 = Vector2(-60, -200)) -> void:
	if node.has_signal("hand_hover_requested"):
		var sig = node.hand_hover_requested
		if not sig.is_connected(_on_hand_hover):
			sig.connect(_on_hand_hover)
	if node.has_signal("hand_hide_requested"):
		var sig = node.hand_hide_requested
		if not sig.is_connected(_on_hand_hide):
			sig.connect(_on_hand_hide)

func _connect_card_signals(card_node: MerchantCard) -> void:
	if not card_node.card_clicked.is_connected(_on_card_purchased):
		card_node.card_clicked.connect(_on_card_purchased.bind(card_node))
	_connect_hand_signals(card_node)

# ============================================
# 价格生成
# ============================================
func _apply_random_price_and_discount(card: Card) -> void:
	var range_vec = _get_price_range_by_rarity(card.rarity)
	var base_price = randi_range(int(range_vec.x), int(range_vec.y))
	if randf() < DISCOUNT_CHANCE:
		card.on_sale = true
		card.original_price = base_price
		card.shop_price = int(base_price * randf_range(DISCOUNT_FACTOR_MIN, DISCOUNT_FACTOR_MAX))
	else:
		card.on_sale = false
		card.shop_price = base_price

func _apply_random_price_to_relic(relic: Relic) -> void:
	relic.shop_price = randi_range(RELIC_PRICE_MIN, RELIC_PRICE_MAX)
	relic.on_sale = false

func _apply_random_price_to_potion(potion: Potion) -> void:
	potion.shop_price = randi_range(POTION_PRICE_MIN, POTION_PRICE_MAX)
	potion.on_sale = false

func _get_price_range_by_rarity(rarity: Card.Rarity) -> Vector2:
	match rarity:
		Card.Rarity.COMMON:   return Vector2(30, 50)
		Card.Rarity.UNCOMMON: return Vector2(60, 80)
		Card.Rarity.RARE:     return Vector2(100, 120)
		_:                   return Vector2(30, 50)

# ============================================
# 购买回调
# ============================================
func _on_card_purchased(shop_item: ShopItem, card_node: MerchantCard) -> void:
	if not _can_afford(shop_item.shop_price):
		_say_random("purchase_fail", 1.5)
		_shake_node(card_node)  
		return
	run_stats.gold -= shop_item.shop_price
#	卡牌复制
	_add_card_to_deck(shop_item.item_data.duplicate())
	card_node.visible = false
	card_node.set_meta("purchased", true)
	_say_random("purchase_success", 2.0)	
	#print("成功购买卡牌：", card.id)

func _on_relic_purchased(shop_item: ShopItem, relic_node: MerchantRelic) -> void:
	if not _can_afford(shop_item.shop_price):
		_say_random("purchase_fail", 1.5)
		_shake_node(relic_node)  
		return
	run_stats.gold -= shop_item.shop_price
	run_stats.add_relic(shop_item.item_data)
	relic_node.visible = false
	relic_node.set_meta("purchased", true)
	_say_random("purchase_success", 2.0)
	#print("成功购买遗物：", relic.relic_name)
	
func _on_potion_purchased(shop_item: ShopItem, potion_node: MerchantPotion) -> void:
	if not _can_afford(shop_item.shop_price):
		_say_random("purchase_fail", 1.5)
		_shake_node(potion_node)  
		return
	run_stats.gold -= shop_item.shop_price
	if not run_stats.add_potion(shop_item.item_data):
		run_stats.gold += shop_item.shop_price
		_say_random("potion_full", 1.5)
		return
	potion_node.visible = false
	potion_node.set_meta("purchased", true)
	_say_random("purchase_success", 2.0)
	#print("成功购买药水：", potion.potion_name)
	
func _on_card_removal_purchased(price: int):
	#print("卡牌移除服务点击，价格: ", price)
	if not _can_afford(price):
		_say_random("purchase_fail", 1.5)
		_shake_node(card_removal_node)  
		return
	#print("金币足够，开始选择卡牌...")
	var selected_card = await _show_card_removal_selection()
	if selected_card == null:
		_say_random("card_removal_cancel", 1.5)
		#print("未选择任何卡牌或选择取消，不扣金币")
		return
	#print("玩家选择了卡牌: ", selected_card.id)
	run_stats.gold -= price
	var run_node = _get_run_node()
	if run_node and run_node.character and run_node.character.deck:
		run_node.character.deck.remove_card(selected_card)
		_say_random("card_removal_success", 2.0)
		#print("成功移除卡牌: ", selected_card.id)
		
func _can_afford(price: int) -> bool:
	if not run_stats:
		print("RunStats 未初始化")
		return false
	if run_stats.gold < price:
		#print("金币不足，无法购买")
		return false
	return true

# ============================================
# 卡牌移除
# ============================================
func _show_card_removal_selection() -> Card:
	is_exiting = false
	var run_node = _get_run_node()
	if not run_node or not run_node.character:
		print("无法获取角色数据")
		return null
	var deck = run_node.character.deck
	if not deck or deck.cards.is_empty():
		print("牌组为空，无法移除卡牌")
		return null

	var deck_view: DeckView = get_node_or_null("/root/Run/DeckViewLayer/DeckView") as DeckView
	if not deck_view:
		deck_view = run_node.get_node_or_null("DeckViewLayer/DeckView") as DeckView
	if not deck_view:
		deck_view = _find_node_of_type(run_node, DeckView)
	
	if not deck_view:
		print("严重错误：未找到 DeckView 节点，无法弹出选择界面")
		return null

	print("成功获取 DeckView，正在调用 select_card_pile...")
	
	var selected = await deck_view.select_card_pile(
		deck.cards.duplicate(),
		1, 1,
		"选择一张卡牌移除"
	)
	print("选择结果数组大小: ", selected.size())
	is_exiting = true
	if selected.size() > 0:
		return selected[0]
	return null

# ============================================
# 手部控制
# ============================================
func _on_hand_hover(card_node: Node) -> void:
	if not merchant_hand:
		return
	_stop_hand_timers_and_shake()
	
	var offset := Vector2(-60, -200)
	if card_node is MerchantRelic or card_node is MerchantPotion:
		offset = Vector2(-40, -70)
	elif card_node is MerchantCardRemoval:
		offset = Vector2(-40, -20)
	
	_move_hand_to_node(card_node, offset)

func _move_hand_to_node(target_node: Node, offset: Vector2) -> void:
	var center = target_node.global_position + target_node.size * target_node.scale * 0.5
	base_hand_pos = center + offset
	hand_move_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	hand_move_tween.tween_property(merchant_hand, "global_position", base_hand_pos, 2)
	hand_move_tween.tween_callback(_start_shake)
	merchant_hand.visible = true

func _stop_hand_timers_and_shake() -> void:
	if hand_hide_timer:
		hand_hide_timer.stop()
	_stop_shake()

func _start_shake() -> void:
	hand_shake_timer.stop()
	hand_shake_timer.start()

func _stop_shake() -> void:
	hand_shake_timer.stop()
	if current_shake_tween and current_shake_tween.is_valid():
		current_shake_tween.kill()
	if hand_move_tween and hand_move_tween.is_valid():
		hand_move_tween.kill()

func _on_hand_hide() -> void:
	if hand_hide_timer:
		hand_hide_timer.start()

func _on_hand_hide_timeout() -> void:
	_stop_shake()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(merchant_hand, "position", Vector2(234, -54), 2)

func _apply_hand_shake() -> void:
	if not merchant_hand or base_hand_pos == Vector2.ZERO:
		return
	var offset = Vector2(randf_range(-1.5, 1.5), randf_range(-1.5, 1.5))
	if current_shake_tween and current_shake_tween.is_valid():
		current_shake_tween.kill()
	current_shake_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	current_shake_tween.tween_property(merchant_hand, "global_position", base_hand_pos + offset, 0.12)

#这里可以考虑购买后不立即收回
func _reset_hand_immediately() -> void:
	_stop_hand_timers_and_shake()
	merchant_hand.position = Vector2(234, -54)

# ============================================
# UI 交互与动画
# ============================================
func _set_slots_initial_position(slots: Control) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var target_x = (viewport_size.x - slots.size.x) / 2
	slots.set_meta("target_position", Vector2(target_x, 0))
	slots.position = Vector2(target_x, -slots.size.y)

#仓库滑下
func _show_inventory() -> void:
	if not slots_container:
		return
	slots_container.visible = true
	var root = get_tree().root
	if slots_container.get_parent() != root:
		slots_container.reparent(root)
	slots_container.z_index = 3

	var target_pos: Vector2 = slots_container.get_meta("target_position", Vector2.ZERO)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(slots_container, "position", target_pos, 0.5)
	tween.parallel().tween_property(slots_container, "modulate:a", 1.0, 0.3).from(0.0)

	back_button.visible = true
	back_button.z_index = 10
	if backstop:
		backstop.visible = true
		create_tween().tween_property(backstop, "modulate:a", 0.7, 0.3)

	if not cards_populated:
		_populate_cards()
		_populate_relics()
		_populate_potions()
		_update_all_affordability()
		cards_populated = true


func _on_back_button_pressed() -> void:
	_reset_hand_immediately()
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
#	快速返回,实际上还会有bug
	tween.tween_property(slots_container, "position:y", -slots_container.size.y, 0.1)
	tween.parallel().tween_property(slots_container, "modulate:a", 0.0, 0.3)
	if backstop:
		var mask_tween = create_tween()
		mask_tween.tween_property(backstop, "modulate:a", 0.0, 0.3)
		mask_tween.tween_callback(func(): backstop.visible = false)
	tween.tween_callback(_reset_inventory_position)

func _reset_inventory_position() -> void:
	if slots_container.get_parent() != inventory:
		slots_container.reparent(inventory)
	slots_container.visible = false
	back_button.visible = false

# ============================================
# 辅助函数
# ============================================
func _create_card_shop_item(card: Card) -> ShopItem:
	var range_vec = _get_price_range_by_rarity(card.rarity)
	var base_price = randi_range(int(range_vec.x), int(range_vec.y))
	if randf() < DISCOUNT_CHANCE:
		var discount_price = int(base_price * randf_range(DISCOUNT_FACTOR_MIN, DISCOUNT_FACTOR_MAX))
		return ShopItem.new(card, discount_price, true, base_price)
	else:
		return ShopItem.new(card, base_price, false, 0)

func _create_relic_shop_item(relic: Relic) -> ShopItem:
	var price = 0
	if relic.rarity == Relic.Rarity.COMMON:
		price = randi_range(RELIC_PRICE_MIN*0.2, RELIC_PRICE_MIN*0.4)
	elif relic.rarity == Relic.Rarity.UNCOMMON||relic.rarity == Relic.Rarity.SHOP_RELIC||relic.rarity == Relic.Rarity.EVENT:
		price = randi_range(RELIC_PRICE_MIN*0.4, RELIC_PRICE_MAX*0.4)
	else:
		price = randi_range(RELIC_PRICE_MAX*0.4, RELIC_PRICE_MAX*0.6)
	return ShopItem.new(relic, price, false, 0)

func _create_potion_shop_item(potion: Potion) -> ShopItem:
	var price = 0
	if potion.rarity == Potion.Rarity.COMMON:
		price = randi_range(POTION_PRICE_MIN, POTION_PRICE_MAX)
	elif potion.rarity == Potion.Rarity.COMMON:
		price = randi_range(POTION_PRICE_MAX, POTION_PRICE_MAX*1.4)
	else:
		price = randi_range(POTION_PRICE_MAX*1.5, POTION_PRICE_MAX*1.9)
	return ShopItem.new(potion, price, false, 0)

func _get_run_node() -> Run:
	var current = self
	while current:
		if current is Run:
			return current
		current = current.get_parent()
	return null

func _find_node_of_type(node: Node, type) -> Node:
	if is_instance_of(node, type):
		return node
	for child in node.get_children():
		var found = _find_node_of_type(child, type)
		if found:
			return found
	return null

func _get_character_stats():
	var run_node = _get_run_node()
	return run_node.character if run_node else null

#好像就两个
func _get_character_name() -> String:
	var stats = _get_character_stats()
	if not stats:
		return ""
	match stats.character_name:
		"铁甲战士": return "ironclad"
		"静默猎手": return "silent"
		_: return ""

func _add_card_to_deck(card: Card):
	var run_node = _get_run_node()
	if run_node and run_node.character:
		run_node.character.add_card_to_deck(card)
	else:
		Events.card_purchased.emit(card)
		
#实时更新所有costlabel颜色
func _update_all_affordability():
	_update_all_cards_affordability()
	
	var relics_container = slots_container.get_node_or_null("Relics")
	if relics_container:
		for child in relics_container.get_children():
			if child is MerchantRelic:
				child._update_cost_color()
	
	var potions_container = slots_container.get_node_or_null("Potions")
	if potions_container:
		for child in potions_container.get_children():
			if child is MerchantPotion:
				child._update_cost_color()
	
	if card_removal_node:
		card_removal_node._update_cost_color()


func _update_all_cards_affordability():
	for container_name in ["CharacterCards", "ColorlessCards"]:
		var container = slots_container.get_node_or_null(container_name)
		if container:
			for child in container.get_children():
				if child is MerchantCard:
					child._update_cost_color()

# 晃动指定商品节点（购买失败）
func _shake_node(node: Control, intensity: float = 5.0, duration: float = 0.15) -> void:
	if not node:
		return
	
	var original_pos = node.position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	# 快速左右晃动三次
	tween.tween_property(node, "position:x", original_pos.x - intensity, duration * 0.25)
	tween.tween_property(node, "position:x", original_pos.x + intensity, duration * 0.25)
	tween.tween_property(node, "position:x", original_pos.x - intensity * 0.5, duration * 0.25)
	tween.tween_property(node, "position:x", original_pos.x + intensity * 0.5, duration * 0.25)
	tween.tween_property(node, "position:x", original_pos.x, duration * 0.25)

# ============================================
# 输入处理
# ============================================
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			accept_event() 
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_mouse_click(event)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if is_exiting == false:
		return
	var local = make_input_local(event)
	if local is InputEventMouseMotion:
		var inside = Rect2(Vector2.ZERO, size).has_point(local.position)
		if inside != is_hovered:
			is_hovered = inside
			_set_hover_effect(inside)
	if back_button and back_button.visible:
		var back_rect = back_button.get_global_rect()
		var inside = back_rect.has_point(event.global_position)
		if inside != back_button_hovered:
			back_button_hovered = inside
			_set_back_button_scale(inside)

func _handle_mouse_click(event: InputEventMouseButton) -> void:
	if is_exiting == false:
		return
	# 优先检测 back_button 的点击
	if back_button and back_button.visible:
		if back_button.get_global_rect().has_point(event.global_position):
			_on_back_button_pressed()
			accept_event()
			return
	# 如果库存未打开，点击商人身体区域由 MerchantButton 信号处理，这里不再重复

func _set_back_button_scale(active: bool) -> void:
	if not back_button: return
	var target = Vector2(1.2, 1.2) if active else Vector2.ONE
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).tween_property(back_button, "scale", target, 0.15)

func _set_hover_effect(active: bool) -> void:
	if not highlight_polygon: return
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT).tween_property(highlight_polygon, "modulate:a", 1.0 if active else 0.0, 0.15)

# ============================================
# 返回地图按钮
# ============================================
func _on_return_map_pressed() -> void:
	is_exiting = false
	Events.shop_exited.emit()

func _on_return_button_entered():
	return_button.scale = Vector2(1.1, 1.1)

func _on_return_button_exited():
	return_button.scale = Vector2(1, 1)

# ============================================
# BackButton 的 gui_input 保障（Control 专用）
# ============================================
func _on_back_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_back_button_pressed()
		accept_event()

func _get_character_color_mask(char_name: String) -> int:
	match char_name:
		"ironclad": return Card.COLOR.RED
		"silent":   return Card.COLOR.GREEN
		# 后续添加其他角色时扩展此处
		_: return 0


#保存功能
#立即收回仓库
func _close_inventory_immediate() -> void:
	if not slots_container:
		return
	# 如果容器被移到了根节点，放回 inventory 下
	if slots_container.get_parent() != inventory:
		slots_container.reparent(inventory)
	slots_container.visible = false
	# 重置位置到屏幕上方（与初始化位置一致）
	var target_x = slots_container.get_meta("target_position", Vector2.ZERO).x
	slots_container.position = Vector2(target_x, -slots_container.size.y)
	slots_container.modulate.a = 1.0
	back_button.visible = false
	if backstop:
		backstop.visible = false
		backstop.modulate.a = 0.0
	_reset_hand_immediately()

func get_save_state() -> Dictionary:
	# 强制关闭库存（无动画）
	if slots_container and slots_container.visible:
		_close_inventory_immediate()

	var state := {
		"cards_populated": cards_populated,
		"card_removal_purchased": false,
		"slots": {},           # 结构：{容器名: [槽位状态, ...]}
		"inventory_open": false   # 始终保持不打开
	}

	if not is_instance_valid(card_removal_node) or not card_removal_node.visible:
		state["card_removal_purchased"] = true

	for container_name in ["CharacterCards", "ColorlessCards", "Relics", "Potions"]:
		var container = slots_container.get_node_or_null(container_name)
		if not container:
			continue
		var children = container.get_children()
		var slot_states: Array = []
		for i in range(children.size()):
			var child = children[i]
			var slot_info := {
				"index": i,
				"visible": child.visible,
				"purchased": child.get_meta("purchased", false)
			}
			if child.visible:
				var shop_item: ShopItem = child.get_shop_item()
				if shop_item:
					slot_info["resource_path"] = shop_item.item_data.resource_path
					slot_info["price"] = shop_item.shop_price
					slot_info["on_sale"] = shop_item.on_sale
					slot_info["original_price"] = shop_item.original_price
				else:
					slot_info["empty"] = true
			slot_states.append(slot_info)
		state["slots"][container_name] = slot_states

	return state


func set_save_state(state: Dictionary) -> void:
	if state.is_empty():
		return

	if not run_stats:
		_initialize_run_stats()

	cards_populated = state.get("cards_populated", false)
	if state.get("card_removal_purchased", false):
		if is_instance_valid(card_removal_node):
			card_removal_node.visible = false
			card_removal_node.set_meta("purchased", true)

	# 库存始终保持关闭（你最后的要求）
	# 隐藏所有槽位，清空商品数据及标记
	for container_name in ["CharacterCards", "ColorlessCards", "Relics", "Potions"]:
		var container = slots_container.get_node_or_null(container_name)
		if not container:
			continue
		for child in container.get_children():
			child.visible = false
			child.set_meta("purchased", false)
			if child.has_method("clear_shop_item"):
				child.clear_shop_item()

	# 按保存的槽位顺序恢复
	var slots_state = state.get("slots", {})
	for container_name in slots_state.keys():
		var container = slots_container.get_node_or_null(container_name)
		if not container:
			continue
		var saved_slots: Array = slots_state[container_name]
		var children = container.get_children()
		for slot_info in saved_slots:
			var idx = slot_info["index"]
			if idx < 0 or idx >= children.size():
				continue
			var child = children[idx]
			if slot_info.get("visible") and slot_info.has("resource_path"):
				# 有商品 → 显示并恢复
				var item_data = load(slot_info["resource_path"])
				if item_data:
					var shop_item := ShopItem.new(
						item_data,
						slot_info["price"],
						slot_info["on_sale"],
						slot_info["original_price"]
					)
					child.visible = true
					child.set_meta("purchased", false)
					child.set_shop_item(shop_item)
					if run_stats:
						child.set_run_stats(run_stats)
					# 重连信号
					_connect_signals_for_child(child, container_name)
			elif slot_info.get("purchased", false):
				# 已购买的空位 → 保持隐藏，标记 purchased
				child.visible = false
				child.set_meta("purchased", true)
				if child.has_method("clear_shop_item"):
					child.clear_shop_item()
			else:
				# 未使用的空位 → 隐藏，无标记
				child.visible = false
				child.set_meta("purchased", false)
				if child.has_method("clear_shop_item"):
					child.clear_shop_item()

	_update_all_affordability()


# 恢复时重连信号的辅助函数（添加在文件中）
func _connect_signals_for_child(child: Node, container_name: String) -> void:
	if child is MerchantCard:
		if not child.card_clicked.is_connected(_on_card_purchased):
			child.card_clicked.connect(_on_card_purchased.bind(child))
		_connect_hand_signals(child)
	elif child is MerchantRelic:
		_connect_click_signal(child, "relic_clicked", _on_relic_purchased)
		_connect_hand_signals(child)
	elif child is MerchantPotion:
		_connect_click_signal(child, "potion_clicked", _on_potion_purchased)
		_connect_hand_signals(child)

# 快速显示库存（无滑下动画）
func _show_inventory_instant() -> void:
	if not slots_container:
		return
	slots_container.visible = true
	var root = get_tree().root
	if slots_container.get_parent() != root:
		slots_container.reparent(root)
	slots_container.z_index = 3
	slots_container.position = slots_container.get_meta("target_position", Vector2.ZERO)
	slots_container.modulate.a = 1.0
	back_button.visible = true
	back_button.z_index = 10
	if backstop:
		backstop.visible = true
		backstop.modulate.a = 0.7


# 根据类型恢复商品到对应容器
func _restore_good(shop_item: ShopItem, type: String) -> void:
	match type:
		"card":
			for container_name in ["CharacterCards", "ColorlessCards"]:
				var container = slots_container.get_node_or_null(container_name)
				if not container:
					continue
				for child in container.get_children():
					if not child.visible and child is MerchantCard:
						child.visible = true
						child.set_shop_item(shop_item)
						if run_stats:
							child.set_run_stats(run_stats)
						_connect_card_signals(child)
						return
		"relic":
			var container = slots_container.get_node_or_null("Relics")
			if not container:
				return
			for child in container.get_children():
				if not child.visible and child is MerchantRelic:
					child.visible = true
					child.set_shop_item(shop_item)
					child.set_run_stats(run_stats)
					_connect_click_signal(child, "relic_clicked", _on_relic_purchased)
					_connect_hand_signals(child)
					return
		"potion":
			var container = slots_container.get_node_or_null("Potions")
			if not container:
				return
			for child in container.get_children():
				if not child.visible and child is MerchantPotion:
					child.visible = true
					child.set_shop_item(shop_item)
					child.set_run_stats(run_stats)
					_connect_click_signal(child, "potion_clicked", _on_potion_purchased)
					_connect_hand_signals(child)
					return
	# 如果没有空闲槽位（理论上不会），打印警告
	print("警告：无法恢复商品，无空闲槽位：", type)


# 判断槽位类型（辅助函数）
func _get_good_type(node: Node) -> String:
	if node is MerchantCard:
		return "card"
	if node is MerchantRelic:
		return "relic"
	if node is MerchantPotion:
		return "potion"
	return ""



	
