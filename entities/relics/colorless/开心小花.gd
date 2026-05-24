extends Relic

func activate_relic(owner: RelicUI) -> void:
	if count < 2:
		count += 1
	else:
		count = 0
		super.activate_relic(owner)
	owner.update_count()
	
