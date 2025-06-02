extends Node2D


@onready var test_map: Node2D = $"."
@onready var ground: TileMapLayer = $Ground

func _ready() -> void:
	StateManager.inBattle = false
