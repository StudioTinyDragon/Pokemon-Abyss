extends Control

@onready var load_bar: Panel = $loadBar
@onready var load_bar_green: ColorRect = $loadBar/loadBarGreen
@onready var tween: Tween = create_tween()



func _ready() -> void:
	await get_tree().process_frame
	# Animate the green bar from 0 to the width of load_bar
	load_bar_green.size.x = 0
	tween.tween_property(
		load_bar_green,
		"size:x",
		load_bar.size.x,
		1.5
	)
	tween.play()

	if StateManager.toTestMap == true:
		StateManager.toTestMap = false
		await  load("res://Scenes/Battle/TestBattle.tscn")
		await  load("res://Scenes/Maps/TestMap.tscn")
		get_tree().change_scene_to_file("uid://dgfbnyymaia6u")
