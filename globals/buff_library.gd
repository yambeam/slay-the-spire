extends Node

var buff_data = {
	"易伤": {
		"name": "易伤",
		"description": "受到的攻击伤害增加50%",
		"icon": preload("res://images/powers/vulnerable_power.png")
	},
	"虚弱": {
		"name": "虚弱",
		"description": "造成的攻击伤害减少25%",
		"icon": preload("res://images/powers/weak_power.png")
	},
	"中毒":{
		"name": "中毒",
		"description": "回合开始时失去{stacks}点生命，然后减少一层",
		"icon": preload("res://images/powers/poison_power.png")
	},
	"脆弱":{
		"name": "脆弱",
		"description": "从卡牌中获得的格挡降低25%",
		"icon": preload("res://images/powers/frail_power.png")
	},
	"力量":{
		"name": "力量",
		"description": "造成的攻击伤害提高{stacks}点",
		"icon": preload("res://images/powers/strength_power.png")
	},
	"敏捷":{
		"name": "敏捷",
		"description": "从卡牌获得的格挡提高{stacks}点",
		"icon": preload("res://images/powers/dexterity_power.png")
	}
}

var buff_scene = {
	"易伤": VulnerableDebuff,
	"虚弱": WeaknessDebuff,
	"中毒": PoisonDebuff,
	"脆弱": FragileDebuff,
	"力量": StrengthBuff,
	"敏捷": DexterityBuff
}

var keyword_info = {
	"易伤": {
		"name": "易伤",
		"description": "受到的攻击伤害增加50%",
	},
	"虚弱": {
		"name": "虚弱",
		"description": "造成的攻击伤害减少25%",
	},
	"中毒":{
		"name": "中毒",
		"description": "回合开始时失去等同于层数的生命，然后减少一层",
	},
	"消耗":{
		"name": "消耗",
		"description": "被消耗的牌不会进入弃牌堆而是进入消耗堆"
	},
	"脆弱":{
		"name": "脆弱",
		"description": "从卡牌中获得的格挡降低25%",
	},
	"力量":{
		"name": "力量",
		"description": "造成的攻击伤害提高"
	},
	"敏捷":{
		"name": "敏捷",
		"description": "从卡牌获得的格挡提高"
	},
	"格挡":{
		"name": "格挡]",
		"description": "在回合开始前抵挡伤害"
	}
}

func get_keyword_description(key: String) -> String:
	return keyword_info.get(key, {}).get("description", "")
# 一般来说key和name是相同的，这里不考虑多语言

func get_keyword_name(key: String) -> String:
	return keyword_info.get(key, {}).get("name", "")

func get_description(buff_name: String, stacks: int) -> String:
	var buff_info = buff_data.get(buff_name, null)
	if buff_info:
		return buff_info["description"].format({"stacks":stacks})
	return ""
