class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25

@export var hand_manager: HandManager
@export var relics: RelicHandler
@onready var player: Player = $"../Player"
@onready var combat_ui: CombatUI = %CombatUI

var char_stats: CharacterStats
# 抽一张牌的效果，这是为了将回合开始时的抽牌也压入结算栈中
var draw_card_effect_with_iteration: IterationEffect = IterationEffect.new()
var draw_card_context := {
	"player": null,
	"targets": []
}

func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	draw_card_effect_with_iteration.effects = [DrawCardEffect.new()]
	draw_card_context["player"] = player

func start_battle(char_stats_: CharacterStats) -> void:
	char_stats = char_stats_
	char_stats.draw_pile = char_stats_.deck.duplicate(true)
	char_stats.draw_pile.shuffle()
	char_stats.discard_pile = CardPile.new()
	char_stats.exhaust_pile = CardPile.new()
	relics.relics_activated.connect(_on_relics_activated)
	start_turn()
	
func start_turn() -> void:
	player.start_turn()
	Events.player_turn_started.emit()
	relics.activate_relics_by_trigger_type(Relic.TriggerType.START_OF_TURN)

func end_turn() -> void:
	# 等待其他效果压入调用栈，比如“惊逃”buff
	# 很丑陋，但是我没办法了
	await get_tree().process_frame
	if player.combat_resolver.is_resolving:
		await player.combat_resolver.resolve_finished
	player.end_turn()
	relics.activate_relics_by_trigger_type(Relic.TriggerType.END_OF_TURN)

func draw_card() -> Card:
	reshuffle_deck_from_discard_pile()
	if char_stats.draw_pile.is_empty():
		# 抽牌堆与弃牌堆都没牌了
		return null
	# 抽牌堆满了不抽牌
	if hand_manager.get_child_count() >= 10:
		return null
	var card = char_stats.draw_pile.draw_card()
	return card

func add_card_to_hand(card: Card) -> void:
	if card:
		hand_manager.add_card(card)
		hand_manager.set_cards()

		
#func draw_cards(amount: int) -> void:
	#var tween := create_tween()
	#for i in range(amount):
		#tween.tween_callback(func():
			##player.draw_card(DrawCardContext.new(player, null, 1))
			#player.combat_resolver.execute(ResolutionEntry.new(null, [draw_card_effect], draw_card_context, func(): return))
		#)
		#tween.tween_interval(HAND_DRAW_INTERVAL)
	#
	#tween.finished.connect(
		#func(): Events.player_hand_drawn.emit()
	#)

func draw_cards() -> void:
	draw_card_effect_with_iteration.count_provider = NumericProvider.new(char_stats.cards_per_turn)
	player.combat_resolver.execute(ResolutionEntry.new(null, [draw_card_effect_with_iteration], draw_card_context, func(): Events.player_hand_drawn.emit()))

func disable_hand(flag: bool = true) -> void:
	for child:CardUI in hand_manager.get_children():
		child.disabled = flag

func discard_card(card: Card) -> void:
	for child: CardUI in hand_manager.get_children():
		if card == child.card:
			hand_manager.discard_card(child)
			char_stats.discard_pile.add_card(card)
			return
	printerr("player_handler")


func exhaust_hand_card(card: Card) -> void:
	for child: CardUI in hand_manager.get_children():
		if card == child.card:
			hand_manager.exhaust_card(child)
			char_stats.exhaust_pile.add_card(card)
			return
	printerr("player_handler")


func discard_cards() -> void:
	if hand_manager.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return
	
	for child: CardUI in hand_manager.get_children():
		if child.card.ethereal:
			char_stats.exhaust_pile.add_card(child.card)
			#TODO:卡片消耗特效
		else:
			char_stats.discard_pile.add_card(child.card)
			
	hand_manager.discard_hand()
	Events.player_hand_discarded.emit()
		

func hide_hand() -> void:
	hand_manager.hide()
	
func show_hand() -> void:
	hand_manager.set_cards(true)
	hand_manager.show()
	
	
func get_hand() -> Array[Card]:
	var ret: Array[Card] = []
	for child: CardUI in hand_manager.get_children():
		ret.append(child.card)
	return ret
	
func reshuffle_deck_from_discard_pile() -> void:
	if not char_stats.draw_pile.is_empty():
		return
	
	combat_ui.animate_shuffle_deck(len(char_stats.get_discard_pile()), char_stats.color)
	while not char_stats.discard_pile.is_empty():
		char_stats.draw_pile.add_card(char_stats.discard_pile.draw_card())	
	
	char_stats.draw_pile.shuffle()

func put_card_in_draw_pile(card: Card, top: bool = false) -> void:
	if top:
		char_stats.draw_pile.add_card_to_top(card)
	else:
		char_stats.draw_pile.add_card(card)
		char_stats.draw_pile.shuffle()

func put_card_in_hand(card: Card) -> void:
	if hand_manager.add_card(card):
		hand_manager.set_cards()
		return
	else:
		card.first_play_free = false
		char_stats.discard_pile.add_card(card)

func put_card_in_discard_pile(card: Card) -> void:
	char_stats.discard_pile.add_card(card)

func remove_card_in_discard_pile(card: Card) -> void:
	char_stats.discard_pile.remove_card(card)

func remove_card_in_draw_pile(card: Card) -> void:
	char_stats.draw_pile.remove_card(card)

# 之后估计会改
func remove_card_in_hand(card: Card) -> void:
	for child: CardUI in hand_manager.get_children():
		if child.card == card:
			hand_manager.discard_card(child)
			return

func update_hand() -> void:
	hand_manager.update_hand()

func _on_card_played(card: Card, _card_context: Dictionary) -> void:
	if card.type == card.Type.POWER:
		# 能力牌打出后不进入任何牌堆
		return
	if card.exhaust:
		char_stats.exhaust_pile.add_card(card)
		Events.card_exhausted.emit(card)
	else:
		var discarded_card := CardInspectUI.new()
		discarded_card.card = card
		discarded_card.global_position = get_viewport().size / 2
		discarded_card.global_position += discarded_card.size / 2
		combat_ui.animate_fly_to_deck(discarded_card, true)
		put_card_in_discard_pile(card)
		
func _on_relics_activated(type: Relic.TriggerType):
	match type:
		Relic.TriggerType.START_OF_TURN:
			draw_cards()
		Relic.TriggerType.END_OF_TURN:
			discard_cards()
