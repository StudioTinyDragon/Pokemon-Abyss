extends Node2D


@onready var tm_panel: Panel = $TMPanel
@onready var back_button: Button = $TMPanel/BackButton

@onready var pokemon_1: Button = $TMPanel/Pokemon1
@onready var pokemon_name_1: Label = $TMPanel/Pokemon1/PokemonName1
@onready var pokemon_lvl_1: Label = $TMPanel/Pokemon1/PokemonLvl1
@onready var pokemon_gender_1: Label = $TMPanel/Pokemon1/PokemonGender1
@onready var pokemon_pic_1: Label = $TMPanel/Pokemon1/PokemonPic1
@onready var pokemon_hp_1: Label = $TMPanel/Pokemon1/PokemonHP1
@onready var pokemon_status_1: Label = $TMPanel/Pokemon1/PokemonStatus1
@onready var pokemon_2: Button = $TMPanel/Pokemon2
@onready var pokemon_name_2: Label = $TMPanel/Pokemon2/PokemonName2
@onready var pokemon_lvl_2: Label = $TMPanel/Pokemon2/PokemonLvl2
@onready var pokemon_gender_2: Label = $TMPanel/Pokemon2/PokemonGender2
@onready var pokemon_pic_2: Label = $TMPanel/Pokemon2/PokemonPic2
@onready var pokemon_hp_2: Label = $TMPanel/Pokemon2/PokemonHP2
@onready var pokemon_status_2: Label = $TMPanel/Pokemon2/PokemonStatus2
@onready var pokemon_3: Button = $TMPanel/Pokemon3
@onready var pokemon_name_3: Label = $TMPanel/Pokemon3/PokemonName3
@onready var pokemon_lvl_3: Label = $TMPanel/Pokemon3/PokemonLvl3
@onready var pokemon_gender_3: Label = $TMPanel/Pokemon3/PokemonGender3
@onready var labe_pokemon_pic_3: Label = $TMPanel/Pokemon3/LabePokemonPic3
@onready var pokemon_hp_3: Label = $TMPanel/Pokemon3/PokemonHP3
@onready var pokemon_status_3: Label = $TMPanel/Pokemon3/PokemonStatus3
@onready var pokemon_4: Button = $TMPanel/Pokemon4
@onready var pokemon_name_4: Label = $TMPanel/Pokemon4/PokemonName4
@onready var pokemon_lvl_4: Label = $TMPanel/Pokemon4/PokemonLvl4
@onready var pokemon_gender_4: Label = $TMPanel/Pokemon4/PokemonGender4
@onready var pokemon_pic_4: Label = $TMPanel/Pokemon4/PokemonPic4
@onready var pokemon_hp_4: Label = $TMPanel/Pokemon4/PokemonHP4
@onready var pokemon_status_4: Label = $TMPanel/Pokemon4/PokemonStatus4
@onready var pokemon_5: Button = $TMPanel/Pokemon5
@onready var pokemon_name_5: Label = $TMPanel/Pokemon5/PokemonName5
@onready var pokemon_lvl_5: Label = $TMPanel/Pokemon5/PokemonLvl5
@onready var pokemon_gender_5: Label = $TMPanel/Pokemon5/PokemonGender5
@onready var pokemon_pic_5: Label = $TMPanel/Pokemon5/PokemonPic5
@onready var pokemon_hp_5: Label = $TMPanel/Pokemon5/PokemonHP5
@onready var pokemon_status_5: Label = $TMPanel/Pokemon5/PokemonStatus5
@onready var pokemon_6: Button = $TMPanel/Pokemon6
@onready var pokemon_name_6: Label = $TMPanel/Pokemon6/PokemonName6
@onready var pokemon_lvl_6: Label = $TMPanel/Pokemon6/PokemonLvl6
@onready var pokemon_gender_6: Label = $TMPanel/Pokemon6/PokemonGender6
@onready var pokemon_pic_6: Label = $TMPanel/Pokemon6/PokemonPic6
@onready var pokemon_hp_6: Label = $TMPanel/Pokemon6/PokemonHP6
@onready var pokemon_status_6: Label = $TMPanel/Pokemon6/PokemonStatus6





func _ready() -> void:
	# Try to find InGameMenu node anywhere in the scene tree
	var in_game_menus = get_tree().get_nodes_in_group("InGameMenu")
	var in_game_menu = null
	if in_game_menus.size() > 0:
		in_game_menu = in_game_menus[0]
	else:
		# fallback: search by name
		in_game_menu = get_tree().get_root().find_node("InGameMenu", true, false)
	if in_game_menu and in_game_menu.has_signal("pokemonTeamPressed"):
		in_game_menu.connect("pokemonTeamPressed", Callable(self, "_on_pokemon_team_pressed"))

# Show the team panel when the signal is emitted

func _on_pokemon_team_pressed():
	tm_panel.visible = true
	StateManager.tmVisible = true
	_update_party_labels()

# Updates the labels in the team manager to show the current party
func _update_party_labels():
	var party = StateManager.player_party
	# Slot 1
	if party.size() > 0:
		var poke = party[0]
		pokemon_name_1.text = poke.get("name", "-")
		pokemon_lvl_1.text = str(poke.get("level", "-"))
		pokemon_hp_1.text = str(poke.get("current_hp", "-")) + "/" + str(poke.get("max_hp", "-"))
	else:
		pokemon_name_1.text = "-"
		pokemon_lvl_1.text = "-"
		pokemon_hp_1.text = "-"
	# Slot 2
	if party.size() > 1:
		var poke = party[1]
		pokemon_name_2.text = poke.get("name", "-")
		pokemon_lvl_2.text = str(poke.get("level", "-"))
		pokemon_hp_2.text = str(poke.get("current_hp", "-")) + "/" + str(poke.get("max_hp", "-"))
	else:
		pokemon_name_2.text = "-"
		pokemon_lvl_2.text = "-"
		pokemon_hp_2.text = "-"
	# Slot 3
	if party.size() > 2:
		var poke = party[2]
		pokemon_name_3.text = poke.get("name", "-")
		pokemon_lvl_3.text = str(poke.get("level", "-"))
		pokemon_hp_3.text = str(poke.get("current_hp", "-")) + "/" + str(poke.get("max_hp", "-"))
	else:
		pokemon_name_3.text = "-"
		pokemon_lvl_3.text = "-"
		pokemon_hp_3.text = "-"
	# Slot 4
	if party.size() > 3:
		var poke = party[3]
		pokemon_name_4.text = poke.get("name", "-")
		pokemon_lvl_4.text = str(poke.get("level", "-"))
		pokemon_hp_4.text = str(poke.get("current_hp", "-")) + "/" + str(poke.get("max_hp", "-"))
	else:
		pokemon_name_4.text = "-"
		pokemon_lvl_4.text = "-"
		pokemon_hp_4.text = "-"
	# Slot 5
	if party.size() > 4:
		var poke = party[4]
		pokemon_name_5.text = poke.get("name", "-")
		pokemon_lvl_5.text = str(poke.get("level", "-"))
		pokemon_hp_5.text = str(poke.get("current_hp", "-")) + "/" + str(poke.get("max_hp", "-"))
	else:
		pokemon_name_5.text = "-"
		pokemon_lvl_5.text = "-"
		pokemon_hp_5.text = "-"
	# Slot 6
	if party.size() > 5:
		var poke = party[5]
		pokemon_name_6.text = poke.get("name", "-")
		pokemon_lvl_6.text = str(poke.get("level", "-"))
		pokemon_hp_6.text = str(poke.get("current_hp", "-")) + "/" + str(poke.get("max_hp", "-"))
	else:
		pokemon_name_6.text = "-"
		pokemon_lvl_6.text = "-"
		pokemon_hp_6.text = "-"


# Returns an array of dictionaries with each Pokémon's name and its position in the party
func get_party_names_and_positions() -> Array:
	var result = []
	for i in range(StateManager.player_party.size()):
		var pokemon = StateManager.player_party[i]
		var name = pokemon.get("name", "Unknown")
		result.append({"name": name, "position": i})
	return result


func _on_back_button_pressed() -> void:
	tm_panel.visible = false
	StateManager.tmVisible = false
