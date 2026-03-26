class_name DrawCardEffect
extends Effect

func execute(context: Context) -> void:
	var tween := context.source.create_tween()
	for i in range(context.amount):
		tween.tween_callback(context.source.draw_card)
		tween.tween_interval(0.2)
	await tween.finished
