extends Node2D


@onready var test_map: Node2D = $"."

func _ready() -> void:
	StateManager.inBattle = false
