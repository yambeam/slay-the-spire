extends Enchantment

func get_modifiers() -> Array[Modifier]:
	return []

func on_play(player: Player, _targets: Array[Node]) -> void:
	player.gain_energy(GainEnergyContext.new(stacks))

func get_description() -> String:
	return description.format({"stacks": stacks})
