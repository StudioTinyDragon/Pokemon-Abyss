extends TileMapLayer

@export var grid_width: int = 60
@export var grid_height: int = 60
@export var default_tile_id: int = 0
@export var cell_size_override: Vector2i = Vector2(16, 16) # Adjust if your tile is not 32x32
@onready var battle_layer: CanvasLayer = $"../BattleLayer"
@onready var player: CharacterBody2D = $"../Player"
@onready var test_map: Node2D = $".."
@onready var ground: TileMapLayer = $"."



var grid_overlay: Node2D = null
var grid_overlay_visible: bool = true

func _ready() -> void:
	print("Filled grid with tiles using set_cell(local_to_map(...))")
	# Add grid overlay
	add_grid_overlay()
	toggle_grid_overlay()
	addCustomTile1(Vector2i(1, 1), Vector2i(6, 30))

#region gridoverlay
class GridOverlay extends Node2D:
	var grid_width: int
	var grid_height: int
	var cell_size: Vector2
	var color: Color = Color(1,1,1,0.25)
	var line_width: float = 1.0

	func _draw():
		var w = cell_size.x
		var h = cell_size.y
		var total_w = grid_width * w
		var total_h = grid_height * h
		# Vertical lines
		for x in range(grid_width+1):
			var x_pos = x * w
			draw_line(Vector2(x_pos, 0), Vector2(x_pos, total_h), color, line_width)
		# Horizontal lines
		for y in range(grid_height+1):
			var y_pos = y * h
			draw_line(Vector2(0, y_pos), Vector2(total_w, y_pos), color, line_width)

func add_grid_overlay():
	if grid_overlay:
		grid_overlay.queue_free()
	grid_overlay = GridOverlay.new()
	grid_overlay.grid_width = grid_width
	grid_overlay.grid_height = grid_height
	grid_overlay.cell_size = Vector2(cell_size_override.x, cell_size_override.y)
	add_child(grid_overlay)
	grid_overlay.queue_redraw()
	grid_overlay.visible = grid_overlay_visible

func toggle_grid_overlay():
	grid_overlay_visible = !grid_overlay_visible
	if grid_overlay:
		grid_overlay.visible = grid_overlay_visible

func _unhandled_input(event):
	if event is InputEventKey and event.keycode == KEY_SPACE and event.pressed and not event.echo:
		toggle_grid_overlay()
#endregion

func addCustomTile1(cell: Vector2i, tile_id: Vector2i):
	set_cell(cell, 0, tile_id)
	# Add collision for the tree
	var tileCollision1 = StaticBody2D.new()
	tileCollision1.name = "tileCollision1_%s_%s" % [cell.x, cell.y]
	var shape = RectangleShape2D.new()
	# Adjust the size to match your tree sprite (here, 16x16 as a default, change as needed)
	shape.extents = Vector2(7, 7)
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	tileCollision1.position = map_to_local(cell)
	tileCollision1.add_child(collision_shape)
	# Add 'F' label above the tree, hidden by default
	var f_label = Label.new()
	f_label.text = "F"
	f_label.name = "FLabel"
	f_label.visible = false
	f_label.position = Vector2(0, -18) # Offset above the tree, adjust as needed
	# Set a smaller font size using theme override (Godot 4 way)
	f_label.add_theme_font_size_override("font_size", 8)
	tileCollision1.add_child(f_label)
	add_child(tileCollision1)
