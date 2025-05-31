extends Node2D


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
			move_1_button.text = player_pokemon.currentMoves[0]
			print("f")
		if player_pokemon.currentMoves.size() > 1:
			move_2_button.text = player_pokemon.currentMoves[1]
			print("f")
		if player_pokemon.currentMoves.size() > 2:
			move_3_button.text = player_pokemon.currentMoves[2]
			print("f")
		if player_pokemon.currentMoves.size() > 3:
			move_4_button.text = player_pokemon.currentMoves[3]
			print("f")
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


func _on_set_moves_button_pressed() -> void:
	var player_pokemon = null
	var pokemons = get_tree().get_nodes_in_group("player_pokemon")
	if pokemons.size() > 0:
		player_pokemon = pokemons[0]
	if player_pokemon:
		print("a")
		player_pokemon.SetPotentiellMoves()
		player_pokemon.SetMoves()


func _on_add_kangaskhan_pressed() -> void:
	# Instance Kangaskhan scene and add to the scene tree for debug/party
	var kangaskhan_scene = load("res://Scenes/Units/Kangaskhan.tscn")
	var kangaskhan_instance = kangaskhan_scene.instantiate()
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


func execute_move(attacker, defender, move_instance, move_name, damage_calculator):
	if not attacker or not defender or not move_instance:
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
		elif defender.has_method("is_in_group") and defender.is_in_group("player_pokemon"):
			print("Player HP:", defender.currentHP)
		if attacker.has_method("is_in_group") and attacker.is_in_group("enemy_pokemon"):
			print("Enemy used %s!" % move_name)
			print("Enemy HP:", attacker.currentHP)
		elif defender.has_method("is_in_group") and defender.is_in_group("enemy_pokemon"):
			print("Enemy HP:", defender.currentHP)
	else:
		print("No valid defender HP.")


func _on_move_1_button_pressed() -> void:
	if get_tree() == null:
		print("Error: get_tree() is null!")
		return
	var pokemons = get_tree().get_nodes_in_group("player_pokemon")
	var player_pokemon = null
	if pokemons.size() > 0:
		player_pokemon = pokemons[0]
	var enemies = get_tree().get_nodes_in_group("enemy_pokemon")
	var enemy_pokemon = null
	if enemies.size() > 0:
		enemy_pokemon = enemies[0]

	# Get move name from slot 1 for player
	var player_move_name = null
	if player_pokemon and player_pokemon.currentMoves.size() > 0:
		player_move_name = player_pokemon.currentMoves[0]

	# Enemy selects a random valid move
	var enemy_move_name = null
	if enemy_pokemon and enemy_pokemon.currentMoves.size() > 0:
		var rng = RandomNumberGenerator.new()
		enemy_move_name = enemy_pokemon.currentMoves[rng.randi_range(0, enemy_pokemon.currentMoves.size() - 1)]

	# Load move scripts
	var player_move_instance = null
	if player_move_name:
		var player_move_path = "res://Scripts/Moves/%s.gd" % player_move_name
		if ResourceLoader.exists(player_move_path):
			var move_resource = load(player_move_path)
			player_move_instance = move_resource.new()
	var enemy_move_instance = null
	if enemy_move_name:
		var enemy_move_path = "res://Scripts/Moves/%s.gd" % enemy_move_name
		if ResourceLoader.exists(enemy_move_path):
			var move_resource = load(enemy_move_path)
			enemy_move_instance = move_resource.new()

	# Load damage_calculator
	var damage_calculator = get_node("/root").get("damage_calculator") if has_node("/root/damage_calculator") else preload("res://Managers/damage_calculator.gd").new()

	# Determine initiative
	var player_initiative = player_pokemon.Iniative if player_pokemon else 0
	var enemy_initiative = enemy_pokemon.Iniative if enemy_pokemon else 0

	# Execute moves in order of initiative
	if player_move_instance and enemy_move_instance:
		if player_initiative > enemy_initiative:
			execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
			execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
		elif enemy_initiative > player_initiative:
			execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
			execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
		else:
			# If tied, player goes first
			execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
			execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
	elif player_move_instance:
		execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator)
	elif enemy_move_instance:
		execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator)
	else:
		print("No valid moves to execute.")
