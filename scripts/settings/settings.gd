class_name Settings
extends Control

signal settings_exited


@onready var global_volume: Label = $"VBoxContainer/audiosettings/VBoxContainer/VBoxContainer/HBoxContainer/Global volume"
@onready var music_volume: Label = $"VBoxContainer/audiosettings/VBoxContainer/VBoxContainer2/HBoxContainer2/music volume"
@onready var sfx_volume: Label = $"VBoxContainer/audiosettings/VBoxContainer/VBoxContainer3/HBoxContainer3/SFX volume"

@onready var globalslider: VolumeSlider = $VBoxContainer/audiosettings/VBoxContainer/VBoxContainer/HBoxContainer/Globalslider
@onready var music_slider: VolumeSlider = $VBoxContainer/audiosettings/VBoxContainer/VBoxContainer2/HBoxContainer2/MusicSlider
@onready var sfx_slider: VolumeSlider = $VBoxContainer/audiosettings/VBoxContainer/VBoxContainer3/HBoxContainer3/SFXSlider

func _ready() -> void:
	var values=globalslider.VolumeValue()
	values*=100
	global_volume.text=str(int(values))
	global_volume.text+="%"
	
	values=music_slider.VolumeValue()
	values*=100
	music_volume.text=str(int(values))
	music_volume.text+="%"
	
	values=sfx_slider.VolumeValue()
	values*=100
	sfx_volume.text=str(int(values))
	sfx_volume.text+="%"
	
	globalslider.volume_changed.connect(func():
		var value=globalslider.VolumeValue()
		value*=100
		global_volume.text=str(int(value))
		global_volume.text+="%"
		
	)
	music_slider.volume_changed.connect(func():
		var value=music_slider.VolumeValue()
		value*=100
		music_volume.text=str(int(value))
		music_volume.text+="%"
		
	)
	sfx_slider.volume_changed.connect(func():
		var value=sfx_slider.VolumeValue()
		value*=100
		sfx_volume.text=str(int(value))
		sfx_volume.text+="%"
		
	)
	

func _on_button_pressed() -> void:
	settings_exited.emit()

	
