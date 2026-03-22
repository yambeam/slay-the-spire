class_name BattleUI
extends CanvasLayer

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var hand_manager: HandManager = $HandManager
@onready var energy_ui: EnergyUI = $EnergyUI
@onready var end_turn: Button = $EndTurn
@onready var end_turn_label: Label = $EndTurn/EndTurnLabel
@onready var end_turn_glow: TextureRect = $EndTurn/EndTurnGlow

func _ready() -> void:
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	end_turn.pressed.connect(_on_end_turn_button_pressed)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	energy_ui.char_stats = value
	
func _on_player_hand_drawn() -> void:
	end_turn.disabled = false
	end_turn_glow.visible = true

func _on_end_turn_button_pressed() -> void:
	end_turn.disabled = true
	end_turn_glow.visible = false
	Events.player_turn_ended.emit()
