extends TileMapLayer

# Add collision detection for player on tall grass tiles
@export var player_group_name: String = "Player"

func _physics_process(_delta):
	# Get all players in the scene (by group)
	var players = get_tree().get_nodes_in_group(player_group_name)
	for player in players:
		if not player.has_method("get_global_position"):
			continue
		var player_pos = player.get_global_position()
		var tile_pos = local_to_map(to_local(player_pos))
		# Check if there is a tile at this position (any layer)
		if get_cell_tile_data(tile_pos) != null:
			# Player is on a tall grass tile
			if not player.has_meta("in_tall_grass") or not player.get_meta("in_tall_grass"):
				player.set_meta("in_tall_grass", true)
				# Trigger wild encounter (debug Kangaskhan)
				if not Engine.has_singleton("EncounterManager"):
					if has_node("../../Managers/encounter_manager.gd"):
						get_node("../../Managers/encounter_manager.gd").debugKangaskhanEncounter()
					elif 'EncounterManager' in get_tree().get_root():
						get_tree().get_root().EncounterManager.debugKangaskhanEncounter()
					else:
						EncounterManager.debugKangaskhanEncounter()
				else:
					EncounterManager.debugKangaskhanEncounter()
		else:
			if player.has_meta("in_tall_grass") and player.get_meta("in_tall_grass"):
				player.set_meta("in_tall_grass", false)
