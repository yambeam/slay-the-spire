extends Node


@warning_ignore_start("unused_signal")
## 卡牌相关
signal card_aim_started(card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_previewed(card_ui: CardUI, to_preview: bool)
signal card_played(card: Card)
## 玩家相关
# 玩家回合开始抽牌后
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_ended
signal player_hited(text: String)
signal player_died
signal player_hit
## 敌人相关
signal enemy_action_completed(enemy: Enemy)
signal enemy_turn_ended
signal enemy_died
@warning_ignore_restore("unused_signal")
