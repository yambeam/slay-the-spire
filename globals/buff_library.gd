extends Node

var buff_data = {
	#"易伤": {
		#"name": "易伤",
		#"description": "受到的攻击伤害增加50%",
		#"icon": preload("res://images/powers/vulnerable_power.png")
	#},
	#"虚弱": {
		#"name": "虚弱",
		#"description": "造成的攻击伤害减少25%",
		#"icon": preload("res://images/powers/weak_power.png")
	#},
	#"中毒":{
		#"name": "中毒",
		#"description": "回合开始时失去{stacks}点生命，然后减少一层",
		#"icon": preload("res://images/powers/poison_power.png")
	#},
	#"脆弱":{
		#"name": "脆弱",
		#"description": "从卡牌中获得的格挡降低25%",
		#"icon": preload("res://images/powers/frail_power.png")
	#},
	#"力量":{
		#"name": "力量",
		#"description": "造成的攻击伤害提高{stacks}点",
		#"icon": preload("res://images/powers/strength_power.png")
	#},
	#"敏捷":{
		#"name": "敏捷",
		#"description": "从卡牌获得的格挡提高{stacks}点",
		#"icon": preload("res://images/powers/dexterity_power.png")
	#},
	#"恶魔形态":{
		#"name": "恶魔形态",
		#"description": "在每回合开始时，获得{stacks}层力量",
		#"icon": preload("res://images/powers/demon_form_power.png")
	#},
	#"壁垒":{
		#"name": "壁垒",
		#"description": "回合开始时格挡不会自动消失",
		#"icon": preload("res://images/powers/barricade_power.png")
	#},
	#"无法抽牌":{
		#"name": "无法抽牌",
		#"description": "本回合无法抽牌",
		#"icon": preload("res://images/powers/no_draw_power.png")
	#},
	#"荆棘":{
		#"name": "荆棘",
		#"description": "受到攻击伤害时，反弹{stacks}点伤害",
		#"icon": preload("res://images/powers/thorns_power.png")
	#},
	#"滑溜":{
		#"name": "滑溜",
		#"description": "下次失去生命值时，只会失去1点生命",
		#"icon": preload("res://images/powers/slippery_power.png")
	#},
	#"地狱狂徒":{
		#"name": "地狱狂徒",
		#"description": "每当你抽到名字中有“打击”的牌时，对一名随机敌人打出这张牌。",
		#"icon": preload("res://images/powers/hellraiser_power.png")
	#},
	#"肌肉药水":{
		#"name": "肌肉药水",
		#"description": "回合结束时，失去{stacks}点力量",
		#"icon": preload("res://images/powers/flex_potion_power.png")
	#}
}

var buff_scene = {
	#"易伤": VulnerableDebuff,
	#"虚弱": WeaknessDebuff,
	#"中毒": PoisonDebuff,
	#"脆弱": FragileDebuff,
	#"力量": StrengthBuff,
	#"敏捷": DexterityBuff,
	#"恶魔形态": DemonFormBuff,
	#"壁垒": BarricadeBuff,
	#"无法抽牌": NoDrawDebuff,
	#"荆棘": ThornsBuff,
	#"滑溜": SlipperyBuff,
	#"地狱狂徒": HellRaiserBuff,
	#"肌肉药水": FlexPotionBuff
}

var buff_resources: Dictionary = {}

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
	"恶魔形态":{
		"name": "恶魔形态",
		"description": "在回合开始时获得等同于层数的力量"
	},
	"格挡":{
		"name": "格挡",
		"description": "在回合开始前抵挡伤害"
	},
	"消耗":{
		"name": "消耗",
		"description": "被消耗的牌不会进入弃牌堆而是进入消耗堆"
	},
	"虚无":{
		"name": "虚无",
		"description": "虚无牌在回合结束时如果仍在手牌中，自动被消耗"
	},
	"壁垒":{
		"name": "壁垒",
		"description": "回合开始时格挡不会自动消失",
	},
	"无法抽牌":{
		"name": "无法抽牌",
		"description": "本回合无法抽牌",
	},
	"荆棘":{
		"name": "荆棘",
		"description": "受到攻击伤害时，反弹等同于荆棘层数点伤害",
	},
	"覆甲":{
		"name": "覆甲",
		"description": "回合结束时获得等同于层数的格挡，然后减少一层"
	}
}

func _ready() -> void:
	load_all_buff_resource("res://entities/buff_resources/")

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

func load_all_buff_resource(dir_path: String):
	var paths = FileHelper.get_all_resources_in_directory(dir_path)
	for path in paths:
		var resource: BuffResource = ResourceLoader.load(path)
		if resource == null:
			printerr("无法加载{path}".format(path))
			continue
		else:
			buff_resources[resource.buff_name] = resource

func get_buff_resource_by_name(buff_name: String) -> BuffResource:
	return buff_resources.get(buff_name, null)
	
