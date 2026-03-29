class_name ChooseCardEffect
extends Effect
# 感觉这个effect不是很必要
func execute(context: Context) -> void:
	await context.source.select(context)
