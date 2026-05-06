class_name RunStats
extends Resource

signal gold_changed

signal floor_changed(new_floor: int)          # 楼层变化信号

## 药水相关
signal potion_added(potion: Potion)
signal potion_removed(index: int)
signal potion_slots_changed()
## 遗物相关
signal relic_added(relic: Relic)
signal relic_removed(relic: Relic)

# 战斗阶段
signal stage_changed(new_stage: int)

const STARTING_GOLD:= 75

const BASE_CARD_REWARDS := 3;
const BASE_COMMON_WEIGHT := 6.0
const BASE_UNCOMMON_WEIGHT := 3.7
const BASE_RARE_WEIGHT := 0.3

@export var gold := STARTING_GOLD : set = set_gold

## 药水
var potions: Array[Potion] = []
@export var max_potion_slots: int = 3 : set =  _set_max_potion_slots
## 遗物
var relics: Array[Relic] = []

###当前房间
#var current_room: Room

##当前阶段
var current_stage : int = 1
var max_stage : int = 2  


@export var card_rewards := BASE_CARD_REWARDS
@export_range(0.0,10.0)var common_weight := BASE_COMMON_WEIGHT
@export_range(0.0,10.0) var uncommon_weight := BASE_UNCOMMON_WEIGHT
@export_range(0.0,10.0) var rare_weight := BASE_RARE_WEIGHT

#地图数据
@export var map_data: Array[Array] = []   # 保存整个地图数据（Room 资源数组）
@export var floors_climbed: int = 0       # 已攀爬的层数（已解锁的最高楼层索引，0-based）

@export var current_room:Room

func _init() -> void:
	init_potion_slots()

func init_potion_slots() -> void:
	var potion_copy = potions.duplicate()
	var length = len(potions)
	potions.clear()
	# 不会出现栏位减少的情况所以不考虑药水溢出问题
	for i in range(max_potion_slots):
		if i < length:
			potions.append(potion_copy[i])
		else:
			potions.append(null)

func add_potion(potion: Potion) -> bool:
	for i in range(potions.size()):
		if potions[i] == null:
			potions[i] = potion
			potion_added.emit(potion)
			return true
	return false

func add_relic(relic: Relic) -> void:
	relics.append(relic)
	relic_added.emit(relic)

func remove_relic(relic: Relic) -> void:
	relics.remove_at(relics.find(relic))
	relic_removed.emit(relic)

func remove_relic_by_name(relic_name: String) -> bool:
	for relic: Relic in relics:
		if relic.relic_name == relic_name:
			remove_relic(relic)
			return true
	return false
			
func remove_potion(index: int) -> void:
	if index >= max_potion_slots:
		return
	potions[index] = null
	potion_removed.emit(index)

func get_potions() -> Array[Potion]:
	return potions

func set_gold(new_amount:int)->void:
	gold = new_amount
	gold_changed.emit()
	
func reset_weights()->void:
	common_weight=BASE_COMMON_WEIGHT
	uncommon_weight=BASE_UNCOMMON_WEIGHT
	rare_weight =BASE_RARE_WEIGHT

func set_floor(new_floor_climbed)->void:
	floors_climbed = new_floor_climbed
	floor_changed.emit(new_floor_climbed)

func has_relic(relic_id: String) -> bool:
	#print("==========当前已拥有遗物============")
	for relic in relics:
		#print(relic.relic_name)
		if relic.id == relic_id:
			return true
	return false
	
func _set_max_potion_slots(value: int) -> void:
	# 不考虑减少栏位
	var delta :int = value - max_potion_slots
	for i in range(delta):
		potions.append(null)
	max_potion_slots = value
	potion_slots_changed.emit()

#统计当前药水数量
func potion_count()->int:
	var count:int=0
	for i in range(potions.size()):
		if potions[i] != null:
			count+=1
	return count
	
	
#统计当前遗物数量
func relic_count()->int:
	var count:int=0
	for i in range(relics.size()):
		if relics[i] != null:
			count+=1
	return count
	
	
	
	
	
	
	
	
	
	
	
	
	
	
## 推进到下一个阶段
func advance_stage() -> void:
	if current_stage >= max_stage:
		return
	current_stage += 1
	stage_changed.emit(current_stage)

## 重置地图相关数据（用于阶段切换时清除旧地图）
func reset_map() -> void:
	map_data.clear()
	floors_climbed = 0
