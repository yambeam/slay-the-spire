# meta-name: Effect逻辑
# meta-description: effect逻辑脚本的模板

class_name MyEffect
extends Effect

var amount := 0

func execute(context: Context) -> void:
	for target: Node in context.targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			target.stats.block += context.amount
			SFXPlayer.play(sound)
