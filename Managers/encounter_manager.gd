extends Node

func debugKangaskhanEncounter():
	# Instance Kangaskhan scene and add to the scene tree as enemy
	var kangaskhan_scene = load("res://Scenes/Units/Kangaskhan.tscn")
	var kangaskhan_instance = kangaskhan_scene.instantiate()
	# Assign a unique ID to this enemy Kangaskhan (different from player's)
	# Use a timestamp + random value for uniqueness
	kangaskhan_instance.uniquePokemonID = int(Time.get_unix_time_from_system()) + randi() % 100000
	# Add to enemy group for logic separation
	kangaskhan_instance.add_to_group("enemy_pokemon")
	# Add to Units node if it exists
	var units_node = get_node_or_null("../Units")
	if units_node:
		units_node.add_child(kangaskhan_instance)
	else:
		add_child(kangaskhan_instance)
	print("Kangaskhan added as enemy for debug.")

	var enemies = get_tree().get_nodes_in_group("enemy_pokemon")
	for enemy_pokemon in enemies:
		if enemy_pokemon.has_method("SetPotentiellMoves"):
			enemy_pokemon.SetPotentiellMoves()
		if enemy_pokemon.has_method("SetMoves"):
			enemy_pokemon.SetMoves()
		if enemy_pokemon.has_method("setMove1PP"):
			enemy_pokemon.setMove1PP()
		if enemy_pokemon.has_method("setMove2PP"):
			enemy_pokemon.setMove2PP()
		if enemy_pokemon.has_method("setMove3PP"):
			enemy_pokemon.setMove3PP()
		if enemy_pokemon.has_method("setMove4PP"):
			enemy_pokemon.setMove4PP()
		# Ensure enemy move instances are created from .tscn scenes (for Inspector values)
		if enemy_pokemon.has_method("instantiate_moves"):
			enemy_pokemon.instantiate_moves()
		# Set all move PP from currentMoves (robust fallback)
		if enemy_pokemon.has_method("set_all_move_pp_from_current_moves"):
			enemy_pokemon.set_all_move_pp_from_current_moves()
