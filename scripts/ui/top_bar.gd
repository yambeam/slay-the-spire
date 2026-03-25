class_name TopBar
extends Control

signal deck_view_requested

@onready var card_pile_button: CardPileButton = $Right/Deck/CardPileButton
@onready var avatar: TextureRect = $Left/AvatarContainer/AvatarBg/Avatar

func initialize(stats: CharacterStats) -> void:
	card_pile_button.card_pile = stats.deck
	avatar.texture = stats.character_icon
	card_pile_button.pressed.connect(deck_view_requested.emit)
