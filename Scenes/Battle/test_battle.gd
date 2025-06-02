extends Node2D

#region onready

@onready var battle_options: Panel = $BattleOptions
@onready var battle_button: Button = $BattleOptions/battleButton
@onready var move_1_button: Button = $MoveOptions/move1Button
@onready var move_2_button: Button = $MoveOptions/move2Button
@onready var move_3_button: Button = $MoveOptions/move3Button
@onready var move_4_button: Button = $MoveOptions/move4Button
@onready var move_options: Panel = $MoveOptions
@onready var set_moves_button: Button = $SetMovesButton
@onready var add_kangaskhan: Button = $addKangaskhan
@onready var add_kangaskhan_as_enemy: Button = $addKangaskhanAsEnemy
@onready var enemy_statblock: Panel = $EnemyStatblock
@onready var enemy_name: Label = $EnemyStatblock/EnemyName
@onready var current_enemy_hp: Label = $EnemyStatblock/CurrentEnemyHP
@onready var current_enemy_status: Label = $EnemyStatblock/CurrentEnemyStatus
@onready var own_statblock: Panel = $OwnStatblock
@onready var pokemon_name: Label = $OwnStatblock/PokemonName
@onready var current_pokemon_hp: Label = $OwnStatblock/CurrentPokemonHP
@onready var current_pokemon_status: Label = $OwnStatblock/CurrentPokemonStatus
@onready var flee_button: Button = $BattleOptions/fleeButton

#endregion

func _on_battle_button_pressed() -> void:
	battle_options.visible = false
	move_options.visible = true
	# Set move button text to currentMoves using group-based approach
	var player_pokemon = null
	var pokemons = get_tree().get_nodes_in_group("player_pokemon")
	if pokemons.size() > 0:
		player_pokemon = pokemons[0]
	if player_pokemon:
		if player_pokemon.currentMoves.size() > 0:
			var move_name = player_pokemon.currentMoves[0]
			var move_pp = player_pokemon.Move1PP
			move_1_button.text = "%s (PP: %s)" % [move_name, move_pp]
		else:
			move_1_button.text = "-"
		if player_pokemon.currentMoves.size() > 1:
			var move_name = player_pokemon.currentMoves[1]
			var move_pp = player_pokemon.Move2PP
			move_2_button.text = "%s (PP: %s)" % [move_name, move_pp]
		else:
			move_2_button.text = "-"
		if player_pokemon.currentMoves.size() > 2:
			var move_name = player_pokemon.currentMoves[2]
			var move_pp = player_pokemon.Move3PP
			move_3_button.text = "%s (PP: %s)" % [move_name, move_pp]
		else:
			move_3_button.text = "-"
		if player_pokemon.currentMoves.size() > 3:
			var move_name = player_pokemon.currentMoves[3]
			var move_pp = player_pokemon.Move4PP
			move_4_button.text = "%s (PP: %s)" % [move_name, move_pp]
		else:
			move_4_button.text = "-"
	else:
		move_1_button.text = "-"
		move_2_button.text = "-"
		move_3_button.text = "-"
		move_4_button.text = "-"
	# Output enemy HP in the console
	var enemies = get_tree().get_nodes_in_group("enemy_pokemon")
	for enemy in enemies:
		if "currentHP" in enemy:
			print("Enemy HP:", enemy.currentHP)


func execute_move(attacker, defender, move_instance, move_name, damage_calculator):
	print("[DEBUG] execute_move: attacker=%s, defender=%s, move_name=%s, moveCat=%s" % [attacker.Name if attacker else "None", defender.Name if defender else "None", move_name, move_instance.moveCat if move_instance else "None"])
	# Print if this is an enemy move
	if attacker and attacker.has_method("is_in_group") and attacker.is_in_group("enemy_pokemon"):
		print("[DEBUG] ENEMY MOVE: %s used %s on %s" % [attacker.Name, move_name, defender.Name if defender else "None"])
	# Handle Status moves (like Tail Whip) separately
	if move_instance.moveCat == "Status":
		# Try to call a debuff or effect function if it exists
		if move_instance.has_method("DebuffEnenmyDefensex1"):
			# Only call if defender is a valid target, not attacker, and is in the enemy_pokemon group if attacker is player, or player_pokemon group if attacker is enemy
			if attacker.is_in_group("player_pokemon") and defender != attacker and defender.has_method("set_stat") and defender.has_method("get_stat") and defender.is_in_group("enemy_pokemon"):
				move_instance.DebuffEnenmyDefensex1(defender)
				print("%s used %s!" % [attacker.Name, move_name])
			elif attacker.is_in_group("enemy_pokemon") and defender != attacker and defender.has_method("set_stat") and defender.has_method("get_stat") and defender.is_in_group("player_pokemon"):
				move_instance.DebuffEnenmyDefensex1(defender)
				print("%s used %s!" % [attacker.Name, move_name])
			else:
				print("[Tail Whip] No valid enemy target for debuff. Defender: ", defender)
		else:
			print("Status move %s has no effect function implemented." % move_name)
		return
	var damage = 0
	if move_instance.moveCat == "Physical":
		damage = damage_calculator.calculate_move_damage(attacker, defender, move_instance)
	elif move_instance.moveCat == "Special":
		damage = damage_calculator.calculate_special_move_damage(attacker, defender, move_instance)
	else:
		print("Move category not supported for damage calculation.")
	if "currentHP" in defender:
		defender.currentHP = max(0, defender.currentHP - damage)
		print("%s used %s!" % [attacker.Name, move_name])
		print("%s HP after attack: %d" % [defender.Name, defender.currentHP])
		# Print both player and enemy HP after each attack
		if attacker.has_method("is_in_group") and attacker.is_in_group("player_pokemon"):
			print("Player HP:", attacker.currentHP)
			current_pokemon_hp.text = str(attacker.currentHP)
			current_enemy_hp.text = str(defender.currentHP)
		elif defender.has_method("is_in_group") and defender.is_in_group("player_pokemon"):
			print("Player HP:", defender.currentHP)
			current_pokemon_hp.text = str(defender.currentHP)
			current_enemy_hp.text = str(attacker.currentHP)
		if attacker.has_method("is_in_group") and attacker.is_in_group("enemy_pokemon"):
			print("Enemy HP:", attacker.currentHP)
			current_enemy_hp.text = str(attacker.currentHP)
			current_pokemon_hp.text = str(defender.currentHP)
		elif defender.has_method("is_in_group") and defender.is_in_group("enemy_pokemon"):
			current_enemy_hp.text = str(defender.currentHP)
			current_pokemon_hp.text = str(attacker.currentHP)
		# Apply Struggle recoil if move is Struggle
		if move_name == "Struggle" and move_instance.has_method("RecoilDamage"):
			move_instance.RecoilDamage(attacker)
			current_pokemon_hp.text = str(attacker.currentHP)
			current_enemy_hp.text = str(defender.currentHP)
	else:
		print("No valid defender HP.")


func _get_battle_pokemon() -> Dictionary: # Helper: get player and enemy pokemon
	var pokemons = get_tree().get_nodes_in_group("player_pokemon")
	var player_pokemon = null
	if pokemons.size() > 0:
		player_pokemon = pokemons[0]
	var enemies = get_tree().get_nodes_in_group("enemy_pokemon")
	var enemy_pokemon = null
	if enemies.size() > 0:
		enemy_pokemon = enemies[0]
	return {"player": player_pokemon, "enemy": enemy_pokemon}



func _handle_move_button(move_index: int) -> void: # Helper: handle move logic for a given move index
	var mons = _get_battle_pokemon()
	var player_pokemon = mons["player"]
	var enemy_pokemon = mons["enemy"]
	if not player_pokemon:
		return
	player_pokemon.checkIfStruggle()
	var player_is_struggling = player_pokemon.isStruggling
	if enemy_pokemon:
		enemy_pokemon.checkIfStruggle()
	var enemy_is_struggling = enemy_pokemon and enemy_pokemon.isStruggling
	var player_move_name = null
	var player_move_instance = null
	if player_is_struggling:
		player_move_name = "Struggle"
		var struggle_path = "res://Scripts/Moves/struggle.gd"
		if ResourceLoader.exists(struggle_path):
			var move_resource = load(struggle_path)
			player_move_instance = move_resource.new()
	else:
		if player_pokemon.currentMoves.size() > move_index and player_pokemon["Move%dPP" % (move_index+1)] > 0:
			player_move_name = player_pokemon.currentMoves[move_index]
			var player_move_path = "res://Scripts/Moves/%s.gd" % player_move_name
			if ResourceLoader.exists(player_move_path):
				var move_resource = load(player_move_path)
				player_move_instance = move_resource.new()
				player_pokemon["Move%dPP" % (move_index+1)] = max(0, player_pokemon["Move%dPP" % (move_index+1)] - 1)
	var enemy_move_name = null
	var enemy_move_instance = null
	if enemy_pokemon:
		if enemy_is_struggling:
			enemy_move_name = "Struggle"
			var struggle_path = "res://Scripts/Moves/struggle.gd"
			if ResourceLoader.exists(struggle_path):
				var move_resource = load(struggle_path)
				enemy_move_instance = move_resource.new()
		else:
			var all_pp_zero = true
			var move_pps = [enemy_pokemon.Move1PP, enemy_pokemon.Move2PP, enemy_pokemon.Move3PP, enemy_pokemon.Move4PP]
			for pp in move_pps:
				if pp > 0:
					all_pp_zero = false
					break
			if all_pp_zero:
				enemy_move_name = "Struggle"
				var struggle_path = "res://Scripts/Moves/struggle.gd"
				if ResourceLoader.exists(struggle_path):
					var move_resource = load(struggle_path)
					enemy_move_instance = move_resource.new()
			else:
				var available_moves = []
				if enemy_pokemon.Move1PP > 0 and enemy_pokemon.currentMoves.size() > 0:
					available_moves.append({"name": enemy_pokemon.currentMoves[0], "slot": 1})
				if enemy_pokemon.Move2PP > 0 and enemy_pokemon.currentMoves.size() > 1:
					available_moves.append({"name": enemy_pokemon.currentMoves[1], "slot": 2})
				if enemy_pokemon.Move3PP > 0 and enemy_pokemon.currentMoves.size() > 2:
					available_moves.append({"name": enemy_pokemon.currentMoves[2], "slot": 3})
				if enemy_pokemon.Move4PP > 0 and enemy_pokemon.currentMoves.size() > 3:
					available_moves.append({"name": enemy_pokemon.currentMoves[3], "slot": 4})
				if available_moves.size() > 0:
					var idx = randi() % available_moves.size()
					enemy_move_name = available_moves[idx]["name"]
					var enemy_move_path = "res://Scripts/Moves/%s.gd" % enemy_move_name
					if ResourceLoader.exists(enemy_move_path):
						var move_resource = load(enemy_move_path)
						enemy_move_instance = move_resource.new()
						match available_moves[idx]["slot"]:
							1:
								enemy_pokemon.Move1PP = max(0, enemy_pokemon.Move1PP - 1)
							2:
								enemy_pokemon.Move2PP = max(0, enemy_pokemon.Move2PP - 1)
							3:
								enemy_pokemon.Move3PP = max(0, enemy_pokemon.Move3PP - 1)
							4:
								enemy_pokemon.Move4PP = max(0, enemy_pokemon.Move4PP - 1)
	var damage_calculator = get_node("/root").get("damage_calculator") if has_node("/root/damage_calculator") else preload("res://Managers/damage_calculator.gd").new()
	var player_initiative = player_pokemon.currentInitiative if player_pokemon else 0
	var enemy_initiative = enemy_pokemon.currentInitiative if enemy_pokemon else 0
	print("[DEBUG] Player move:", player_move_name, "Enemy move:", enemy_move_name)
	if player_move_instance and enemy_move_instance:
		if player_initiative > enemy_initiative:
			execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
			execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
		elif enemy_initiative > player_initiative:
			execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
			execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
		else:
			execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
			execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
	elif player_move_instance:
		execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
	elif enemy_move_instance:
		execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
	else:
		print("No valid moves to execute.")
	if player_pokemon and player_pokemon.currentMoves.size() > 0:
		move_1_button.text = "%s (PP: %s)" % [player_pokemon.currentMoves[0], player_pokemon.Move1PP]
	if player_pokemon and player_pokemon.currentMoves.size() > 1:
		move_2_button.text = "%s (PP: %s)" % [player_pokemon.currentMoves[1], player_pokemon.Move2PP]
	if player_pokemon and player_pokemon.currentMoves.size() > 2:
		move_3_button.text = "%s (PP: %s)" % [player_pokemon.currentMoves[2], player_pokemon.Move3PP]
	if player_pokemon and player_pokemon.currentMoves.size() > 3:
		move_4_button.text = "%s (PP: %s)" % [player_pokemon.currentMoves[3], player_pokemon.Move4PP]

func _on_move_1_button_pressed() -> void:
	_handle_move_button(0)

func _on_move_2_button_pressed() -> void:
	_handle_move_button(1)

func _on_move_3_button_pressed() -> void:
	_handle_move_button(2)

func _on_move_4_button_pressed() -> void:
	_handle_move_button(3)

func _on_flee_button_pressed() -> void:
	# When fleeing, show the map and player, hide the battle layer
	var parent = get_parent()
	if parent:
		# Try to find the map and player as children or siblings of the battle scene
		var map_node : Node = null
		var player_node : Node = null
		var battle_layer_node : Node = null

		# Look for map and player as siblings (common in Godot scene trees)
		if parent.has_node("../TestMap"):
			map_node = parent.get_node("../TestMap")
		elif parent.has_node("../test_map"):
			map_node = parent.get_node("../test_map")
		elif parent.has_node("../ground"):
			map_node = parent.get_node("../ground")
		elif parent.has_node("../Ground"):
			map_node = parent.get_node("../Ground")

		if parent.has_node("../Player"):
			player_node = parent.get_node("../Player")
		elif parent.has_node("../player"):
			player_node = parent.get_node("../player")

		# Try to find the battle layer as a sibling or as a child
		if parent.has_node("../BattleLayer"):
			battle_layer_node = parent.get_node("../BattleLayer")
			map_node = parent.get_node("..")
			StateManager.inBattle = false

		# Set visibility accordingly
		if map_node:
			map_node.visible = true
		if player_node:
			player_node.visible = true
		if battle_layer_node:
			battle_layer_node.visible = false

#region debugbutons

func _on_set_moves_button_pressed() -> void:
	var player_pokemon = null
	var pokemons = get_tree().get_nodes_in_group("player_pokemon")
	if pokemons.size() > 0:
		player_pokemon = pokemons[0]
	if player_pokemon:
		player_pokemon.SetPotentiellMoves()
		player_pokemon.SetMoves()
		player_pokemon.setMove1PP()
		player_pokemon.setMove2PP()
		player_pokemon.setMove3PP()
		player_pokemon.setMove4PP()

	# Also set moves and PP for enemy pokemon
	#var enemies = get_tree().get_nodes_in_group("enemy_pokemon")
	#for enemy_pokemon in enemies:
		#if enemy_pokemon.has_method("SetPotentiellMoves"):
			#enemy_pokemon.SetPotentiellMoves()
		#if enemy_pokemon.has_method("SetMoves"):
			#enemy_pokemon.SetMoves()
		#if enemy_pokemon.has_method("setMove1PP"):
			#enemy_pokemon.setMove1PP()
		#if enemy_pokemon.has_method("setMove2PP"):
			#enemy_pokemon.setMove2PP()
		#if enemy_pokemon.has_method("setMove3PP"):
			#enemy_pokemon.setMove3PP()
		#if enemy_pokemon.has_method("setMove4PP"):
			#enemy_pokemon.setMove4PP()

func _on_add_kangaskhan_pressed() -> void:
	# Instance Kangaskhan scene and add to the scene tree for debug/party
	var kangaskhan_scene = load("res://Scenes/Units/Kangaskhan.tscn")
	var kangaskhan_instance = kangaskhan_scene.instantiate()
	# Add to player group for logic separation
	kangaskhan_instance.add_to_group("player_pokemon")
	# Optionally set position or parent as needed
	# Add to Units node if it exists
	var units_node = get_node_or_null("../Units")
	if units_node:
		units_node.add_child(kangaskhan_instance)
	else:
		add_child(kangaskhan_instance)
	print("Kangaskhan added to party for debug.")

func _on_add_kangaskhan_as_enemy_pressed() -> void:
	# Instance Kangaskhan scene and add to the scene tree as enemy
	var kangaskhan_scene = load("res://Scenes/Units/Kangaskhan.tscn")
	var kangaskhan_instance = kangaskhan_scene.instantiate()
	# Add to enemy group for logic separation
	kangaskhan_instance.add_to_group("enemy_pokemon")
	# Add to Units node if it exists
	var units_node = get_node_or_null("../Units")
	if units_node:
		units_node.add_child(kangaskhan_instance)
	else:
		add_child(kangaskhan_instance)
	print("Kangaskhan added as enemy for debug.")
#endregion
