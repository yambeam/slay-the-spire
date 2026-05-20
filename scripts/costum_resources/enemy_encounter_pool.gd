class_name EnemyEncounterPool
extends Resource

@export var pool: Array[EnemyEncounter]
var total_weights_by_type := [0.0, 0.0, 0.0, 0.0]

func _get_all_encounters_by_type(type: EnemyEncounter.Type) -> Array[EnemyEncounter]:
	return pool.filter(func(encounter: EnemyEncounter): return encounter.type == type)

func _setup_weight_for_type(type: EnemyEncounter.Type) -> void:
	if type == EnemyEncounter.Type.INCIDENT:
		# 事件的战斗不是随机的
		return
	var encounters := _get_all_encounters_by_type(type)
	var idx := (type as int)
	total_weights_by_type[idx] = 0.0
	
	for encounter: EnemyEncounter in encounters:
		total_weights_by_type[idx] += encounter.weight
		encounter.accumulated_weight = total_weights_by_type[idx]

func get_random_encounter_by_type(type: EnemyEncounter.Type) -> EnemyEncounter:
	if type == EnemyEncounter.Type.INCIDENT:
		return null
	
	var idx := (type as int)
	var roll := RandomSetting.instance.randf_range(0.0, total_weights_by_type[idx])
	var encounters := _get_all_encounters_by_type(type)
	for encounter: EnemyEncounter in encounters:
		if encounter.accumulated_weight > roll:
			return encounter
	printerr("enemy_encounter_pool: get_random_encounter_by_type")
	return null

func get_encounter_by_name(encounter_name: String, type: EnemyEncounter.Type = EnemyEncounter.Type.INCIDENT) -> EnemyEncounter:
	var encounters = _get_all_encounters_by_type(type)
	for encounter: EnemyEncounter in encounters:
		if encounter.encounter_name == encounter_name:
			return encounter
	return null

func setup() -> void:
	_setup_weight_for_type(EnemyEncounter.Type.WEAK)
	_setup_weight_for_type(EnemyEncounter.Type.STRONG)
	_setup_weight_for_type(EnemyEncounter.Type.ELITE)
	_setup_weight_for_type(EnemyEncounter.Type.BOSS)
