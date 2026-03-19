class_name Stats
extends Resource

signal stats_changed

@export var max_health := 1
@export var animation: SpineSkeletonDataResource

var health: int : set = _set_health
var block: int : set = _set_block

func _set_health(value: int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()

func _set_block(value: int) -> void:
	block = clampi(value, 0, 999)
	stats_changed.emit()

func take_damage(damage: int) -> bool:
	if damage <= 0:
		return false
	var actual_damage: int
	#实际伤害
	actual_damage = clampi(damage - block, 0, damage)
	#计算护甲
	block = clampi(block - damage, 0, block)
	health -= actual_damage
	return actual_damage > 0
	
func heal(amount: int) -> void:
	health += amount

#资源只加载一次，所以需要复制以附加到不同的实体上
func create_instance() -> Stats:
	var instance: Stats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	return instance
