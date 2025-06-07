extends Node2D

@onready var debug_panel: Panel = $DebugPanel
@onready var add_kangaskhan: Button = $Panel/addKangaskhan

func _ready() -> void:
	# Try to find InGameMenu node anywhere in the scene tree
	var in_game_menus = get_tree().get_nodes_in_group("InGameMenu")
	var in_game_menu = null
	if in_game_menus.size() > 0:
		in_game_menu = in_game_menus[0]
	else:
		# fallback: search by name
		in_game_menu = get_tree().get_root().find_node("InGameMenu", true, false)
	if in_game_menu and in_game_menu.has_signal("DebugMenuPressed"):
		in_game_menu.connect("DebugMenuPressed", Callable(self, "_on_debug_menu_button_pressed"))

func _on_debug_menu_button_pressed():
	if debug_panel.visible == false:
		debug_panel.visible = true

	else: debug_panel.visible = false
	print (debug_panel.visible)

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


func _on_save_party_button_pressed() -> void:
	SaveManager.save_player_party_to_json()

func _on_load_party_button_pressed() -> void:
	var loaded_party = SaveManager.load_player_party_from_json()
	if loaded_party.size() > 0:
		StateManager.player_party = loaded_party
		print("[save_pokemon] Player party loaded and set in StateManager.")
	else:
		print("[save_pokemon] No party loaded or file empty.")
