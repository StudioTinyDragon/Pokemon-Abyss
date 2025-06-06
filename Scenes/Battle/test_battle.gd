extends Node2D


var player_pokemon = null
var enemy_pokemon = null


func _ready() -> void:
	# Set player_pokemon and enemy_pokemon only after the node is in the scene tree
	var mons = _get_battle_pokemon()
	player_pokemon = mons["player"]
	enemy_pokemon = mons["enemy"]



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
