extends Relic

var available := false

func initialize_relic(owner: RelicUI) -> void:
	Events.card_played.connect(_on_card_played.bind(owner))
	Events.combat_won.connect(
		func(_context: RewardContext):
			available = false
			temp_count = 0
			owner.update_count()
	)

func activate_relic(owner: RelicUI) -> void:
	if not available:
		available = true
		return
	if temp_count <= 3:
		super.activate_relic(owner)
	temp_count = 0
	owner.update_count()
	
func _on_card_played(_card: Card, _card_context: Dictionary, owner: RelicUI) -> void:
	temp_count += 1
	owner.update_count()
