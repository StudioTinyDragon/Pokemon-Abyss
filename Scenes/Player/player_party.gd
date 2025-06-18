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



# --- Utility: Instance a Pokémon scene and add to the scene tree ---
func _instance_debug_pokemon(scene_path: String, group_name: String = "player_pokemon", parent_path: String = "../Units"):
	var poke_scene = load(scene_path)
	var poke_instance = poke_scene.instantiate()
	poke_instance.add_to_group(group_name)
	var units_node = get_node_or_null(parent_path)
	if units_node:
		units_node.add_child(poke_instance)
	else:
		add_child(poke_instance)
	print("Pokemon added to scene for debug from %s." % scene_path)
	return poke_instance

# --- Utility: Set up stats and moves for a Pokémon node ---
func _setup_pokemon_stats_and_moves(poke_instance, group_name: String = "player_pokemon"):
	if poke_instance.has_method("setLevel"):
		poke_instance.setLevel(1)
	if poke_instance.has_method("get_unique_id"):
		poke_instance.get_unique_id()
	var pokes = get_tree().get_nodes_in_group(group_name)
	for poke in pokes:
		if poke.has_method("SetPotentiellMoves"):
			poke.SetPotentiellMoves()
		if poke.has_method("SetMoves"):
			poke.SetMoves()
		if poke.has_method("setMove1PP"):
			poke.setMove1PP()
		if poke.has_method("setMove2PP"):
			poke.setMove2PP()
		if poke.has_method("setMove3PP"):
			poke.setMove3PP()
		if poke.has_method("setMove4PP"):
			poke.setMove4PP()
	if poke_instance.has_method("instantiate_moves"):
		poke_instance.instantiate_moves()
	if poke_instance.has_method("set_all_move_pp_from_current_moves"):
		poke_instance.set_all_move_pp_from_current_moves()
	if poke_instance.has_method("setCurrentHP"):
		poke_instance.setCurrentHP()
	if poke_instance.has_method("GenderGenerator"):
		poke_instance.GenderGenerator()

# --- Utility: Build moves array for party dictionary ---
func _build_moves_array(poke_instance):
	var moves_array = []
	for i in range(poke_instance.currentMoves.size()):
		var move_name = poke_instance.currentMoves[i]
		var max_pp = 0
		match i:
			0:
				max_pp = poke_instance.Move1PP
			1:
				max_pp = poke_instance.Move2PP
			2:
				max_pp = poke_instance.Move3PP
			3:
				max_pp = poke_instance.Move4PP
		moves_array.append({"name": move_name, "pp": max_pp, "max_pp": max_pp})
	return moves_array

# --- Utility: Build party dictionary for Pokémon ---
func _build_party_pokemon_dict(poke_instance, moves_array):
	return {
		"name": poke_instance.Name,
		"unique_id": poke_instance.uniquePokemonID,
		"types": poke_instance.TYP.duplicate(),
		"level": poke_instance.currentLevel,
		"current_hp": poke_instance.currentHP,
		"max_hp": poke_instance.currentMaxHP,
		"current_attack": poke_instance.currentAttack,
		"current_defense": poke_instance.currentDefense,
		"current_sp_attack": poke_instance.currentSPAttack,
		"current_sp_defense": poke_instance.currentSPDefense,
		"current_iniative": poke_instance.currentInitiative,
		"moves": moves_array.duplicate(),
		"status_effects": [],
		"stat_debuffs": {"defense": 0.0, "attack": 0.0},
		# Sprite file paths for UI
		"pokemon_front_sprite": poke_instance.PokemonFront if "PokemonFront" in poke_instance else "",
		"pokemon_back_sprite": poke_instance.PokemonBack if "PokemonBack" in poke_instance else "",
		"pokemon_icon_sprite": poke_instance.PokemonIcon if "PokemonIcon" in poke_instance else "",
		"pokemon_front_sprite_shiny": poke_instance.PokemonFrontShiny if "PokemonFrontShiny" in poke_instance else "",
		"pokemon_back_sprite_shiny": poke_instance.PokemonBackShiny if "PokemonBackShiny" in poke_instance else "",
		"pokemon_image_sprite": poke_instance.PokemonImage if "PokemonImage" in poke_instance else "",
		"is_shiny": poke_instance.isShiny,
		"Gender": poke_instance.Gender,
		"Nature": poke_instance.Nature,
		"move_1_pp": poke_instance.Move1PP,
		"move_2_pp": poke_instance.Move2PP,
		"move_3_pp": poke_instance.Move3PP,
		"move_4_pp": poke_instance.Move4PP,
		"held_item": poke_instance.heldItem,
		"exp": poke_instance.Exp,
		"ability": poke_instance.Ability,
		"trainings_hp": poke_instance.TrainingHP,
		"trainings_attack": poke_instance.TrainingAttack,
		"trainings_defense": poke_instance.TrainingDefense,
		"trainings_sp_attack": poke_instance.TrainingSPAttack,
		"trainings_sp_efense": poke_instance.TrainingSPDefense,
		"trainings_initiative": poke_instance.TrainingInitiative,
		"is_fainted": poke_instance.isFainted
	}

# --- Main: Add debug Pokémon to party (universal) ---
func add_debug_pokemon_to_party(scene_path: String, group_name: String = "player_pokemon", parent_path: String = "../Units") -> void:
	var poke_instance = _instance_debug_pokemon(scene_path, group_name, parent_path)
	_setup_pokemon_stats_and_moves(poke_instance, group_name)
	var moves_array = _build_moves_array(poke_instance)
	var party_pokemon = _build_party_pokemon_dict(poke_instance, moves_array)
	if StateManager.add_pokemon_to_party(party_pokemon):
		print("Pokemon added to player_party.")
	else:
		print("Party full, could not add Pokemon.")

# --- For compatibility: Add Kangaskhan as debug ---
func add_debug_kangaskhan_to_party():
	add_debug_pokemon_to_party("res://Scenes/Units/WildPokemon/Kangaskhan.tscn")
