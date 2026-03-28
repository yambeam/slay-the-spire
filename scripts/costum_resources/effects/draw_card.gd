class_name DrawCardEffect
extends Effect

func execute(context: Context) -> void:
	await context.source.draw_cards(context)
	
