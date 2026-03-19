class_name LossHealthEffect
extends Effect

var amount := 0

func execute(_targets: Array[Node]) -> void:
	for target in _targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			target.lose_health(amount)
			SFXPlayer.play(sound)
