extends Node


# Called when the node enters the scene tree for the first time.

# Save the player's party to JSON
func save_player_party_to_json():
	var party = StateManager.player_party
	var save_path = "res://Scenes/Save+Load/Savefiles/partyPokemonSave.json"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		print("[SaveManager] Could not open file for writing: ", save_path)
		return false
	var json = JSON.stringify(party, "\t")
	file.store_string(json)
	file.close()
	print("[SaveManager] Player party saved to ", save_path)
	return true

# Load the player's party from JSON
func load_player_party_from_json():
	var save_path = "res://Scenes/Save+Load/Savefiles/partyPokemonSave.json"
	if not FileAccess.file_exists(save_path):
		print("[SaveManager] Save file does not exist: ", save_path)
		return []
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		print("[SaveManager] Could not open file for reading: ", save_path)
		return []
	var json = file.get_as_text()
	file.close()
	var result = JSON.parse_string(json)
	if result is Array:
		print("[SaveManager] Player party loaded from ", save_path)
		return result
	else:
		print("[SaveManager] Failed to parse player party JSON.")
		return []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
