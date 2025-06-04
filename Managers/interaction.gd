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
							print(StateManager.player_position)
							# Emit signal to request the battle scene to start the fight
							emit_signal("request_ready_to_fight")
						elif node.has_node("BattleLayer"):
							node.get_node("BattleLayer").visible = true
							StateManager.inBattle = true

					# Hide tilemap
					if "ground" in node:
						node.ground.visible = false
					# Hide player
					var parent = node.get_parent()
					if parent and parent.has_node("Player"):
						var player_node = parent.get_node("Player")
						if player_node.has_node("PlayerSprite2D"):
							player_node.get_node("PlayerSprite2D").visible = false
							print("Sprite Player Invisible")
						else:
							print("[DEBUG] PlayerSprite2D node not found in Player node:", player_node)

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
