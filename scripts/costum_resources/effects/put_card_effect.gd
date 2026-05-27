class_name PutCardEffect
extends Effect

enum CardSource{
	SPECIFIED, # 导出的卡牌
	COPY_OF_PLAYING_CARD, # 只用卡牌的effect中允许使用
	RANDOM_FROM_POOL,
	PREVOUSE_RESULT
}

enum Where{
	DRAW_PILE,
	DISCARD_PILE,
	HAND
}

@export var source: CardSource
@export var where: Where
@export var card_to_put: Card
@export var put_card_count_provider: NumericProvider
@export var card_filter: CardFilter
# TODO:包装成card_modifier
@export var upgraded: bool
@export var first_play_free: bool

func apply(source_: Node, targets: Array[Node], card_context: Dictionary, previous_result: Variant = null) -> Variant:
	var value := put_card_count_provider.get_value(previous_result, card_context)
	var cards_to_add :Array[Card] = []
	match source:
		CardSource.SPECIFIED:
			for i in range(value):
				cards_to_add.append(card_to_put.duplicate())
		CardSource.COPY_OF_PLAYING_CARD:
			var card : Card = card_context.get("card")
			if card:
				for i in range(value):
					cards_to_add.append(card.duplicate())
		CardSource.RANDOM_FROM_POOL:
			var cards :Array[Card] = ItemPool.get_random_discoverable_cards(card_filter.get_color(source_)\
			, card_filter.type, card_filter.rarity, value)
			for i in range(len(cards)):
				cards[i] = cards[i].duplicate()
			cards_to_add = cards
		CardSource.PREVOUSE_RESULT:
			cards_to_add = [previous_result as Card]
	
	for target: Creature in targets:
		if target is Player:
			match where:
				Where.DRAW_PILE:
					for card: Card in cards_to_add:
						target.put_card_in_draw_pile(_apply_modifiers(card))
				Where.DISCARD_PILE:
					for card: Card in cards_to_add:
						target.put_card_in_discard_pile(_apply_modifiers(card))
				Where.HAND:
					for card: Card in cards_to_add:
						target.put_card_in_hand(_apply_modifiers(card))	
	return null

func _apply_modifiers(card: Card) -> Card:
	if first_play_free:
		card.first_play_free = true
	if upgraded:
		card.upgrade()
	return card
