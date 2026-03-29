# 记得删掉class_name
# !!一定记得把脚本附加到cardname.tres上
extends Card

func apply_effects(context: Context) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.sound = sound
	damage_effect.execute(DamageContext.new(context.source, context.targets, get_numeric_value(get_numeric_entries(), 0)))
	
	var source: Player = context.source
	var choose_card_effect := ChooseCardEffect.new()
	var target_cards: Array[Card] = []
	for card: Card in source.get_hand_cards():
		if not card.ethereal:
			target_cards.append(card)
	target_cards.erase(self)
	choose_card_effect.execute(ChooseCardContext.new(source, target_cards, "选择一张手牌施加虚无", 1, 1, func(card: Card): card.ethereal = true))
