extends Node

@warning_ignore("unused_signal")
signal player_fled_battle

var CalculatingDamage = false
var inBattle = false
var inBattleSelect = false
var inItems = false
var switchingPokemon = false
var mMenuVisible = false
var tmVisible = false

var player_position: Vector2 = Vector2.ZERO

var player_party: Array = []
var enemy_party: Array = []

# Helper: Add a Pokémon to the party (returns true if added, false if full)
func add_pokemon_to_party(pokemon_dict: Dictionary) -> bool:
	if player_party.size() >= 6:
		print("party full")
		return false
	player_party.append(pokemon_dict)
	return true

# Helper: Remove a Pokémon by unique_id (returns true if removed)
func remove_pokemon_from_party(unique_id: int) -> bool:
	for i in range(player_party.size()):
		if player_party[i].get("unique_id", -1) == unique_id:
			player_party.remove_at(i)
			return true
	return false

# Helper: Get Pokémon by unique_id (returns Dictionary or null)
func get_pokemon_by_id(unique_id: int) -> Dictionary:
	for poke in player_party:
		if poke.get("unique_id", -1) == unique_id:
			return poke
	return {}

# Helper: Update a Pokémon's field by unique_id
func update_pokemon_field(unique_id: int, field: String, value) -> bool:
	for poke in player_party:
		if poke.get("unique_id", -1) == unique_id:
			poke[field] = value
			return true
	return false

# Helper: Clear all stat debuffs for a Pokémon (e.g., after battle)
func clear_stat_debuffs(unique_id: int) -> void:
	for poke in player_party:
		if poke.get("unique_id", -1) == unique_id:
			poke["stat_debuffs"] = {}
			return


# --- Player position tracking ---
# Continuously updated by the map/player scene
# Call this from the player or map script to update the position
func update_player_position(pos: Vector2) -> void:
	player_position = pos
