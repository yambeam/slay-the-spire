extends EnemyAI

func get_skin(spine_sprite: SpineManager) -> SpineSkin:
	var data := spine_sprite.get_skeleton().get_data()
	return data.find_skin("rock")

func execute_intent(source: Creature, target: Creature, current_intent: Intent) -> void:
	super.execute_intent(source, target, current_intent)
