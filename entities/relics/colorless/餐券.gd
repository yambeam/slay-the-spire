extends Relic

var relic_ui: RelicUI

func initialize_relic(owner: RelicUI) -> void:
	Events.shop_entered.connect(_on_shop_entered)
	relic_ui = owner

func deactivate_relic(_owner: RelicUI) -> void:
	if Events.shop_entered.is_connected(_on_shop_entered):
		Events.shop_entered.disconnect(_on_shop_entered)

func _on_shop_entered(_room: Room, _run_stats: RunStats, char_stats: CharacterStats) -> void:
	char_stats.health += 15
	relic_ui.flash()
