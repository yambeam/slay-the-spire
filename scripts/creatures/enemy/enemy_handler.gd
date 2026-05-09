class_name EnemyHandler
extends Node2D

const EnemyScene := preload("res://scenes/creatures/enemy/enemy.tscn")

func _ready() -> void:
	Events.enemy_action_completed.connect(_on_enemy_action_completed)

func reset_enemy_intents() -> void:
	for child: Enemy in get_children():
		# 如果child被queue_free就不会再更新意图
		if is_instance_valid(child):
			child.current_intent = null
			child.update_intent()

func setup_enemies(encounter: EnemyEncounter) -> void:
	if not encounter:
		return
	for enemy: Enemy in get_children():
		enemy.queue_free()
	for enemy_entry : EnemyEntry in encounter.enemy_entries:
		var new_enemy: Enemy = EnemyScene.instantiate()
		new_enemy.position = enemy_entry.position
		new_enemy.stats = enemy_entry.enemy_stats.create_instance()
		
		
		add_child(new_enemy)
		if !new_enemy.is_node_ready():
			await new_enemy.ready
			
		var initial_buff: Dictionary = enemy_entry.initial_buff
		for key in initial_buff:
			if key == "格挡":
				new_enemy.gain_block(GainBlockContext.new(new_enemy, new_enemy, initial_buff[key], [], true))
			else:
				new_enemy.add_buff(ApplyBuffContext.new(new_enemy, new_enemy, initial_buff[key], key))
		#new_enemy.ready.connect(
			#func():
				#var buffs := enemy_entry.get_initial_buffs()
				#for key in buffs.keys():
					#new_enemy.add_buff(ApplyBuffContext.new(new_enemy, new_enemy, buffs[key], key))
				#)
		

func start_turn() -> void:
	if get_child_count() == 0:
		return
	
	var first_enemy: Enemy = get_child(0)
	first_enemy.do_turn()

func _on_enemy_action_completed(enemy: Enemy) -> void:
	# 最后一个敌人行动结束
	if enemy.get_index() == get_child_count() - 1:
		Events.enemy_turn_ended.emit()
		return
	(get_child(enemy.get_index() + 1) as Enemy).do_turn()
