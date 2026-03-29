# 记得删掉class_name
# !!一定记得把脚本附加到cardname.tres上
extends Card

func apply_effects(context: Context) -> void:
	var draw_card_effect = DrawCardEffect.new()
	await draw_card_effect.execute(DrawCardContext.new(context.source, [context.source], get_numeric_value(get_numeric_entries(), 0)))
	var choose_card_effect = ChooseCardEffect.new()
	var source: Player = context.source
	choose_card_effect.execute(ChooseCardContext.new(source, source.get_hand_cards(), \
	"选择一张牌丢弃", 1, 1, func(card: Card):source.discard_card(card)))
