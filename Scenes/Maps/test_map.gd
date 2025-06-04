extends Node2D


@onready var test_map: Node2D = $"."
@onready var ground: TileMapLayer = $Ground
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	StateManager.inBattle = false
	# Connect to StateManager's signal for fleeing
	if not StateManager.is_connected("player_fled_battle", Callable(self, "_on_player_fled_battle")):
		StateManager.connect("player_fled_battle", Callable(self, "_on_player_fled_battle"))
		print("Connected StateManager.player_fled_battle signal in test_map.gd")


func _on_player_fled_battle():
	print("Flee triggered (via StateManager signal)")
	var test_battle_instance = $TestBattle
	print("TestBattle instance:", test_battle_instance)
	print("Ground node:", ground)
	print("Player node:", player)
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
