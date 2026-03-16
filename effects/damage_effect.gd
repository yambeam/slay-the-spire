class_name DamageEffect
extends Effect

var amount := 0

func execute(_targets: Array[Node]) -> void:
	for target in _targets:
		if not target:
			continue
		target.take_damage(amount)
