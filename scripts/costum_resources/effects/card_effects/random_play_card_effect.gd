class_name RandomPlayCardEffect
extends CardEffect


func execute(source_: Node, card_context: Dictionary = {}, _previous_result: Variant = null) -> Variant:
	var player = source_.get_tree().get_first_node_in_group("ui_player")
	_random_play(player, card_context["target_card"])
	return null

func _random_play(player: Node, card: Card) -> void:
	var enemies: Array[Node] = player.get_tree().get_nodes_in_group("ui_enemies")
	match card.get_target():
		card.Target.SELF:
			card.play(player, [player], true)
		card.Target.SINGLE_ENEMY:
			card.play(player, [enemies[RandomSetting.instance.randi() % len(enemies)]], true)
		card.Target.ALL_ENEMIES:
			card.play(player, enemies, true)
		card.Target.EVERYONE:
			card.play(player, enemies, true)
