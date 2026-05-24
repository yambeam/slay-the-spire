class_name SaveGame
extends Resource

const SAVE_PATH := "user://savegame.tres"

enum State { ON_MAP, IN_ROOM }

#人物数据
@export var run_stats: RunStats
@export var char_stats: CharacterStats
@export var current_deck: CardPile
@export var current_health: int
@export var potions: Array[Potion] = []
@export var relics: Array[Relic] = []


#房间数据/地图
@export var state: State
@export var room_type: Room.Type
@export var last_room: Room           # 仅用于地图高亮等
@export var room_state: Dictionary = {}  

@export var map_types: Array = []        
@export var selected_rooms: Array = []   

@export var last_room_unknown_type: String = ""

#进出房间相机位置保存
@export var map_camera_y: float = 0.0           # 当前地图相机 Y
@export var map_old_camera_y: float = 0.0       # 进入房间前的相机 Y

#判断是否是奖励房间
@export var is_battle_reward: bool = false

func save_data() -> void:
	var err := ResourceSaver.save(self, SAVE_PATH)
	assert(err == OK, "Could not save the game!")

static func load_data() -> SaveGame:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as SaveGame
	return null

static func delete_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
