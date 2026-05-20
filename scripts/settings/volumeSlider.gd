class_name VolumeSlider
extends HSlider

@export var bus:StringName="Master"
@onready var bus_index:=AudioServer.get_bus_index(bus)
signal volume_changed


func VolumeValue()->float:
	return MusicPlayer.get_volume(bus_index)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value=MusicPlayer.get_volume(bus_index)
	
	value_changed.connect(func(v:float):
		MusicPlayer.set_volume(bus_index,v)
		GameManager.save_config()
		volume_changed.emit()
	)
	
