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
	}
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
