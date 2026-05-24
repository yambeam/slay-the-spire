extends Relic

func activate_relic(owner: RelicUI) -> void:
	if temp_count < 2:
		temp_count += 1
	else:
		super.activate_relic(owner)
		temp_count = 0
	owner.update_count()
