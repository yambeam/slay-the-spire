class_name BGMProxy
extends Node

@export var last_music_type: MusicType
@export var act1_bgm: Dictionary[String, AudioStream] = {
	"BOSS": null,
	"WEAK_ENEMY": null,
	"STRONG_ENEMY": null,
	"ELITE": null,
	"SHOP": null,
	"BACKGROUND": null,
	"TREASURE_ROOM": null
}

@export var act2_bgm: Dictionary[String, AudioStream] = {
	"BOSS": null,
	"WEAK_ENEMY": null,
	"STRONG_ENEMY": null,
	"ELITE": null,
	"SHOP": null,
	"BACKGROUND": null,
	"TREASURE_ROOM": null
}
	
enum MusicType
{
	BACKGROUND,
	WEAK_ENEMY,
	STRONG_ENEMY,
	ELITE,
	SHOP,
	BOSS,
	TREASURE_ROOM,
}


func update_music(room: Room, act: int) -> void:
	match room.type:
		Room.Type.BOSS:
			if room.enemy_encounter.custom_music:
				MusicPlayer.play(room.enemy_encounter.custom_music, true)
			else:
				MusicPlayer.play(get_bgm_dict(act)["BOSS"], true)
			last_music_type = MusicType.BOSS
		Room.Type.SHOP:
			if last_music_type != MusicType.SHOP:
				MusicPlayer.play(get_bgm_dict(act)["SHOP"], true)
			last_music_type = MusicType.SHOP
		Room.Type.ELITE:
			if last_music_type != MusicType.ELITE:
				MusicPlayer.play(get_bgm_dict(act)["ELITE"], true)
			last_music_type = MusicType.ELITE
		Room.Type.MONSTER:
			if room.enemy_encounter.type == EnemyEncounter.Type.WEAK:
				if last_music_type != MusicType.WEAK_ENEMY:
					MusicPlayer.play(get_bgm_dict(act)["WEAK_ENEMY"], true)
				last_music_type = MusicType.WEAK_ENEMY
			else:
				if last_music_type != MusicType.STRONG_ENEMY:
					MusicPlayer.play(get_bgm_dict(act)["STRONG_ENEMY"], true)
				last_music_type = MusicType.STRONG_ENEMY
		Room.Type.TREASURE:
			if last_music_type != MusicType.TREASURE_ROOM:
				MusicPlayer.play(get_bgm_dict(act)["TREASURE_ROOM"], true)
			last_music_type = MusicType.TREASURE_ROOM
		
func get_bgm_dict(act: int):
	if act == 1:
		return act1_bgm
	return act2_bgm
