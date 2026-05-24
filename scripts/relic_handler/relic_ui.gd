class_name RelicUI
extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var count: Label = $Count

@export var relic: Relic

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_relic(new_relic: Relic) -> void:
	if not is_node_ready():
		await ready
	
	relic = new_relic
	texture_rect.texture = new_relic.icon
	update_count()

func update_count() -> void:
	count.text = str(relic.temp_count) if relic.temp_count > 0 else ""

func flash() -> void:
	animation_player.play("flash")

func _on_mouse_entered() -> void:
	Events.tooltip_show_request.emit(self, show_keyword_tooltip)

func _on_mouse_exited() -> void:
	Events.tooltip_hide_request.emit()

func show_keyword_tooltip() -> void:
	KeywordTooltip.add_keyword(relic.relic_name, relic.description)
	KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 1.4, size.y)
	KeywordTooltip.show()
