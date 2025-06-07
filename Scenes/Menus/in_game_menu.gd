extends Control

@onready var battle_ui: Control = $"."
@onready var menu_panel: Panel = $MenuPanel
@onready var trainer_id_button: Button = $MenuPanel/TrainerIDButton
@onready var bag_button: Button = $MenuPanel/BagButton
@onready var pokemon_team_button: Button = $MenuPanel/PokemonTeamButton
@onready var pokedex_button: Button = $MenuPanel/PokedexButton
@onready var map_button: Button = $MenuPanel/MapButton
@onready var save_button: Button = $MenuPanel/SaveButton
@onready var load_button: Button = $MenuPanel/LoadButton
@onready var debug_menu_button: Button = $MenuPanel/DebugMenuButton
@onready var options_button: Button = $MenuPanel/OptionsButton



func _ready() -> void:
	add_to_group("InGameMenu")

func _input(event):
	if event.is_action_pressed("MainMenu") && StateManager.tmVisible == false && StateManager.inBattle == false:
		if not menu_panel.visible == true:
			menu_panel.visible = true
			StateManager.mMenuVisible = true

		else:
			menu_panel.visible = false
			StateManager.mMenuVisible = false


signal pokemonTeamPressed
func _on_pokemon_team_button_pressed() -> void:
	emit_signal("pokemonTeamPressed")
	menu_panel.visible = false

signal DebugMenuPressed
func _on_debug_menu_button_pressed() -> void:
	emit_signal("DebugMenuPressed")
