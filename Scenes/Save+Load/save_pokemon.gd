extends Node

# Call this to save the player's party to JSON
func save_party():
	if SaveManager.save_player_party_to_json():
		print("[save_pokemon] Player party saved!")
	else:
		print("[save_pokemon] Failed to save player party.")

# Call this to load the player's party from JSON and update StateManager
func load_party():
	var loaded_party = SaveManager.load_player_party_from_json()
	if loaded_party.size() > 0:
		StateManager.player_party = loaded_party
		print("[save_pokemon] Player party loaded and set in StateManager.")
	else:
		print("[save_pokemon] No party loaded or file empty.")
