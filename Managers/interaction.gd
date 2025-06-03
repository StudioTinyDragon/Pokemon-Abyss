extends Node

# Signal to request the battle scene to start the fight
signal request_ready_to_fight

func try_interact_with_tile1(player: Node2D) -> void:
	var radius = 20 # pixels
	# Search the whole scene for TreeCollision nodes
	var root = player.get_tree().current_scene
	for node in root.get_children():
		if node is TileMapLayer:
			for child in node.get_children():
				if child is StaticBody2D and child.name.begins_with("tileCollision1_"):
					var dist = player.global_position.distance_to(child.global_position)
					if dist <= radius:
						# Make the battle_layer visible
						if "battle_layer" in node:
							node.battle_layer.visible = true
							StateManager.inBattle = true
							EncounterManager.debugKangaskhanEncounter()
							# Emit signal to request the battle scene to start the fight
							emit_signal("request_ready_to_fight")
						elif node.has_node("BattleLayer"):
							node.get_node("BattleLayer").visible = true
							StateManager.inBattle = true

						# Hide the map and player when starting battle
						if "test_map" in node:
							node.test_map.visible = false
						elif node.has_node("TestMap"):
							node.get_node("TestMap").visible = false

						# Hide the player (assume player is a child of the map or scene)
						if "player" in node:
							node.player.visible = false
						elif node.has_node("Player"):
							node.get_node("Player").visible = false
						return

func update_tile1_interaction_labels(player: Node2D) -> void:
	var radius = 22 # pixels
	var root = player.get_tree().current_scene
	for node in root.get_children():
		if node is TileMapLayer:
			for child in node.get_children():
				if child is StaticBody2D and child.name.begins_with("tileCollision1_"):
					var f_label = child.get_node_or_null("FLabel")
					if f_label:
						var dist = player.global_position.distance_to(child.global_position)
						f_label.visible = dist <= radius
