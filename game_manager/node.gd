extends Node

const CONFIG_PATH :="res://USER/config.ini"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_config()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_config()->void:
	var config:=ConfigFile.new()
	config.set_value("audio","master",MusicPlayer.get_volume(MusicPlayer.Bus.MASTER))
	config.set_value("audio","sfx",MusicPlayer.get_volume(MusicPlayer.Bus.SFX))
	config.set_value("audio","music",MusicPlayer.get_volume(MusicPlayer.Bus.MUSIC))
	config.save(CONFIG_PATH)

func load_config()->void:
	var config:=ConfigFile.new()
	config.load(CONFIG_PATH)
	
	MusicPlayer.set_volume(MusicPlayer.Bus.MASTER,config.get_value("audio","master",1.0))
	MusicPlayer.set_volume(MusicPlayer.Bus.SFX,config.get_value("audio","sfx",1.0))
	MusicPlayer.set_volume(MusicPlayer.Bus.MUSIC,config.get_value("audio","music",1.0))
	
	
	
	
	
	
	
	
