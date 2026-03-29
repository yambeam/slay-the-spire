extends Node
enum Bus{MASTER,SFX,MUSIC}

func play(audio: AudioStream, single :bool = false) -> void:
	if not audio:
		return
	
	if single:
		stop()
	
	for player: AudioStreamPlayer in get_children():
		if not player.playing:
			player.stream = audio
			player.play()
			return

func stop() -> void:
	for player: AudioStreamPlayer in get_children():
		player.stop()

func get_volume(bus_index:int)->float:
	var db=AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)
	
func set_volume(bus_index:int,v:float)->void:
	var db:=linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index,db)
