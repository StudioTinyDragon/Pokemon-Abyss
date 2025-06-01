extends CharacterBody2D

const SPEED = 220.0

func _process(delta: float) -> void:
	if StateManager.inBattle == false:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.x += Input.get_action_strength("d") - Input.get_action_strength("a")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector.y += Input.get_action_strength("s") - Input.get_action_strength("w")
		
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()

		var new_velocity = input_vector * SPEED
		var new_position = position + new_velocity * delta
		
	#region out of bounds check

		## Restrict player to map bounds only (no ground tile check)
		## Assumes parent is the city map TileMapLayer with grid_width/grid_height exported
		#var map_node = get_parent()
		#var map_size = Vector2i(20, 20)
		#if map_node and "grid_width" in map_node and "grid_height" in map_node:
			#map_size = Vector2i(map_node.grid_width, map_node.grid_height)
		#var cell_size = Vector2(16, 16)
		#if map_node and "cell_size_override" in map_node:
			#cell_size = map_node.cell_size_override
		#var cell = Vector2i(floor(new_position.x / cell_size.x), floor(new_position.y / cell_size.y))
		#if cell.x < 0 or cell.y < 0 or cell.x >= map_size.x or cell.y >= map_size.y:
			#velocity = Vector2.ZERO
			#return
	#endregion

		velocity = new_velocity
		move_and_slide()

		# --- INTERACTION: Show/hide 'F' label above trees every frame ---
		if typeof(Interaction) == TYPE_OBJECT:
			Interaction.update_tile1_interaction_labels(self)

		# --- INTERACTION: Check for trees nearby and handle 'F' key ---
		if Input.is_action_just_pressed("interact"):
			if typeof(Interaction) == TYPE_OBJECT:
				Interaction.try_interact_with_tile1(self)
