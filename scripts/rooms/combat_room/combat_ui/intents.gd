class_name Intents
extends HBoxContainer

# 暂时的
const IntentUi = preload("res://scenes/rooms/combat_room/combat_ui/intent_ui.tscn")


var intent: Intent

func update_intent(intent_: Intent) -> void:
	var new_uis :int = intent_.sub_intents.size() - get_child_count()
	new_uis = clampi(new_uis, 0, new_uis)
	for i in range(new_uis):
		add_child(IntentUi.instantiate())
	update_display(intent_)

func update_display(intent_: Intent) -> void:
	for i in range(intent_.sub_intents.size()):
		get_child(i).update_display(intent_.sub_intents[i])
		get_child(i).show()
		
func hide_intent() -> void:
	for child: IntentUI in get_children():
		child.hide()
