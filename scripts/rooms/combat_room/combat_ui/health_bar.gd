class_name HealthBar
extends Control

@onready var hp_bar_container: Control = $HPBarContainer
@onready var block_outline: NinePatchRect = %BlockOutline
@onready var mask: NinePatchRect = $HPBarContainer/HPForegroundContainer/Mask
@onready var hp_label: Label = %HpLabel
@onready var block_container: Control = $BlockContainer
@onready var block_label: Label = %BlockLabel

@export var mask_length: int

func update_stats(stats: Stats) -> void:
	block_outline.visible = stats.block > 0
	block_container.visible = stats.block > 0
	block_label.text = str(stats.block)
	hp_label.text = "%s/%s" % [stats.health, stats.max_health]
	# 根据生命值修改mask长度
	mask.size.x = mask_length * (float(stats.health) / stats.max_health)
