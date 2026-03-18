class_name Intents
extends HBoxContainer

@onready var intent_ui_1: IntentUI = $intentUI1
@onready var intent_ui_2: IntentUI = $intentUI2

# 暂时的
const INTENT_ATTACK_1 = preload("res://images/packed/intents/attack/intent_attack_1.png")
const INTENT_BUFF_00 = preload("res://images/packed/intents/buff/intent_buff_00.png")
const INTENT_DEFEND_00 = preload("res://images/packed/intents/defend/intent_defend_00.png")

var intent: Intent

func update_intent(intent_: Intent) -> void:
	intent_ui_1.show()
	## 如果有两个意图，让第二个intentUI可见
	intent_ui_2.visible = intent_.type > intent_.Type.SEPERATION
	match intent_.type:
		Intent.Type.ATTACK:
			intent_ui_1.icon.texture = INTENT_ATTACK_1
			intent_ui_1.value.text = intent_.values[0]
		Intent.Type.DEFFEND:
			intent_ui_1.icon.texture = INTENT_DEFEND_00
			intent_ui_1.value.text = intent_.values[0]
		Intent.Type.ATTACK_DEFFEND:
			intent_ui_1.icon.texture = INTENT_ATTACK_1
			intent_ui_2.icon.texture = INTENT_DEFEND_00
			intent_ui_1.value.text = intent_.values[0]
			intent_ui_2.value.text = intent_.values[1]
		_:
			printerr("intents出错")
			pass

func hide_intent() -> void:
	intent_ui_1.hide()
	intent_ui_2.hide()
