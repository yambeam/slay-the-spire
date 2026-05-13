class_name PauseMenu
extends CanvasLayer

signal save_and_quit
@onready var continue_button: TextureButton = $VBoxContainer/continueButton
@onready var setting_button: TextureButton = $VBoxContainer/settingButton
@onready var save_button: TextureButton = $VBoxContainer/saveButton
@onready var back_button: ComfirmButton = $BackButton

@onready var settings: Settings = $settings

func _ready() -> void:
	settings.settings_exited.connect(handleSettings)

func handleSettings()->void:
	settings.hide()
	get_tree().paused=false	
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			settings.hide()
			_unpause()
		else:
			_pause()
		get_viewport().set_input_as_handled()
		
func _pause()->void:
	show()
	get_tree().paused=true

func _unpause()->void:
	hide()
	get_tree().paused=false

func _on_continue_button_pressed() -> void:
	_unpause()
	


func _on_setting_button_pressed() -> void:
	settings.show()
	pass # Replace with function body.


func _on_save_button_pressed() -> void:
	get_tree().paused=false
	save_and_quit.emit()
	


func _on_back_button_pressed() -> void:
	_unpause()
