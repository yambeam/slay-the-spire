extends HSlider

@export var bus:StringName="Master"
@onready var bus_index:=AudioServer.get_bus_index(bus)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value=MusicPlayer.get_volume(bus_index)
	value_changed.connect(func(v:float):
		MusicPlayer.set_volume(bus_index,v)
		Game.save_config()
	)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
