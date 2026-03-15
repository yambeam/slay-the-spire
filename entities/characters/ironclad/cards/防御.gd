extends Card

func apply_effects(targets) -> void:
	print("apply")
	var block_effect := BlockEffect.new()
	block_effect.amount = 5
	block_effect.execute(targets)
