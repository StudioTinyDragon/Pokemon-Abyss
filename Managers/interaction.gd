extends Node

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
						#if node.has_method("show_chopping_tree_minigame"):
							#node.show_chopping_tree_minigame(Callable(self, "_on_tree_minigame_complete").bind(child))
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
