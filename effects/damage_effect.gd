class_name DamageEffect
extends Effect

func execute(context: Context) -> void:
	for target: Node in context.targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			SFXPlayer.play(sound)
			target.take_damage(context)
		
