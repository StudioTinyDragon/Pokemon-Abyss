extends Node2D


var player_pokemon = null
var enemy_pokemon = null


func _ready() -> void:
	# Set player_pokemon and enemy_pokemon only after the node is in the scene tree
	var pokemon = _get_battle_pokemon()
	player_pokemon = pokemon["player"]
	enemy_pokemon = pokemon["enemy"]


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
