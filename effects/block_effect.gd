class_name BlockEffect
extends Effect

func execute(context: Context) -> void:
	for target: Node in context.targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			target.gain_block(context)
			SFXPlayer.play(sound)
