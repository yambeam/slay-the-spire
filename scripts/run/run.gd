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

@onready var current_room: Control = $CurrentRoom
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

var is_scroll_blocked: bool = false

#杀掉的精英怪数量
@export var elite_mob_killed:int = 0
@export var loading_status: int = 0

var is_on_map: bool = true
@export var act1_encounter_pool: EnemyEncounterPool
@export var act2_encounter_pool: EnemyEncounterPool
@export var mob_killed_this_act: int = 0

# 负责背景音乐播放
@export var bgm_proxy: BGMProxy

# 标记 Boss 战后是否需要进入阶段切换
var _pending_stage_transition: bool = false


#当前时否在保存
var _restoring: bool = false

# 战斗前快照（记录进入战斗房间前一刻的状态）
var pre_combat_snapshot: Dictionary = {}

func back_to_main()->void:
	
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
	

func _ready() -> void:
	
	if not run_startup:
		return
	pause_menu.save_and_quit.connect(
		func():
			#var on_map := is_on_map  # 假设 Map 节点有 visible 属性；若无，需手动维护 is_on_map 变量
			# 不需要在这里保存
			#_save_run(on_map)
			#get_tree().change_scene_to_file(MAIN_MENU_PATH)
			
			_save_run(is_on_map)
			#if is_on_map:
				#save_data.state = save_data.State.ON_MAP
			#else:
				#save_data.state = save_data.State.IN_ROOM
				#save_data.map_camera_y = 0.0
				#save_data.map_old_camera_y = 0.0
				#if current_room.get_child_count() > 0 and current_room.get_child(0) is BattleReward:
					#save_data.is_battle_reward = true
					#save_data.room_state = _collect_room_state()
			#print(save_data.potions)
			#save_data.save_data()
			
			back_to_main()
	)
	death_settlement.DeathSettlementBackToMainMenu.connect(
		func():
			save_data.delete_data()
			back_to_main()
	)
	
	Events.map_room_selected.connect(_on_map_room_selected)
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			SaveGame.delete_data()
			character = run_startup.picked_character.create_instance()
			_start_run()
		RunStartup.Type.CONTINUE_RUN:
			_load_run()
			print("_load_run:加载游戏数据")

func _on_map_room_selected(room: Room) -> void:
	print("[MapSelect] room.type = ", room.type, " row=", room.row, " col=", room.column)
	is_scroll_blocked = true
	is_on_map = false
	#print("进入房间，保存游戏")
	map_node.last_room = room
	
	match room.type:
		Room.Type.MONSTER, Room.Type.ELITE, Room.Type.BOSS:
			if room.type==Room.Type.ELITE:
				elite_mob_killed+=1
			_on_combat_room_entered(room)
			Events.combat_room_entered.emit(room, stats, character)
		Room.Type.TREASURE:
			_on_treasure_room_entered(room)
		Room.Type.SHOP:
			_on_shop_room_entered(room)
		Room.Type.CAMPFIRE:
			_on_campfire_room_entered(room)
		Room.Type.UNKNOWN:
			_handle_unknown_room(room)
			Events.unknown_room_entered.emit(room, stats, character)
		Room.Type.ANCIENT:
			_on_ancient_room_entered(room)
		_:
			pass
	_save_run(false)
	bgm_proxy.update_music(room, stats.current_stage)
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
	
	if map_node.last_room.unknownType:
		match map_node.last_room.unknownType:
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
		return
	
	var current_probs = calculate_compensated_probabilities()
	var room_type = get_random_room_type(current_probs)
	map_node.last_room.unknownType=room_type
	#_save_run(false)
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
	stats.add_potion(preload("res://entities/potions/灾厄药水.tres").duplicate())
	_setup_event_connections()
	_setup_top_bar()
	map_node.init(stats)
	ItemPool.init_item_pool(character.color)
	
#	保存数据
	save_data = SaveGame.new()
	_show_map()
	
	act1_encounter_pool.setup()
	act2_encounter_pool.setup()


func _load_up_top_bar() -> void:
	
	top_bar.run_stats = stats
	top_bar.character_stats = character
	
	top_bar.initialize(character)
	
	top_bar.deck_view_requested.connect(deck_view.show_card_pile.bind("你在战斗中将会使用这里的所有卡牌。", false))
	top_bar.select_deck_view = select_deck_view
	
	top_bar.relic_handler.add_relics(stats.relics)
	
	top_bar.settings_requested.connect(handleSettingsRequest)
	top_bar.top_bar_potion.update_potion_slot()

func _setup_top_bar() -> void:
	top_bar.run_stats = stats
	top_bar.character_stats = character
	top_bar.initialize(character)
	top_bar.deck_view_requested.connect(deck_view.show_card_pile.bind("你在战斗中将会使用这里的所有卡牌。", false))
	top_bar.select_deck_view = select_deck_view
	#top_bar.relic_handler.add_relic(character.starting_relic)
	stats.add_relic(character.starting_relic)
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
	if map_node.last_room and map_node.last_room.type == Room.Type.BOSS:
		if stats.current_stage >= stats.max_stage:
			_victory()
			return
		_pending_stage_transition = true
		print("boss房胜利")
	var reward_scene := await _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.add_rewards(map_node.last_room, context)
	_save_run(false)

	
	

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
	if stats.current_stage < stats.max_stage:
		stats.advance_stage()
	print("当前阶段:",stats.current_stage);
	# 2. 重置旧地图数据（清空地图数组和楼层计数）
	stats.reset_map()
	
	map_node.play_stage_transition(stats.current_stage)
	#print("当前地图数据置空")
	## 3. 重建第二阶段地图（起点自动为 Ancient 房间）
	#print("======开始重建地图数据*")
	##map_node.rebuild_for_stage(stats)
	#print("======结束*")
	## 4. 显示新地图，玩家站在起点（没有任何弹出窗口）
	#print("=======展示地图")
	#_show_map()

func _setup_event_connections() -> void:
	Events.combat_won.connect(
		func(context: RewardContext):
			await get_tree().process_frame
			_on_combat_won(context)
	)
	Events.player_died_outside.connect(_on_player_died_outside)
	Events.player_died.connect(on_player_died)
	#Events.combat_reward_exited.connect(_on_room_exited)
	# ★ 修改：战斗奖励退出使用分流函数
	Events.combat_reward_exited.connect(_on_combat_reward_exited)
	
	Events.shop_exited.connect(_on_room_exited)
	Events.treasure_room_exited.connect(_on_room_exited)
	Events.incident_exited.connect(_on_room_exited)
	Events.campfire_exited.connect(_on_room_exited)
	# 普通 Ancient 房间退出（地图上 Ancient 格子）也走正常流程
	Events.ancient_exited.connect(_on_room_exited)
	
	Events.map_exited.connect(_on_map_exited)
	
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
	is_on_map = true
	if current_room.get_child_count() > 0:
		current_room.get_child(0).hide()
	map_node.show_map()
	
	#if stats.current_room!=null:
		#stats.current_room.type=Room.Type.NOT_ASSIGNED
	_save_run(true)

func _on_map_exited() -> void:
	map_node.hide()
	if current_room.get_child_count() > 0:
		current_room.get_child(0).show()
	print("map_exited")

func _on_room_exited() -> void:
	#print(">>> _on_room_exited START")
	#print("current_room children: ", current_room.get_children())
	is_scroll_blocked = false
	is_on_map = true
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
	#print(">>> _on_room_exited END")

# ========== 房间入口 ==========
#func _on_combat_room_entered(room: Room = null) -> void:
	#var encounter_pool: EnemyEncounterPool = act1_encounter_pool if stats.current_stage == 1 else act2_encounter_pool 
	#match room.type:
		#Room.Type.BOSS:
			#mob_killed_this_act = 0
		#Room.Type.ELITE:
			#room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.ELITE)
		#Room.Type.MONSTER, Room.Type.UNKNOWN:
			## 第一章前三个遭遇战从弱怪池中选取
			## 第二章前两个遭遇战从弱怪池中选取
			#mob_killed_this_act += 1
			#if stats.current_stage == 1:
				#if mob_killed_this_act <= 3:
					#room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.WEAK)
				#else:
					#room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.STRONG)
			#else:
				## act2
				#if mob_killed_this_act <= 2:
					#room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.WEAK)
				#else:
					#room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.STRONG)
	#print(room.enemy_encounter)
	#var battle_scene: CombatRoom = await _change_view(COMBAT_SCENE)
	#battle_scene.char_stats = character
	#if room:
		#battle_scene.enemy_encounter = room.enemy_encounter
	#battle_scene.relics = top_bar.relic_handler
	#battle_scene.start_combat()
	
func _on_combat_room_entered(room: Room = null, restore_state: Dictionary = {}) -> void:
	var encounter_pool: EnemyEncounterPool = act1_encounter_pool if stats.current_stage == 1 else act2_encounter_pool

	# 分配遭遇战（恢复时房间已有 enemy_encounter，跳过随机生成）
	if room.enemy_encounter == null:
		match room.type:
			Room.Type.BOSS:
				mob_killed_this_act = 0
			Room.Type.ELITE:
				room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.ELITE)
			Room.Type.MONSTER, Room.Type.UNKNOWN:
				mob_killed_this_act += 1
				if stats.current_stage == 1:
					if mob_killed_this_act <= 3:
						room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.WEAK)
					else:
						room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.STRONG)
				else:
					if mob_killed_this_act <= 2:
						room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.WEAK)
					else:
						room.enemy_encounter = encounter_pool.get_random_encounter_by_type(EnemyEncounter.Type.STRONG)

	# ★ 无条件创建快照（全新进入与读档恢复都需记录战斗前状态，以保证中途存档可正确回滚）
	pre_combat_snapshot = {
		potions = stats.potions.duplicate(true),
		health = character.health,
		max_health = character.max_health,
		random_seed = RandomSetting.instance.seed,
		random_state = RandomSetting.instance.state,
		# 如需保存遗物计数器，可在此添加：relic_counters = ...
	}

	var battle_scene: CombatRoom = await _change_view(COMBAT_SCENE)
	if not is_instance_valid(battle_scene):
		return

	battle_scene.update_background(stats.current_stage)
	battle_scene.char_stats = character
	battle_scene.enemy_encounter = room.enemy_encounter
	battle_scene.relics = top_bar.relic_handler
	battle_scene.start_combat()   # 总是重新开始战斗

	# 记录遭遇战信息到地图房间（供存档用）
	map_node.last_room.enemy_encounter = room.enemy_encounter.duplicate()
	_restoring = false
	
		

func _on_shop_room_entered(room: Room) -> void:
	_change_view(SHOP_SCENE)

func _on_treasure_room_entered(room: Room) -> void:
	_change_view(TREASURE_SCENE)

func _on_ancient_room_entered(room: Room) -> void:
	if current_room.get_child_count() > 0:
		current_room.get_child(0).queue_free()
	var ancient = _get_ancient_scene().instantiate()
	ancient.current_stage = stats.current_stage
	current_room.add_child(ancient)
	ancient.initialize_new()   
	_save_run(false)            
		
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


func _victory() -> void:
	# 删除本次存档
	save_data.delete_data()
	# 返回主菜单
	get_tree().change_scene_to_file(MAIN_MENU_PATH)



#=========存档相关==
func _save_run(on_map: bool) -> void:
	if _restoring:
		return

	# 判断当前是否在“进行中的战斗”（非奖励界面的战斗房间）
	var in_active_combat := false
	if not on_map:
		var room_type = map_node.last_room.type if map_node.last_room else Room.Type.NOT_ASSIGNED
		if room_type in [Room.Type.MONSTER, Room.Type.ELITE, Room.Type.BOSS]:
			if not (current_room.get_child_count() > 0 and current_room.get_child(0) is BattleReward):
				in_active_combat = true

	# ========== 随机数种子与状态 ==========
	# 战斗中存档 → 使用快照中的种子（回到战斗前随机状态）
	if in_active_combat and not pre_combat_snapshot.is_empty():
		save_data.generator_seed = pre_combat_snapshot["random_seed"]
		save_data.generator_state = pre_combat_snapshot["random_state"]
	else:
		save_data.generator_seed = RandomSetting.instance.seed
		save_data.generator_state = RandomSetting.instance.state

	# ========== 人物与进度数据 ==========
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck

	# 药水、血量：战斗中存档用快照回滚，否则保存当前值
	if in_active_combat and not pre_combat_snapshot.is_empty():
		save_data.potions = pre_combat_snapshot["potions"]
		save_data.current_health = pre_combat_snapshot["health"]
		# 如果存在最大血量变化，同样回滚：save_data.current_max_health = pre_combat_snapshot["max_health"]
	else:
		save_data.potions = stats.potions.duplicate()
		save_data.current_health = character.health

	save_data.relics = stats.relics.duplicate()
	save_data.gold = stats.gold
	for relic: Relic in save_data.relics:
		relic.save_count()

	# 相机位置
	save_data.map_camera_y = map_node.camera_2d.position.y
	save_data.map_old_camera_y = map_node.old_camera_2d_position_y

	# 地图数据
	save_data.last_room = map_node.last_room
	if map_node.last_room != null:
		print(map_node.last_room.type)

	if on_map:
		save_data.state = SaveGame.State.ON_MAP
		save_data.room_type = Room.Type.NOT_ASSIGNED
		save_data.room_state = {}
	else:
		# 判断当前界面是否是战斗奖励
		if current_room.get_child_count() > 0 and current_room.get_child(0) is BattleReward:
			save_data.is_battle_reward = true
		else:
			save_data.is_battle_reward = false
		# 收集房间状态（触发商店等 get_save_state，关闭 UI）
		save_data.room_state = _collect_room_state()
		save_data.state = SaveGame.State.IN_ROOM
		save_data.room_type = map_node.last_room.type if map_node.last_room else Room.Type.NOT_ASSIGNED

	# 收集所有房间类型与已选状态
	var types := []
	for floor in stats.map_data:
		var row_types := []
		for room: Room in floor:
			row_types.append(room.type)
		types.append(row_types)
	save_data.map_types = types

	var sel := []
	for floor in stats.map_data:
		for room: Room in floor:
			if room.selected:
				sel.append([room.row, room.column])
	save_data.selected_rooms = sel

	# 写入存档
	save_data.save_data()

	# 记录问号房类型（如果需要）
	save_data.last_room_unknown_type = map_node.last_room.unknownType if map_node.last_room else ""	
	
func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Could not load last save")
	RandomSetting.set_from_save_data(save_data.generator_seed, save_data.generator_state)
	#人物数据加载	
	character = save_data.char_stats
	stats = save_data.run_stats
	stats.potions = save_data.potions
	stats.relics = save_data.relics
	stats.gold = save_data.gold
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	ItemPool.init_item_pool(character.color)
	stats.relics = save_data.relics
	for relic: Relic in save_data.relics:
		relic.load_count()

	_load_up_top_bar()
	_setup_event_connections()
	
	# 恢复每个房间的类型
	for i in min(stats.map_data.size(), save_data.map_types.size()):
		var row_types = save_data.map_types[i]
		var floor = stats.map_data[i]
		for j in min(floor.size(), row_types.size()):
			floor[j].type = row_types[j]

	# 恢复已选状态
	for coord in save_data.selected_rooms:
		var r = coord[0]
		var c = coord[1]
		if r < stats.map_data.size() and c < stats.map_data[r].size():
			stats.map_data[r][c].selected = true
	
	# 恢复相机位置
	map_node.camera_2d.position.y = save_data.map_camera_y
	map_node.old_camera_2d_position_y = save_data.map_old_camera_y
	
	map_node.load_map(stats, save_data.last_room)
	if save_data.last_room:
		save_data.last_room.unknownType = save_data.last_room_unknown_type
	
	match save_data.state:
		SaveGame.State.ON_MAP:
			is_on_map = true
			_show_map()
		SaveGame.State.IN_ROOM:
			is_on_map = false
			_restore_room(save_data.room_type, save_data.last_room)
		_:
			is_on_map = true
			_show_map()  # 安全回退

func _collect_room_state() -> Dictionary:
	if current_room.get_child_count() == 0:
		return {}

	# 奖励房间的保存逻辑保留
	if current_room.get_child(0) is BattleReward:
		var scene = current_room.get_child(0)
		if scene.has_method("get_save_state"):
			return scene.get_save_state()
		return {}

	# 战斗房间不需要保存内部状态，因为会重新开始战斗
	var room_type = map_node.last_room.type if map_node.last_room else Room.Type.NOT_ASSIGNED
	if room_type in [Room.Type.MONSTER, Room.Type.ELITE, Room.Type.BOSS]:
		return {}   # 空状态，读档时直接进入新战斗

	# 其他房间按需保存
	var scene = current_room.get_child(0)
	if scene.has_method("get_save_state"):
		return scene.get_save_state()
	return {}

func _apply_room_state(scene: Node, state: Dictionary) -> void:
	if scene.has_method("set_save_state"):
		scene.set_save_state(state)
		
func _restore_room(type: Room.Type, room: Room) -> void:
	print("Restoring room type: ", type, " room: ", room, " room.type: ", room.type if room else "null")
	_restoring = true
	is_on_map = false
	var state_to_apply := save_data.room_state.duplicate()  
	
	if save_data.is_battle_reward:
		var reward_scene = BATTLE_REWARD_SCENE.instantiate()
		current_room.add_child(reward_scene)
		reward_scene.run_stats = stats
		reward_scene.character_stats = character          
		if reward_scene.has_method("set_save_state"):
			reward_scene.set_save_state(state_to_apply)
		_restoring = false
		return
	
	match type:
		Room.Type.MONSTER, Room.Type.ELITE, Room.Type.BOSS:
			_on_combat_room_entered(room, state_to_apply)
			return
		Room.Type.TREASURE:
			var treasure_scene = TREASURE_SCENE.instantiate()
			current_room.add_child(treasure_scene)
			if treasure_scene.has_method("set_save_state"):
				treasure_scene.set_save_state(state_to_apply)
			_restoring = false
			return 
		Room.Type.SHOP:
			var shop_scene = SHOP_SCENE.instantiate()
			current_room.add_child(shop_scene)
			if shop_scene.has_method("set_save_state"):
				shop_scene.set_save_state(state_to_apply)
			_restoring = false
			return 
		Room.Type.CAMPFIRE:
			_on_campfire_room_entered(room)
			_restoring = false
			return 
		Room.Type.UNKNOWN:
			match room.unknownType:
				"combat":
					_on_combat_room_entered(room, state_to_apply)
				"shop":
					var shop_scene = SHOP_SCENE.instantiate()
					current_room.add_child(shop_scene)
					if shop_scene.has_method("set_save_state"):
						shop_scene.set_save_state(state_to_apply)
				"treasure":
					var treasure_scene = TREASURE_SCENE.instantiate()
					current_room.add_child(treasure_scene)
					if treasure_scene.has_method("set_save_state"):
						treasure_scene.set_save_state(state_to_apply)
				"incident":
					_on_incident_room_entered(room)
					# 事件房间入口已经创建了实例，直接调用 set_save_state 恢复进度
					var scene = current_room.get_child(0) if current_room.get_child_count() > 0 else null
					if scene and scene.has_method("set_save_state"):
						scene.set_save_state(state_to_apply)
				_:
					_on_incident_room_entered(room)   # 安全回退
			_restoring = false
			return
		Room.Type.ANCIENT:
			var ancient_scene = _get_ancient_scene()
			var ancient = ancient_scene.instantiate()
			ancient.current_stage = stats.current_stage
			current_room.add_child(ancient)
			ancient.restore_state(state_to_apply)
			_restoring = false
			return 
		_:
			_show_map()
			_restoring = false
			return




func _get_ancient_scene() -> PackedScene:
	if stats.current_stage == 1:
		return ANCIENT_SCENE_NEOW
	else:
		return ANCIENT_SCENE_OROBAS


func _input(event: InputEvent) -> void:
	if is_scroll_blocked and event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			get_viewport().set_input_as_handled()
