extends ColorRect

@onready var flash_timer: Timer = $FlashTimer

func _ready() -> void:
	Events.player_hit.connect(_on_player_hit)
	flash_timer.timeout.connect(_on_timer_timeout)

func _on_player_hit() -> void:
	# TODO:根据受到伤害/剩余血量修改透明度
	color.a = 0.05
	flash_timer.start()

func _on_timer_timeout() -> void:
	color.a = 0.0
