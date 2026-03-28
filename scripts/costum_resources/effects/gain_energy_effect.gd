class_name GainEnergyEffect
extends Effect

func execute(context: Context) -> void:
	if not context.targets:
		return
	for target: Creature in context.targets:
		target.gain_energy(context)
