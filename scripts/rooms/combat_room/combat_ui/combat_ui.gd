class_name CombatUI
extends CanvasLayer

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var hand_manager: HandManager = $HandManager
@onready var energy_ui: EnergyUI = $EnergyUI
@onready var end_turn: Button = $EndTurn
@onready var end_turn_label: Label = $EndTurn/EndTurnLabel
@onready var end_turn_glow: TextureRect = $EndTurn/EndTurnGlow
@onready var inspect_pile_view: DeckView = %InspectPileView
@onready var draw_pile_button: CardPileButton = %DrawPileButton
@onready var discard_pile_button: CardPileButton = %DiscardPileButton
@onready var exhaust_pile_button: CardPileButton = $ExhaustPileButton
@onready var sfx_layer: CanvasLayer = %SFXLayer

var draw_pile_position: Vector2
var discard_pile_position: Vector2

func _ready() -> void:
	Events.player_hand_drawn.connect(_on_player_hand_drawn)
	end_turn.pressed.connect(_on_end_turn_button_pressed)
	
	draw_pile_position = draw_pile_button.global_position + draw_pile_button.size / 2
	discard_pile_position = discard_pile_button.global_position + discard_pile_button.size / 2
	#discard_pile_button.pressed.connect(discard_pile_view.show_card_pile.bind("当抽牌堆耗尽时，这里的牌会被洗入抽牌堆。", false))
	#exhaust_pile_button.pressed.connect(exhaust_pile_view.show_card_pile.bind("这里是在本场战斗中被消耗的牌。", false))
	
	
func initialize_card_pile_view() -> void:
	draw_pile_button.card_pile = char_stats.draw_pile
	discard_pile_button.card_pile = char_stats.discard_pile
	exhaust_pile_button.card_pile = char_stats.exhaust_pile
	draw_pile_button.pressed.connect(inspect_pile_view.show_card_pile.bind(char_stats.draw_pile.cards, "每回合开始时会从这里抽牌。", true))
	discard_pile_button.pressed.connect(inspect_pile_view.show_card_pile.bind(char_stats.discard_pile.cards, "当抽牌堆耗尽时，这里的牌会被洗入抽牌堆。", false))
	exhaust_pile_button.pressed.connect(inspect_pile_view.show_card_pile.bind(char_stats.exhaust_pile.cards, "这里是在本场战斗中被消耗的牌。", false))
	Events.card_discarded.connect(func(card_ui: CardUI): animate_fly_to_deck(card_ui, true))

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	energy_ui.char_stats = value
	
func _on_player_hand_drawn() -> void:
	end_turn.disabled = false
	end_turn_glow.visible = true

func _on_end_turn_button_pressed() -> void:
	end_turn.disabled = true
	end_turn_glow.visible = false
	Events.player_turn_ended.emit()

func animate_fly_to_deck(card: Control, to_discard_pile: bool = true) -> void:
	var card_fly_vfx :CardFlyVFX = null
	if to_discard_pile:
		card_fly_vfx = CardFlyVFX.new(card, discard_pile_position, char_stats.color)
	else:
		card_fly_vfx = CardFlyVFX.new(card, draw_pile_position, char_stats.color)
	if card.get_parent():
		card.reparent(sfx_layer)
	sfx_layer.call_deferred("add_child", card_fly_vfx)

func animate_shuffle_deck(count: int, character_color: CharacterStats.COLOR) -> void:
	count = 20 if count > 20 else count
	for i in range(count):
		var card_shuffle_vfx := CardShuffleVFX.new(discard_pile_position, draw_pile_position, character_color)
		sfx_layer.call_deferred("add_child", card_shuffle_vfx)
