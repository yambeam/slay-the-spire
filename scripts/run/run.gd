class_name Run
extends Node

const COMBAT_SCENE := preload("res://scenes/rooms/combat_room/combat_room.tscn")
const COMBAT_REWARD_SCENE := preload("res://scenes/rooms/reward/reward_room.tscn")
const CAMPFIRE_SCENE := preload("res://scenes/rooms/campfire_room/campfire_room.tscn")
const MAP_SCENE := preload("res://scenes/map/map.tscn")
const SHOP_SCENE := preload("res://scenes/rooms/shop_room/shop_room.tscn")
const TREASURE_SCENE := preload("res://scenes/rooms/treasure_room/treasure_room.tscn")
const INCIDENT_SCENE := preload("res://scenes/rooms/incident_room/incident_room.tscn")

const BATTLE_REWARD_SCENE = preload("res://scenes/rooms/reward/reward_room.tscn")

@onready var current_room: Node = $CurrentRoom

@onready var combat: Button = %combat
@onready var treasure: Button = %treasure
@onready var shop: Button = %shop
@onready var campfire: Button = %campfire
@onready var rewards: Button = %rewards
@onready var incident: Button = %incident

@onready var map: Button = %map

@onready var top_bar: TopBar = %TopBar
#@onready var gold_ui: GoldUI = %TopBar/Left/TopBarGold

@onready var deck_view: DeckView = %DeckView


@export var run_startup: RunStartup

var character: CharacterStats

var stats: RunStats

func _ready() -> void:
	if not run_startup:
		return
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.picked_character.create_instance()
			_start_run()
		RunStartup.Type.CONTINUE_RUN:
			print("加载游戏")
	
func _start_run() -> void:
	stats = RunStats.new()
	
	_setup_event_connections()
	_setup_top_bar()
	# TODO: 生成地图
	
	#debug
	#await get_tree().create_timer(3).timeout
	#stats.gold += 55

func _setup_top_bar() -> void:
	deck_view.card_pile = character.deck
	
	#金币状态赋值
	top_bar.run_stats = stats   
	
	top_bar.initialize(character)
	top_bar.deck_view_requested.connect(deck_view.show_card_pile.bind("你在战斗中将会使用这里的所有卡牌。", false))


func _change_view(scene: PackedScene) -> Node:
	if current_room.get_child_count() > 0:
		current_room.get_child(0).queue_free()
		
	var new_view := scene.instantiate()
	current_room.add_child(new_view)
	
	return new_view
	
func _on_combat_won() -> void:

	var reward_scene :=_change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats =character
	#this is temporary code,it will come from real battle encounter data
	# as a dependency
	
	#reward_scene.add_gold_reward(77)
	#reward_scene.add_card_reward()
	
func _setup_event_connections() -> void:
	Events.combat_won.connect(_on_combat_won)
	Events.combat_reward_exited.connect(_change_view.bind(MAP_SCENE))
	Events.campfire_exited.connect(_change_view.bind(MAP_SCENE))
	Events.map_exited.connect(_on_map_exited)
	Events.shop_exited.connect(_change_view.bind(MAP_SCENE))
	Events.treasure_room_exited.connect(_change_view.bind(MAP_SCENE))
	Events.incident_exited.connect(_change_view.bind(MAP_SCENE))
	
	combat.pressed.connect(_change_view.bind(COMBAT_SCENE))
	rewards.pressed.connect(_change_view.bind(COMBAT_REWARD_SCENE))
	treasure.pressed.connect(_change_view.bind(TREASURE_SCENE))
	shop.pressed.connect(_change_view.bind(SHOP_SCENE))
	campfire.pressed.connect(_change_view.bind(CAMPFIRE_SCENE))
	map.pressed.connect(_change_view.bind(MAP_SCENE))
	incident.pressed.connect(_change_view.bind(INCIDENT_SCENE))
	
func _on_map_exited() -> void:
	print("map_exited")
