class_name SaveGame
extends Resource

const SAVE_PATH:="user://savegame.tres"

@export var run_stats:RunStats
@export var char_stats:CharacterStats

@export var randomSeed:int
@export var randomState:int

#@export var current_deck:CardPile
#@export var current_health:int

@export var last_room:Room
@export var was_on_map:bool

## 药水
#@export var potions: Array[Potion] = []
## 遗物
#@export var relics: Array[Relic] = []

func save_data()->void:
	var err:=ResourceSaver.save(self,SAVE_PATH)
	assert(err==OK,"could not save the game!")

static func load_data()->SaveGame:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as SaveGame
	return null
	
static func delete_data()->void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
