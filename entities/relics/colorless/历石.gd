extends Relic

var used := false

func initialize_relic(owner: RelicUI) -> void:
	Events.combat_won.connect(
		func(_context: RewardContext):
			temp_count = 0
			used = false
			owner.update_count()
	)
	
func activate_relic(owner: RelicUI) -> void:
	if used:
		return
	if temp_count < 7:
		temp_count += 1
	else:
		super.activate_relic(owner)
		used = true
		temp_count = 0
	owner.update_count()
	
