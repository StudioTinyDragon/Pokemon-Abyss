extends Control


func _ready() -> void:
	add_debug_kangaskhan_to_party()

func remove_pokemon_by_id(unique_id: int) -> bool:
	for i in range(StateManager.player_party.size()):
		if StateManager.player_party[i].get("unique_id", -1) == unique_id:
			StateManager.player_party.remove_at(i)
			return true
	return false

func get_pokemon_by_id(unique_id: int) -> Dictionary:
	for poke in StateManager.player_party:
		if poke.get("unique_id", -1) == unique_id:
			return poke
	return {}

func update_pokemon_field(unique_id: int, field: String, value) -> bool:
	for poke in StateManager.player_party:
		if poke.get("unique_id", -1) == unique_id:
			poke[field] = value
			return true
	return false

@warning_ignore("unused_parameter")
func add_debug_kangaskhan_to_party(level := 10, levelRange := 2) -> void:
	# Instance Kangaskhan scene and add to the scene tree as player Pokémon
	var kangaskhan_scene = load("uid://w66ycrams3y7")
	var kangaskhan_instance = kangaskhan_scene.instantiate()
	kangaskhan_instance.uniquePokemonID = int(Time.get_unix_time_from_system()) + randi() % 100000
	kangaskhan_instance.add_to_group("player_pokemon")
	var units_node = get_node_or_null("../Units")
	if units_node:
		units_node.add_child(kangaskhan_instance)
	else:
		add_child(kangaskhan_instance)
	print("Kangaskhan added to scene for debug.")

	# Set level and levelRange before WildGenerator
	if kangaskhan_instance.has_method("setLevel"):
		kangaskhan_instance.setLevel(1)
	var player = get_tree().get_nodes_in_group("player_pokemon")
	for player_pokemon in player:
		if player_pokemon.has_method("SetPotentiellMoves"):
			player_pokemon.SetPotentiellMoves()
		if player_pokemon.has_method("SetMoves"):
			player_pokemon.SetMoves()
		if player_pokemon.has_method("setMove1PP"):
			player_pokemon.setMove1PP()
		if player_pokemon.has_method("setMove2PP"):
			player_pokemon.setMove2PP()
		if player_pokemon.has_method("setMove3PP"):
			player_pokemon.setMove3PP()
		if player_pokemon.has_method("setMove4PP"):
			player_pokemon.setMove4PP()
	# Ensure move instances are created from .tscn scenes (for Inspector values)
	if kangaskhan_instance.has_method("instantiate_moves"):
		kangaskhan_instance.instantiate_moves()
	# Set all move PP from currentMoves (robust fallback)
	if kangaskhan_instance.has_method("set_all_move_pp_from_current_moves"):
		kangaskhan_instance.set_all_move_pp_from_current_moves()
	if kangaskhan_instance.has_method("setCurrentHP"):
		kangaskhan_instance.setCurrentHP()
	if kangaskhan_instance.has_method("GenderGenerator"):
		kangaskhan_instance.GenderGenerator()

	# Add to party array as a dictionary
	var party_pokemon = {
		"name": kangaskhan_instance.Name,
		"unique_id": kangaskhan_instance.uniquePokemonID,
		"types": kangaskhan_instance.TYP.duplicate(),
		"level": kangaskhan_instance.currentLevel,
		"current_hp": kangaskhan_instance.currentMaxHP,
		"max_hp": kangaskhan_instance.currentMaxHP,
		"moves": [],
		"status_effects": [],
		"stat_debuffs": {"defense": 0.0, "attack": 0.0}
	}
	# Fill moves from currentMoves and PP
	for i in range(kangaskhan_instance.currentMoves.size()):
		var move_name = kangaskhan_instance.currentMoves[i]
		var max_pp = 0
		match i:
			0:
				max_pp = kangaskhan_instance.Move1PP
			1:
				max_pp = kangaskhan_instance.Move2PP
			2:
				max_pp = kangaskhan_instance.Move3PP
			3:
				max_pp = kangaskhan_instance.Move4PP
		party_pokemon["moves"].append({"name": move_name, "pp": max_pp, "max_pp": max_pp})

	if StateManager.add_pokemon_to_party(party_pokemon):
		print("Kangaskhan added to player_party.")
	else:
		print("Party full, could not add Kangaskhan.")
