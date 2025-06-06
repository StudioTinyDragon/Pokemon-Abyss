extends Control


func _ready() -> void:
	# Example: Add a Kangaskhan to the party at game start
	var kangaskhan_scene = load("res://Scenes/Units/Kangaskhan.tscn")
	var kangaskhan_instance = kangaskhan_scene.instantiate()
	kangaskhan_instance.uniquePokemonID = int(Time.get_unix_time_from_system()) + randi() % 100000
	kangaskhan_instance.add_to_group("player_pokemon")
	var units_node = get_node_or_null("../Units")
	if units_node:
		units_node.add_child(kangaskhan_instance)
	else:
		add_child(kangaskhan_instance)
	print("Kangaskhan added to scene for debug.")

	# Add to party array as a dictionary
	var party_pokemon = {
		"name": kangaskhan_instance.Name,
		"unique_id": kangaskhan_instance.uniquePokemonID,
		"types": kangaskhan_instance.TYP.duplicate(),
		"level": kangaskhan_instance.currentLevel,
		"current_hp": kangaskhan_instance.currentHP,
		"max_hp": kangaskhan_instance.currentMaxHP,
		"moves": [
			{"name": "Pound", "pp": 35, "max_pp": 35},
			{"name": "Tail Whip", "pp": 30, "max_pp": 30}
		],
		"status_effects": [],
		"stat_debuffs": {"defense": 0.0, "attack": 0.0}
	}
	if StateManager.add_pokemon_to_party(party_pokemon):
		print("Kangaskhan added to player_party.")
	else:
		print("Party full, could not add Kangaskhan.")

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
