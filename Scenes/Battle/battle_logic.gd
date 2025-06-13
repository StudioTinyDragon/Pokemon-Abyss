extends Control

var is1v1 = false
var is2v2 = false
var is3v3 = false
var is4v4 = false
var is5v5 = false
var is6v6 = false

var isForest = true

func get_player_party() -> Dictionary:
	return StateManager.player_party

func get_enemy_party() -> Dictionary:
	return EncounterManager.enemy_party

# Returns the first N non-empty Pokémon for player and enemy, where N is determined by the current battle mode
func get_first_pokemon():
	var player_party = get_player_party()
	var enemy_party = get_enemy_party()
	var player_first = []
	var enemy_first = []
	# Determine N based on battle mode
	var N = 1
	if is2v2:
		N = 2
	elif is3v3:
		N = 3
	elif is4v4:
		N = 4
	elif is5v5:
		N = 5
	elif is6v6:
		N = 6
	# Find first N non-empty player Pokémon
	for i in range(1, 7):
		var key = "pokemon%d" % i
		if player_party.has(key) and player_party[key].has("name") and player_party[key]["name"] != null and player_party[key]["name"] != "":
			player_first.append(player_party[key])
			if player_first.size() >= N:
				break
	# Find first N non-empty enemy Pokémon
	for i in range(1, 7):
		var key = "pokemon%d" % i
		if enemy_party.has(key) and enemy_party[key].has("name") and enemy_party[key]["name"] != null and enemy_party[key]["name"] != "":
			enemy_first.append(enemy_party[key])
			if enemy_first.size() >= N:
				break
	return {"player": player_first, "enemy": enemy_first}
