extends Control

@onready var load_bar: Panel = $loadBar
@onready var load_bar_green: ColorRect = $loadBar/loadBarGreen



func _ready() -> void:
	await get_tree().process_frame
	var tween = get_tree().create_tween()
	tween.tween_property(load_bar_green, "size", Vector2(633, 57), 0.5) # 1900
	tween.play()
	await tween.finished
	tween.stop()
	if StateManager.toTestMap == true:
		StateManager.toTestMap = false
		load("res://Scenes/Battle/TestBattle.tscn")
		tween = get_tree().create_tween()
		tween.tween_property(load_bar_green, "size", Vector2(1266, 57), 0.5) # 1900
		tween.play()
		await tween.finished
		tween.stop()
		load("res://Scenes/Maps/TestMap.tscn")
		tween = get_tree().create_tween()
		tween.tween_property(load_bar_green, "size", Vector2(1900, 57), 0.5) # 1900
		tween.play()
		await tween.finished
		tween.stop()
		get_tree().change_scene_to_file("res://Scenes/Maps/TestMap.tscn")
