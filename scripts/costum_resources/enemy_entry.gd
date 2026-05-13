class_name EnemyEntry
extends Resource

@export var enemy_stats: EnemyStats
@export var position: Vector2
@export var index: int = 0
@export var initial_buff: Dictionary


#
#func get_initial_buffs() -> Dictionary:
	#var ret: Dictionary = {}
	#for key in initial_buff.keys():
		#var buff_resource: BuffResource = BuffLibrary.get_buff_resource_by_name(key)
		#var buff: Buff = buff_resource.buff_script.new()
		#ret[buff] = initial_buff[key]
	#return ret
