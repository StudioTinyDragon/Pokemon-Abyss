extends Node2D

@onready var debug_panel: Panel = $DebugPanel
@onready var add_kangaskhan: Button = $DebugPanel/addKangaskhan
@onready var load_party_button: Button = $DebugPanel/loadPartyButton
@onready var save_party_button: Button = $DebugPanel/savePartyButton


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

func _on_add_kangaskhan_pressed() -> void:
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


func _on_save_party_button_pressed() -> void:
	SaveManager.save_player_party_to_json()

func _on_load_party_button_pressed() -> void:
	var loaded_party = SaveManager.load_player_party_from_json()
	if loaded_party.size() > 0:
		StateManager.player_party = loaded_party
		print("[save_pokemon] Player party loaded and set in StateManager.")
	else:
		print("[save_pokemon] No party loaded or file empty.")
