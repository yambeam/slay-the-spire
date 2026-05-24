extends Relic

func initialize_relic(owner: RelicUI) -> void:
	Events.after_potion_used.connect(_after_potion_used.bind(owner))

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.after_potion_used.is_connected(_after_potion_used):
		Events.after_potion_used.disconnect(_after_potion_used)

func _after_potion_used(_potion_ui: PotionUI, owner: RelicUI) -> void:
	activate_relic(owner)
