## 房间奖励的上下文
class_name RewardContext
extends RefCounted

# 额外奖励
var extra_card_count := 0
var extra_potion_count := 0
var extra_relic_count := 0
var extra_gold: Array[int] = []
# 卡牌升级
var upgrade_attack := false
var upgrade_skill := false
var upgrade_power := false
var upgrade_all := false
# 限定卡牌类型
var all_rare := false
var all_uncommon := false
var all_common := false

var all_colorless := false
