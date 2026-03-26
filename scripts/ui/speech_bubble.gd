class_name SpeechBubble
extends Control

@onready var speech_label: RichTextLabel = $SpeechLabel
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(func(): visible = false)

func set_text(text: String, time: float = 2.5) -> void:
	speech_label.text = text
	visible = true
	timer.start(time)
