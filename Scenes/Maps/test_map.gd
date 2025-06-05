extends Node2D


@onready var test_map: Node2D = $"."
@onready var ground: TileMapLayer = $Ground
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	StateManager.inBattle = false
	# Connect to StateManager's signal for fleeing
	StateManager.connect("player_fled_battle", Callable(self, "_on_player_fled_battle"))


func _on_player_fled_battle():
	ground.visible = true
	player.visible = true
	StateManager.inBattle = false
	var root = player.get_tree().current_scene
	for node in root.get_children():
		var parent = node.get_parent()
		if parent and parent.has_node("Player"):
			var player_node = parent.get_node("Player")
			if player_node.has_node("PlayerSprite2D"):
				player_node.get_node("PlayerSprite2D").visible = true
