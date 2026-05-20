class_name EnemyStats
extends Stats


@export var ai: EnemyAI
@export var enemy_name: String
@export var hightest_max_health: int
@export var lowest_max_health: int

func create_instance() -> Stats:
	var instance: Stats = self.duplicate()
	instance.max_health = RandomSetting.instance.randi_range(lowest_max_health, hightest_max_health)
	instance.health = instance.max_health
	instance.block = 0
	return instance
