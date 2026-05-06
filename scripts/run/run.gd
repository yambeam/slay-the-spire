class_name Run
extends Node

# 场景资源
const MAIN_MENU_PATH := "res://scenes/main_menu/main_menu.tscn"

const COMBAT_SCENE := preload("res://scenes/rooms/combat_room/combat_room.tscn")
const COMBAT_REWARD_SCENE := preload("res://scenes/rooms/reward/reward_room.tscn")
const CAMPFIRE_SCENE := preload("res://scenes/rooms/campfire_room/campfire_room.tscn")
const MAP_SCENE := preload("res://scenes/map/map.tscn")
const SHOP_SCENE := preload("res://scenes/rooms/shop_room/shop_room.tscn")
const TREASURE_SCENE := preload("res://scenes/rooms/treasure_room/treasure_room.tscn")
const INCIDENT_SCENE := preload("res://scenes/rooms/incident_room/incident_room.tscn")

# 两个先古场景（根据阶段动态选择）
const ANCIENT_SCENE_NEOW := preload("res://scenes/rooms/ancient_room/neow_ancient_room.tscn")
const ANCIENT_SCENE_OROBAS := preload("res://scenes/rooms/ancient_room/orobas_ancient_room.tscn")

const BATTLE_REWARD_SCENE = preload("res://scenes/rooms/reward/reward_room.tscn")

@onready var current_room: Node = $CurrentRoom

@onready var combat: Button = %combat
@onready var treasure: Button = %treasure
@onready var shop: Button = %shop
@onready var campfire: Button = %campfire
@onready var rewards: Button = %rewards
@onready var incident: Button = %incident

@onready var map: Button = %map
@onready var map_node: Map = $Map
@onready var top_bar: TopBar = %TopBar
@onready var deck_view: DeckView = %DeckView
@onready var select_deck_view: DeckView = %SelectDeckView
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var death_settlement: DeathSettlement = $death_settlement

@export var run_startup: RunStartup

var character: CharacterStats
var stats: RunStats
var save_data: SaveGame


#杀掉的精英怪数量
@export var elite_mob_killed:int = 0
@export var loading_status: int = 0


# 标记 Boss 战后是否需要进入阶段切换
var _pending_stage_transition: bool = false

func _ready() -> void:
	if not run_startup:
		return
	pause_menu.save_and_quit.connect(
		func():
			get_tree().change_scene_to_file(MAIN_MENU_PATH)
	)
	death_settlement.DeathSettlementBackToMainMenu.connect(
		func():
			save_data.delete_data()
			get_tree().change_scene_to_file(MAIN_MENU_PATH)
	)
	
	Events.map_room_selected.connect(_on_map_room_selected)
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.picked_character.create_instance()
			_start_run()
		RunStartup.Type.CONTINUE_RUN:
			_load_run()
			print("加载游戏")

func _on_map_room_selected(room: Room) -> void:
	print("进入房间，保存游戏")
	map_node.last_room = room
	_save_run(false)
	match room.type:
		Room.Type.MONSTER, Room.Type.ELITE, Room.Type.BOSS:
			if room.type==Room.Type.ELITE:
				elite_mob_killed+=1
			_on_combat_room_entered(room)
			Events.combat_room_entered.emit(room, stats, character)
			return
		Room.Type.TREASURE:
			_on_treasure_room_entered(room)
			return
		Room.Type.SHOP:
			_on_shop_room_entered(room)
			return
		Room.Type.CAMPFIRE:
			_on_campfire_room_entered(room)
			return
		Room.Type.UNKNOWN:
			_handle_unknown_room(room)
			Events.unknown_room_entered.emit(room, stats, character)
			return
		Room.Type.ANCIENT:
			_on_ancient_room_entered(room)
		_:
			return

################实现问号房逻辑####################
var unknown_room_probs = {
	"combat": 0.10,      # 战斗
	"shop": 0.02,       # 商人
	"treasure": 0.03,   # 宝箱
	"incident": 0.85    # 事件
}

var last_unknown_room_type: String = ""
var compensation_chance: float = 0.0

func _handle_unknown_room(room: Room) -> void:
	var current_probs = calculate_compensated_probabilities()
	var room_type = get_random_room_type(current_probs)
	
	match room_type:
		"combat":
			_on_combat_room_entered(room)
		"shop":
			_change_view(SHOP_SCENE)
		"treasure":
			_change_view(TREASURE_SCENE)
		"incident":
			_on_incident_room_entered(room)
		_:
			_on_incident_room_entered(room)
	
	update_compensation(room_type)

func calculate_compensated_probabilities() -> Dictionary:
	var probs = unknown_room_probs.duplicate()
	if last_unknown_room_type == "":
		return probs
	
	if compensation_chance > 0:
		probs[last_unknown_room_type] -= compensation_chance
		probs[last_unknown_room_type] = max(probs[last_unknown_room_type], 0.01)
		
		var other_types = []
		for type in probs.keys():
			if type != last_unknown_room_type:
				other_types.append(type)
		var bonus_per_type = compensation_chance / other_types.size()
		for type in other_types:
			probs[type] += bonus_per_type
	
	var total = 0.0
	for prob in probs.values():
		total += prob
	if total > 0:
		for type in probs.keys():
			probs[type] /= total
	return probs

func get_random_room_type(probabilities: Dictionary) -> String:
	var roll = randf()
	var cumulative = 0.0
	for room_type in probabilities.keys():
		cumulative += probabilities[room_type]
		if roll <= cumulative:
			return room_type
	return "incident"

func update_compensation(current_room_type: String) -> void:
	if current_room_type == last_unknown_room_type:
		compensation_chance += 0.05
	else:
		compensation_chance = 0.0
	last_unknown_room_type = current_room_type

# ========== 游戏流程 ==========
func _start_run() -> void:
	stats = RunStats.new()
	_setup_event_connections()
	_setup_top_bar()
	map_node.init(stats)
	ItemPool.init_item_pool(character.color)
	save_data = SaveGame.new()
	_show_map()

func _save_run(was_on_map: bool) -> void:
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.last_room = map_node.last_room
	save_data.was_on_map = was_on_map
	save_data.potions = stats.potions
	save_data.relics = stats.relics
	save_data.save_data()

func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "could not load last save")
	character = save_data.char_stats
	stats = save_data.run_stats
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	ItemPool.init_item_pool(character.color)
	for potion in save_data.potions:
		print("加载药水")
		stats.add_potion(potion)
	stats.relics = save_data.relics
	_load_up_top_bar()
	_setup_event_connections()
	map_node.load_map(stats, save_data.last_room)
	if save_data.last_room and not save_data.was_on_map:
		print("was on map : false")
		_on_map_room_selected(save_data.last_room)
	else:
		_show_map()

func _load_up_top_bar() -> void:
	top_bar.run_stats = stats
	top_bar.character_stats = character
	top_bar.initialize(character)
	top_bar.deck_view_requested.connect(deck_view.show_card_pile.bind("你在战斗中将会使用这里的所有卡牌。", false))
	top_bar.select_deck_view = select_deck_view
	top_bar.relic_handler.add_relics(stats.relics)
	top_bar.settings_requested.connect(handleSettingsRequest)

func _setup_top_bar() -> void:
	top_bar.run_stats = stats
	top_bar.character_stats = character
	top_bar.initialize(character)
	top_bar.deck_view_requested.connect(deck_view.show_card_pile.bind("你在战斗中将会使用这里的所有卡牌。", false))
	top_bar.select_deck_view = select_deck_view
	top_bar.relic_handler.add_relic(character.starting_relic)
	top_bar.settings_requested.connect(handleSettingsRequest)

func handleSettingsRequest() -> void:
	pause_menu._pause()

func _change_view(scene: PackedScene) -> Node:
	if current_room.get_child_count() > 0:
		current_room.get_child(0).queue_free()
	
	var new_view := scene.instantiate()
	current_room.add_child(new_view)
	return new_view

# ========== 战斗奖励与阶段切换 ==========
func _on_combat_won(context: RewardContext) -> void:
	var reward_scene := await _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.add_rewards(map_node.last_room, context)

	
	if map_node.last_room and map_node.last_room.type == Room.Type.BOSS:
		_pending_stage_transition = true
		print("boss房胜利")

func _on_combat_reward_exited() -> void:
	_on_room_exited()
	if _pending_stage_transition:
		_pending_stage_transition = false
		_transition_to_next_stage()


func _transition_to_next_stage() -> void:
	#current_room.hide()
	#for child in current_room.get_children():
		#child.queue_free()
	# 1. 推进阶段（current_stage 从 1 变为 2）
	stats.advance_stage()
	print("当前阶段:",stats.current_stage);
	# 2. 重置旧地图数据（清空地图数组和楼层计数）
	stats.reset_map()
	
	map_node.play_stage_transition(stats.current_stage)
	print("当前地图数据置空")
	# 3. 重建第二阶段地图（起点自动为 Ancient 房间）
	print("======开始重建地图数据*")
	#map_node.rebuild_for_stage(stats)
	print("======结束*")
	# 4. 显示新地图，玩家站在起点（没有任何弹出窗口）
	print("=======展示地图")
	#_show_map()

func _setup_event_connections() -> void:
	Events.combat_won.connect(
		func(context: RewardContext):
			await get_tree().process_frame
			_on_combat_won(context)
	)
	Events.player_died_outside.connect(_on_player_died_outside)
	Events.player_died.connect(on_player_died)
	Events.combat_reward_exited.connect(_on_room_exited)
	# ★ 修改：战斗奖励退出使用分流函数
	Events.combat_reward_exited.connect(_on_combat_reward_exited)
	
	Events.shop_exited.connect(_on_room_exited)
	Events.treasure_room_exited.connect(_on_room_exited)
	Events.incident_exited.connect(_on_room_exited)
	Events.campfire_exited.connect(_on_room_exited)
	# 普通 Ancient 房间退出（地图上 Ancient 格子）也走正常流程
	Events.ancient_exited.connect(_on_room_exited)
	
	Events.map_exited.connect(_on_map_exited)
	map.pressed.connect(_show_map)
	
	# 测试按钮（调试用）
	combat.pressed.connect(_on_combat_room_entered.bind(null))
	rewards.pressed.connect(_on_rewards_pressed)
	treasure.pressed.connect(_on_treasure_pressed)
	shop.pressed.connect(_on_shop_pressed)
	campfire.pressed.connect(_on_campfire_pressed)
	incident.pressed.connect(_on_incident_pressed)
	
	# 先古遗物选择信号
	Events.ancient_relic_selected.connect(_on_ancient_relic_selected)

func _on_player_died_outside()->void:
	
	if stats.current_room.type not in [Room.Type.MONSTER, Room.Type.BOSS,Room.Type.ELITE]:
		on_player_died()
		

func on_player_died()->void:
	get_tree().paused=true
	death_settlement.char_stats=character
	death_settlement.run_stats=stats
	
	print("角色死亡")
	if stats.current_room.type==Room.Type.ELITE:
		elite_mob_killed-=1
	death_settlement.init(elite_mob_killed)
	death_settlement.show()
	

func _on_rewards_pressed():
	await _change_view(COMBAT_REWARD_SCENE)

func _on_treasure_pressed():
	_on_treasure_room_entered(null)

func _on_shop_pressed():
	_on_shop_room_entered(null)

func _on_campfire_pressed():
	_on_campfire_room_entered(null)

func _on_incident_pressed():
	_on_incident_room_entered(null)

func _show_map() -> void:
	if current_room.get_child_count() > 0:
		current_room.get_child(0).hide()
	map_node.show_map()
	
	if stats.current_room!=null:
		stats.current_room.type=Room.Type.NOT_ASSIGNED
	_save_run(true)

func _on_map_exited() -> void:
	map_node.hide()
	if current_room.get_child_count() > 0:
		current_room.get_child(0).show()
	print("map_exited")

func _on_room_exited() -> void:
	#print(">>> _on_room_exited START")
	#print("current_room children: ", current_room.get_children())
	if current_room.get_child_count() > 0:
		var child = current_room.get_child(0)
		#print("Removing child: ", child.name)
		child.queue_free()
		# 立即从父节点移除（不等下一帧）
		current_room.remove_child(child)
		#print("current_room children after remove: ", current_room.get_children())
	#else:
		#print("No child to remove")
	map_node.complete_current_room()
	_show_map()
	print(">>> _on_room_exited END")

# ========== 房间入口 ==========
func _on_combat_room_entered(room: Room = null) -> void:
	var battle_scene: CombatRoom = await _change_view(COMBAT_SCENE)
	battle_scene.char_stats = character
	if room:
		battle_scene.enemy_encounter = room.enemy_encounter
	battle_scene.relics = top_bar.relic_handler
	battle_scene.start_combat()

func _on_shop_room_entered(room: Room) -> void:
	await _change_view(SHOP_SCENE)

func _on_treasure_room_entered(room: Room) -> void:
	await _change_view(TREASURE_SCENE)

func _on_ancient_room_entered(room: Room) -> void:
	var scene: PackedScene
	if stats.current_stage == 1:
		scene = ANCIENT_SCENE_NEOW
	else:
		scene = ANCIENT_SCENE_OROBAS

	var ancient = scene.instantiate()
	ancient.current_stage = stats.current_stage   
	current_room.add_child(ancient)  
		
func _on_ancient_relic_selected(relic: Relic) -> void:
	if stats:
		stats.add_relic(relic)

func _on_campfire_room_entered(room: Room)-> void:
	var capfire_scene :CampfireRoom = _change_view(CAMPFIRE_SCENE) as CampfireRoom
	capfire_scene.char_stats=character
	capfire_scene.deck_view = select_deck_view
	capfire_scene.initialize()
	Events.campfire_entered.emit(room, stats, character)

func _on_incident_room_entered(room: Room)->void:
	var incident_scene :IncidentRoom = _change_view(INCIDENT_SCENE) as IncidentRoom
	incident_scene.char_stats = character
	incident_scene.run_stats=stats
	incident_scene.deck_view= select_deck_view
	incident_scene.init()
	Events.incident_room_entered.emit(room, stats, character)

func _on_shop_entered(room: Room) -> void:
	if current_room.get_child_count() > 0:
		current_room.get_child(0).queue_free()
	
	var loaded_scene = map_node.get_shop_scene()
	if loaded_scene == null:
		loaded_scene = load(SHOP_SCENE.resource_path)
	var new_view = loaded_scene.instantiate()
	current_room.add_child.call_deferred(new_view)
	
	Events.shop_entered.emit(room, stats, character)
