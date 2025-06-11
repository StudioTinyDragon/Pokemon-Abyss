extends Node2D


var player_pokemon = null
var enemy_pokemon = null



func _ready() -> void:
	# Set player_pokemon and enemy_pokemon only after the node is in the scene tree
	var pokemon = _get_battle_pokemon()
	player_pokemon = pokemon["player"]
	enemy_pokemon = pokemon["enemy"]
	# Connect to switchPM2 signal for party switching
	if StateManager.has_signal("switchPM2"):
		StateManager.connect("switchPM2", Callable(self, "_on_switchPM2"))



func _get_battle_pokemon() -> Dictionary: # Helper: get player and enemy pokemon
	var pokemons = get_tree().get_nodes_in_group("player_pokemon")
	player_pokemon = null
	if pokemons.size() > 0:
		player_pokemon = pokemons[0]
		# Sync HP from party dictionary (always use first party member)
		if StateManager.player_party.size() > 0 and player_pokemon and "current_hp" in StateManager.player_party[0]:
			player_pokemon.currentHP = StateManager.player_party[0]["current_hp"]
	var enemies = get_tree().get_nodes_in_group("enemy_pokemon")
	enemy_pokemon = null
	if enemies.size() > 0:
		enemy_pokemon = enemies[0]
	return {"player": player_pokemon, "enemy": enemy_pokemon}

func is_pokemon_fainted(pokemon) -> bool:
	if not pokemon:
		return false
	if not ("currentHP" in pokemon):
		return false
	return pokemon.currentHP <= 0

func check_faint_and_remaining():
	# Returns a dictionary with fainted status and remaining count for both sides
	var result = {
		"player": {"fainted": false, "remaining": 0},
		"enemy": {"fainted": false, "remaining": 0}
	}

	# Check player side
	var player_fainted = is_pokemon_fainted(player_pokemon)
	var player_remaining = 0
	if StateManager.player_party.size() > 0:
		for poke in StateManager.player_party:
			if ("current_hp" in poke and poke["current_hp"] > 0):
				player_remaining += 1
	result["player"]["fainted"] = player_fainted
	result["player"]["remaining"] = player_remaining

	# Check enemy side (assuming enemy_party or similar for future, fallback to 1v1 for now)
	var enemy_fainted = is_pokemon_fainted(enemy_pokemon)
	var enemy_remaining = 1 if enemy_pokemon and not enemy_fainted else 0
	# If you have an enemy_party array, replace this logic with a loop like above
	result["enemy"]["fainted"] = enemy_fainted
	result["enemy"]["remaining"] = enemy_remaining

	return result

func _on_switchPM2():
	# Switch the player_pokemon in battle to the second pokemon in the party (index 1)
	if StateManager.player_party.size() > 1:
		var new_poke_dict = StateManager.player_party[1]
		# Find the corresponding node in the scene (by unique_id if possible)
		var new_poke_node = null
		if "unique_id" in new_poke_dict:
			for poke in get_tree().get_nodes_in_group("player_pokemon"):
				# Robust property check for uniquePokemonID
				if ("uniquePokemonID" in poke and poke["uniquePokemonID"] == new_poke_dict["unique_id"]):
					new_poke_node = poke
					break
		if new_poke_node == null:
			# fallback: just use the second node in the group
			var pokes = get_tree().get_nodes_in_group("player_pokemon")
			if pokes.size() > 1:
				new_poke_node = pokes[1]
		if new_poke_node:
			player_pokemon = new_poke_node
			# Optionally update HP from party dict
			if "current_hp" in new_poke_dict:
				player_pokemon.currentHP = new_poke_dict["current_hp"]
			# You may want to update UI or emit a signal here
			StateManager.emit_signal("switchedToPM2")
		else:
			print("[Battle] Could not find node for party slot 2.")
	else:
		print("[Battle] No second pokemon in party to switch to.")
