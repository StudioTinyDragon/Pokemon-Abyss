extends Node2D


@onready var test_map: Node2D = $"."
@onready var ground: TileMapLayer = $Ground
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	StateManager.inBattle = false
