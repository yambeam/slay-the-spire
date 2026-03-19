class_name ApplyBuffEffect
extends Effect

func execute(context: Context) -> void:
	print(context.targets)
	BuffHandler.add_buff(context)
	SFXPlayer.play(sound)
