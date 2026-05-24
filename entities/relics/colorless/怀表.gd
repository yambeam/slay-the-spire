extends Relic

var available := false

func initialize_relic(owner: RelicUI) -> void:
	Events.card_played.connect(_on_card_played.bind(owner))
	Events.combat_won.connect(_on_combat_won.bind(owner))

func activate_relic(owner: RelicUI) -> void:
	if not available:
		available = true
		return
	if temp_count <= 3:
		super.activate_relic(owner)
	temp_count = 0
	owner.update_count()

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.card_played.is_connected(_on_card_played):
		Events.card_played.disconnect(_on_card_played)
	if Events.combat_won.is_connected(_on_combat_won):
		Events.combat_won.disconnect(_on_combat_won)
	
func _on_card_played(_card: Card, _card_context: Dictionary, owner: RelicUI) -> void:
	temp_count += 1
	owner.update_count()

func _on_combat_won(_context, owner: RelicUI) -> void:
	available = false
	temp_count = 0
	owner.update_count()
