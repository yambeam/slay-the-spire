class_name CardVisuals
extends Control

const CARD_PORTRAIT_BORDER_ATTACK_S = preload("res://images/atlases/ui_atlas.sprites/card/card_portrait_border_attack_s.tres")
const CARD_PORTRAIT_BORDER_POWER_S = preload("res://images/atlases/ui_atlas.sprites/card/card_portrait_border_power_s.tres")
const CARD_PORTRAIT_BORDER_SKILL_S = preload("res://images/atlases/ui_atlas.sprites/card/card_portrait_border_skill_s.tres")

const CARD_FRAME_ATTACK_S = preload("res://images/atlases/ui_atlas.sprites/card/card_frame_attack_s.tres")
const CARD_FRAME_POWER_S = preload("res://images/atlases/ui_atlas.sprites/card/card_frame_power_s.tres")
const CARD_FRAME_SKILL_S = preload("res://images/atlases/ui_atlas.sprites/card/card_frame_skill_s.tres")

#const CARD_BANNER_ANCIENT_MAT = preload("res://materials/cards/banners/card_banner_ancient_mat.tres")
const CARD_BANNER_COMMON_MAT = preload("res://materials/cards/banners/card_banner_common_mat.tres")
const CARD_BANNER_CURSE_MAT = preload("res://materials/cards/banners/card_banner_curse_mat.tres")
#const CARD_BANNER_EVENT_MAT = preload("res://materials/cards/banners/card_banner_event_mat.tres")
#const CARD_BANNER_QUEST_MAT = preload("res://materials/cards/banners/card_banner_quest_mat.tres")
const CARD_BANNER_RARE_MAT = preload("res://materials/cards/banners/card_banner_rare_mat.tres")
const CARD_BANNER_STATUS_MAT = preload("res://materials/cards/banners/card_banner_status_mat.tres")
const CARD_BANNER_UNCOMMON_MAT = preload("res://materials/cards/banners/card_banner_uncommon_mat.tres")

#const CARD_FRAME_BLUE_MAT = preload("res://materials/cards/frames/card_frame_blue_mat.tres")
const CARD_FRAME_COLORLESS_MAT = preload("res://materials/cards/frames/card_frame_colorless_mat.tres")
const CARD_FRAME_CURSE_MAT = preload("res://materials/cards/frames/card_frame_curse_mat.tres")
const CARD_FRAME_GREEN_MAT = preload("res://materials/cards/frames/card_frame_green_mat.tres")
#const CARD_FRAME_ORANGE_MAT = preload("res://materials/cards/frames/card_frame_orange_mat.tres")
#const CARD_FRAME_PINK_MAT = preload("res://materials/cards/frames/card_frame_pink_mat.tres")
#const CARD_FRAME_QUEST_MAT = preload("res://materials/cards/frames/card_frame_quest_mat.tres")
const CARD_FRAME_RED_MAT = preload("res://materials/cards/frames/card_frame_red_mat.tres")

@export var card: Card: set = _set_card

@onready var card_portrait: TextureRect = %CardPortrait
@onready var card_frame: TextureRect = %CardFrame
@onready var portrait_border: TextureRect = %PortraitBorder
@onready var title_label: Label = %TitleLabel
@onready var energy_label: Label = %EnergyLabel
@onready var type_label: Label = %TypeLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var title_banner: TextureRect = $TitleBanner
@onready var type_plaque: NinePatchRect = %TypePlaque

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	card_portrait.texture = card.portrait
	title_label.text = card.id
	energy_label.text = str(card.cost)
	description_label.text = card.description
	var type_text: String
	# TODO: 诅咒，状态
	match card.type:
		card.Type.ATTACK:
			type_text = "攻击"
			card_frame.texture = CARD_FRAME_ATTACK_S
			portrait_border.texture = CARD_PORTRAIT_BORDER_ATTACK_S
		card.Type.SKILL:
			type_text = "技能"
			card_frame.texture = CARD_FRAME_SKILL_S
			portrait_border.texture = CARD_PORTRAIT_BORDER_SKILL_S
		card.Type.POWER:
			type_text = "能力"
			card_frame.texture = CARD_FRAME_POWER_S
			portrait_border.texture = CARD_PORTRAIT_BORDER_POWER_S
		_:
			type_text = "出错"
	match card.card_color:
		card.COLOR.RED:
			card_frame.material = CARD_FRAME_RED_MAT
		card.COLOR.GREEN:
			card_frame.material = CARD_FRAME_GREEN_MAT
		card.COLOR.COLORLESS:
			card_frame.material = CARD_FRAME_COLORLESS_MAT
		card.COLOR.CURSE:
			card_frame.material = CARD_FRAME_CURSE_MAT
		_:
			printerr("card_visuals")
			return
	match card.rarity:
		card.Rarity.COMMON:
			title_banner.material = CARD_BANNER_COMMON_MAT
			type_plaque.material = CARD_BANNER_COMMON_MAT
			portrait_border.material = CARD_BANNER_COMMON_MAT
		card.Rarity.UNCOMMON:
			title_banner.material = CARD_BANNER_UNCOMMON_MAT
			type_plaque.material = CARD_BANNER_UNCOMMON_MAT
			portrait_border.material = CARD_BANNER_UNCOMMON_MAT
		card.Rarity.RARE:
			title_banner.material = CARD_BANNER_RARE_MAT
			type_plaque.material = CARD_BANNER_RARE_MAT
			portrait_border.material = CARD_BANNER_RARE_MAT
		card.Rarity.STATUS:
			title_banner.material = CARD_BANNER_STATUS_MAT
			type_plaque.material = CARD_BANNER_STATUS_MAT
			portrait_border.material = CARD_BANNER_STATUS_MAT
		card.Rarity.CURSED:
			title_banner.material = CARD_BANNER_CURSE_MAT
			type_plaque.material = CARD_BANNER_CURSE_MAT
			portrait_border.material = CARD_BANNER_CURSE_MAT
		_:
			printerr("card_visuals")
			return			
	type_label.text = type_text
	description_label.text = card.get_default_description()

func set_description(text: String) -> void:
	description_label.text = text
