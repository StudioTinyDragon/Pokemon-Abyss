extends Node2D


@onready var add_kangaskhan: Button = $addKangaskhan


func _on_add_kangaskhan_pressed() -> void:
	# Instance Kangaskhan scene and add to the scene tree for debug/party
	var kangaskhan_scene = load("res://Scenes/Units/Kangaskhan.tscn")
	var kangaskhan_instance = kangaskhan_scene.instantiate()
	kangaskhan_instance.uniquePokemonID = int(Time.get_unix_time_from_system()) + randi() % 100000
	print(kangaskhan_instance.uniquePokemonID)
	# Add to player group for logic separation
	kangaskhan_instance.add_to_group("player_pokemon")
	# Optionally set position or parent as needed
	var units_node = get_node_or_null("../Units")
	if units_node:
		units_node.add_child(kangaskhan_instance)
	else:
		add_child(kangaskhan_instance)
	print("Kangaskhan added to scene for debug.")

	# Build party dictionary for Kangaskhan and add to StateManager party
	var party_pokemon = {
		"name": kangaskhan_instance.Name,
		"unique_id": kangaskhan_instance.get_instance_id(),
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
