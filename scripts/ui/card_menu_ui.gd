class_name CardMenuUI
extends CenterContainer

signal inspect_card_requested(card: Card)

const CARD_PORTRAIT_BORDER_ATTACK_S = preload("res://images/atlases/ui_atlas.sprites/card/card_portrait_border_attack_s.tres")
const CARD_PORTRAIT_BORDER_POWER_S = preload("res://images/atlases/ui_atlas.sprites/card/card_portrait_border_power_s.tres")
const CARD_PORTRAIT_BORDER_SKILL_S = preload("res://images/atlases/ui_atlas.sprites/card/card_portrait_border_skill_s.tres")

const CARD_FRAME_ATTACK_S = preload("res://images/atlases/ui_atlas.sprites/card/card_frame_attack_s.tres")
const CARD_FRAME_POWER_S = preload("res://images/atlases/ui_atlas.sprites/card/card_frame_power_s.tres")
const CARD_FRAME_SKILL_S = preload("res://images/atlases/ui_atlas.sprites/card/card_frame_skill_s.tres")


@onready var card_portrait: TextureRect = %CardPortrait
@onready var card_frame: TextureRect = %CardFrame
@onready var portrait_border: TextureRect = %PortraitBorder
@onready var title_label: Label = %TitleLabel
@onready var energy_label: Label = %EnergyLabel
@onready var type_label: Label = %TypeLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var visuals: Control = $CardMenuUI/Visuals


var tween: Tween

@export var card: Card: set = _set_card


func _on_visuals_mouse_entered() -> void:
	if tween: 
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)


func _on_visuals_mouse_exited() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	
func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse") or event.is_action_pressed("right_mouse"):
		inspect_card_requested.emit(card)

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
			
	type_label.text = type_text
	description_label.text = card.get_default_description()
