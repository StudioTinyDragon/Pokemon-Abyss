extends Node2D


@onready var new_game_button: Button = $"New Game Button"
@onready var load_game_button: Button = $"Load Game Button"
@onready var options_button: Button = $"Options Button"
@onready var exit_game_button: Button = $"Exit Game Button"
@onready var test_map_button: Button = $testMapButton




func _on_test_map_button_pressed() -> void:
	StateManager.toTestMap = true
	get_tree().change_scene_to_file("res://Scenes/Menus/loading_screen.tscn")
