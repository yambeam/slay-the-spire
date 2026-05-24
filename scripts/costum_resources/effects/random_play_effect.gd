class_name RandomPlayEffect
extends Effect

enum CardSource{
	SPECIFIED, # 导出的卡牌
	RANDOM, # where中的随机牌
	TOP_OF_DECK, 
	RANDOM_ATTACK, # where中的随机攻击牌
}

enum Where{
	DRAW_PILE,
	DISCARD_PILE,
	HAND,
	NONE
}

@export var source: CardSource
@export var where: Where
@export var card_to_play: Card
@export var random_play_count_provider: NumericProvider
# TODO:包装成card_modifier

func apply(source_: Node, _targets: Array[Node], card_context: Dictionary, previous_result: Variant = null) -> Variant:
	if source_ is Player:
		var value := random_play_count_provider.get_value(previous_result, card_context)
		var cards_to_play :Array[Card] = []
		var candidates: Array[Card] = []
		
		match where:
			Where.DRAW_PILE:
				candidates = source_.get_draw_pile().duplicate()
			Where.DISCARD_PILE:
				candidates = source_.get_discard_pile().duplicate()
			Where.HAND:
				candidates = source_.get_hand_cards().duplicate()
		
		match source:
			CardSource.SPECIFIED:
				for i in range(value):
					cards_to_play.append(card_to_play.duplicate())
			CardSource.TOP_OF_DECK:
				cards_to_play = candidates.slice(0, value)
			CardSource.RANDOM:
				RandomSetting.array_shuffle(candidates)
				cards_to_play = candidates.slice(0, value)
			CardSource.RANDOM_ATTACK:
				candidates = candidates.filter(func(card: Card): return card.type == Card.Type.ATTACK)
				RandomSetting.array_shuffle(candidates)
				cards_to_play = candidates.slice(0, value)
		
		if where == Where.HAND:
			source_.agent.disable_hand(true)
		for card: Card in cards_to_play:
			match where:
				Where.DRAW_PILE:
					source_.remove_card_in_draw_pile(card)
				Where.DISCARD_PILE:
					source_.remove_card_in_discard_pile(card)
				Where.HAND:
					source_.remove_card_in_hand(card)
			_random_play(source_, card)
			await source_.get_tree().create_timer(0.3).timeout
		if where == Where.HAND:
			source_.agent.disable_hand(false)
	return null

func _random_play(player: Node, card: Card) -> void:
	var enemies: Array[Node] = player.get_tree().get_nodes_in_group("ui_enemies")
	card.first_play_free = true

	match card.get_target():
		card.Target.SELF:
			card.play(player, [player])
		card.Target.SINGLE_ENEMY:
			card.play(player, [RandomSetting.array_pick_random(enemies)])
			#card.play(player, [enemies[randi() % len(enemies)]])
		card.Target.ALL_ENEMIES:
			card.play(player, enemies)
		card.Target.EVERYONE:
			card.play(player, enemies)
	if where == Where.HAND:
		print("remove_hand")
		(player as Player).agent.hand_manager.remove_card(card)
