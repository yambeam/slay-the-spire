extends Relic

@export var initialized: bool = false

func initialize_relic(owner: RelicUI) -> void:
	if initialized:
		return
	initialized = true
	count = 3
	owner.update_count()
	
func activate_relic(owner: RelicUI) -> void:
	if count > 0:
		count -= 1
		super.activate_relic(owner)
		owner.update_count()
