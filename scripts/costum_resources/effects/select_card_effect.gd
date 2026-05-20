class_name SelectCardEffect
extends Effect

enum Where{
	HAND, # 手牌
	DRAW_PILE, # 抽牌堆
	DISCARD_PILE # 弃牌堆
}

enum SelectionMode{
	MANUAL,
	ALL,
	RANDOM, # 随机卡牌，取决于max_select
	FIRST, # 第一张（牌库顶
	ALL_NOT_UPGRADED, #所有未升级的卡牌
}

@export var where: Where
@export var selectionMode: SelectionMode
@export var min_select: int = 0
@export var max_select: int = 0
@export var filter_condition: CardCondition
@export var deck_view_selection_mode: DeckView.SelectionMode = DeckView.SelectionMode.SELECT
## 消耗，升级等
@export var callback_hint: String

			#if where == Where.HAND:
				#card_count = await source.select_hand(ChooseCardContext.new(source, filter_cards(cards), get_hint_text(), min_select, max_select, hook, get_selection_mode()))
			#else:
				#card_count = await source.select_deck(ChooseCardContext.new(source, filter_cards(cards), get_hint_text(), min_select, max_select, hook, get_selection_mode()))
			#return card_count

func execute(source: Node, _card_context: Dictionary = {}, _previous_result: Variant = null) -> Variant:
	source = (source as Player)
	if source:
		var cards: Array[Card] = _get_cards(source)
		var selected_cards: Array[Card] = []
		if filter_condition:
			cards = cards.filter(func(c: Card): return filter_condition.is_met(c))
		
		if len(cards) > 0:
			match selectionMode:
				SelectionMode.MANUAL:
					if where == Where.HAND:
						selected_cards = await source.select_hand(SelectCardContext.new(source, cards, _get_hint_text(), min_select, max_select, deck_view_selection_mode))
					else:
						selected_cards = await source.select_deck(SelectCardContext.new(source, cards, _get_hint_text(), min_select, max_select, deck_view_selection_mode))
				SelectionMode.ALL:
					selected_cards = cards
				SelectionMode.RANDOM:
					if max_select == 1:
						selected_cards = [cards[randi() % len(cards)]]
					else:
						selected_cards = cards.duplicate()
						selected_cards.shuffle()
						selected_cards = selected_cards.slice(0, max_select)

				SelectionMode.FIRST:
					selected_cards = [cards[0]]
				SelectionMode.ALL_NOT_UPGRADED:
					selected_cards = cards.filter(func(c: Card): return c.upgraded == false)
				_:
					selected_cards = []
		return {"selected_cards": selected_cards, "source_pile": where}
	return {"selected_cards": [], "source_pile": where} 
	
func _get_cards(player: Player) -> Array[Card]:
	match where:
		Where.HAND:
			return player.get_hand_cards()
		Where.DRAW_PILE:
			return player.get_draw_pile()
		Where.DISCARD_PILE:
			return player.get_discard_pile()
	return []

func _get_hint_text() -> String:
	var front: String
	if max_select == min_select:
		front = "选择{card}张牌".format({"card": min_select})
	else:
		if min_select == 0:
			if max_select == 10:
				front = "选择任意张牌"
			else:
				front = "选择至多{card}张牌".format({"card": max_select})
		else:
			front = "选择至少{min_select}张牌，至多{max_select}张牌".format({"min_select": min_select, "max_select": max_select})
	return front + callback_hint
