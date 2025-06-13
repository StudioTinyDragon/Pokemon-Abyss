extends Control

#region onready

@onready var battle_options: Panel = $BattleOptions
@onready var battle_button: Button = $BattleOptions/battleButton
@onready var button_2: Button = $BattleOptions/Button2
@onready var pokemon_button: Button = $BattleOptions/pokemonButton
@onready var flee_button: Button = $BattleOptions/fleeButton
@onready var move_options: Panel = $MoveOptions
@onready var move_1_button: Button = $MoveOptions/move1Button
@onready var move_2_button: Button = $MoveOptions/move2Button
@onready var move_3_button: Button = $MoveOptions/move3Button
@onready var move_4_button: Button = $MoveOptions/move4Button
@onready var move_go_back: Button = $MoveOptions/moveGoBack
@onready var enemy_statblock: Panel = $EnemyStatblock
@onready var enemy_name: Label = $EnemyStatblock/EnemyName
@onready var current_enemy_hp: Label = $EnemyStatblock/CurrentEnemyHP
@onready var current_enemy_status: Label = $EnemyStatblock/CurrentEnemyStatus
@onready var enemy_level: Label = $EnemyStatblock/EnemyLevel
@onready var gender_panel: Panel = $EnemyStatblock/GenderPanel
@onready var enemy_gender_sprite: Sprite2D = $EnemyStatblock/GenderPanel/EnemyGenderSprite
@onready var held_item_enemy: Panel = $EnemyStatblock/heldItemEnemy
@onready var held_item_icon_enemy: Sprite2D = $EnemyStatblock/heldItemEnemy/heldItemIconEnemy
@onready var held_item_label_enemy: Label = $EnemyStatblock/heldItemEnemy/heldItemLabelEnemy
@onready var nature: Panel = $EnemyStatblock/nature
@onready var nature_label_enemy: Label = $EnemyStatblock/nature/natureLabelEnemy
@onready var ablility: Panel = $EnemyStatblock/ablility
@onready var ability_label_enemy: Label = $EnemyStatblock/ablility/abilityLabelEnemy
@onready var typ: Panel = $EnemyStatblock/typ
@onready var typ_label_enemy: Label = $EnemyStatblock/typ/typLabelEnemy
@onready var own_statblock: Panel = $OwnStatblock
@onready var pokemon_name: Label = $OwnStatblock/PokemonName
@onready var current_pokemon_hp: Label = $OwnStatblock/CurrentPokemonHP
@onready var current_pokemon_status: Label = $OwnStatblock/CurrentPokemonStatus
@onready var own_level: Label = $OwnStatblock/OwnLevel
@onready var player_gender_sprite: Sprite2D = $OwnStatblock/GenderPanel/PlayerGenderSprite
@onready var held_item_player: Panel = $OwnStatblock/heldItemPlayer
@onready var held_item_icon_player: Sprite2D = $OwnStatblock/heldItemPlayer/heldItemIconPlayer
@onready var held_item_label_player: Label = $OwnStatblock/heldItemPlayer/heldItemLabelPlayer
@onready var nature_label_player: Label = $OwnStatblock/nature/natureLabelPlayer
@onready var ability_label_player: Label = $OwnStatblock/ablility/abilityLabelPlayer
@onready var typ_label_player: Label = $OwnStatblock/typ/typLabelPlayer
@onready var battle_dialogue_box: Panel = $battleDialogueBox
@onready var battle_text: RichTextLabel = $battleDialogueBox/battleText
@onready var ready_to_fight_timer: Timer = $battleDialogueBox/readyToFightTimer
@onready var attack_shoutout_timer: Timer = $battleDialogueBox/attackShoutoutTimer
@onready var background: Sprite2D = $Background
@onready var current_pokemon: Label = $BattleOptions/currentPokemon

@onready var player_1: Sprite2D = $Player1
@onready var bar_1: ColorRect = $Player1/Bar1
@onready var hp_1: ColorRect = $Player1/Bar1/HP1
@onready var player_2: Sprite2D = $Player2
@onready var bar_2: ColorRect = $Player2/Bar2
@onready var hp_2: ColorRect = $Player2/Bar2/HP2
@onready var player_3: Sprite2D = $Player3
@onready var bar_9: ColorRect = $Player3/Bar9
@onready var hp_9: ColorRect = $Player3/Bar9/HP9
@onready var player_4: Sprite2D = $Player4
@onready var bar_4: ColorRect = $Player4/Bar4
@onready var hp_4: ColorRect = $Player4/Bar4/HP4
@onready var player_5: Sprite2D = $Player5
@onready var bar_5: ColorRect = $Player5/Bar5
@onready var hp_5: ColorRect = $Player5/Bar5/HP5
@onready var player_6: Sprite2D = $Player6
@onready var bar_6: ColorRect = $Player6/Bar6
@onready var hp_6: ColorRect = $Player6/Bar6/HP6
@onready var enemy_1: Sprite2D = $Enemy1
@onready var bar_7: ColorRect = $Enemy1/Bar7
@onready var hp_7: ColorRect = $Enemy1/Bar7/HP7
@onready var enemy_2: Sprite2D = $Enemy2
@onready var bar_8: ColorRect = $Enemy2/Bar8
@onready var hp_8: ColorRect = $Enemy2/Bar8/HP8
@onready var enemy_3: Sprite2D = $Enemy3
@onready var bar_3: ColorRect = $Enemy3/Bar3
@onready var hp_3: ColorRect = $Enemy3/Bar3/HP3
@onready var enemy_4: Sprite2D = $Enemy4
@onready var bar_10: ColorRect = $Enemy4/Bar10
@onready var hp_10: ColorRect = $Enemy4/Bar10/HP10
@onready var enemy_5: Sprite2D = $Enemy5
@onready var bar_11: ColorRect = $Enemy5/Bar11
@onready var hp_11: ColorRect = $Enemy5/Bar11/HP11
@onready var enemy_6: Sprite2D = $Enemy6
@onready var bar_12: ColorRect = $Enemy6/Bar12
@onready var hp_12: ColorRect = $Enemy6/Bar12/HP12

#endregion


const FOREST = preload("res://Assets/parallax/forest.png")

const FEMALE_SIGN = preload("res://Assets/Icons/FemaleSign.png")
const MALE_SIGN = preload("res://Assets/Icons/MaleSign.png")

var SuperEffective = false
var notEffective = false


var player_pokemon = []
var enemy_pokemon = []
var enemyMaxHP
var playerMaxHP
var test_battle = get_parent()
var pokemon
var EnemyCurrentHP
var PlayerCurrentHP
var _battle_started


func _ready() -> void:
	setBackground()
	setPokemonVisible()
	signalManager()
	setPokemonSprite()

#region set Scene

func readyToFight():
	if _battle_started:
		return
	_battle_started = true
	battle_dialogue_box.visible = true
	battle_options.visible = false
	battle_text.text = "It's time to fight"

	# Fetch Pokémon data using BattleLogic singleton
	var battle_logic = null
	if has_node("/root/BattleLogic"):
		battle_logic = get_node("/root/BattleLogic")
	if battle_logic and battle_logic.has_method("get_first_pokemon"):
		pokemon = battle_logic.get_first_pokemon()
		player_pokemon = pokemon.get("player", [])
		enemy_pokemon = pokemon.get("enemy", [])

	# Set HP and max HP for UI (universal, dictionary-based)
	#showPokemonHP()
#
	## Set status effect labels for player and enemy
	#if current_pokemon_status and player_pokemon.size() > 0:
		#current_pokemon_status.text = _get_status_text(player_pokemon[0])
	#if current_enemy_status and enemy_pokemon.size() > 0:
		#current_enemy_status.text = _get_status_text(enemy_pokemon[0])
#
	#showPokemonNames()
	#setPokemonPosition()
	add_to_group("BattleUI")
	ready_to_fight_timer.start()
	if own_level and player_pokemon.size() > 0 and "currentLevel" in player_pokemon[0]:
		own_level.text = str(int(player_pokemon[0].currentLevel))
	if enemy_level and enemy_pokemon.size() > 0 and "currentLevel" in enemy_pokemon[0]:
		enemy_level.text = str(int(enemy_pokemon[0].currentLevel))

	# Set gender icons for player and enemy
	#if player_pokemon.size() > 0:
		#_set_gender_sprite(player_pokemon[0], player_gender_sprite)
		#_set_held_item(player_pokemon[0], held_item_label_player)
		#_set_ability_label(player_pokemon[0], ability_label_player)
		#_set_nature_label(player_pokemon[0], nature_label_player)
		#_get_typ_label(player_pokemon[0], typ_label_player)
	#if enemy_pokemon.size() > 0:
		#_set_gender_sprite(enemy_pokemon[0], enemy_gender_sprite)
		#_set_held_item(enemy_pokemon[0], held_item_label_enemy)
		#_set_ability_label(enemy_pokemon[0], ability_label_enemy)
		#_set_nature_label(enemy_pokemon[0], nature_label_enemy)
		#_get_typ_label(enemy_pokemon[0], typ_label_enemy)
#
	## Set move button colors at battle start
	#if player_pokemon.size() > 0 and "moves" in player_pokemon[0]:
		#var moves = player_pokemon[0]["moves"]
		#_set_move_button_color(move_1_button, _get_move_type(moves[0]) if moves.size() > 0 else "")
		#_set_move_button_color(move_2_button, _get_move_type(moves[1]) if moves.size() > 1 else "")
		#_set_move_button_color(move_3_button, _get_move_type(moves[2]) if moves.size() > 2 else "")
		#_set_move_button_color(move_4_button, _get_move_type(moves[3]) if moves.size() > 3 else "")
	#else:
		#_set_move_button_color(move_1_button, "")
		#_set_move_button_color(move_2_button, "")
		#_set_move_button_color(move_3_button, "")
		#_set_move_button_color(move_4_button, "")

	await get_tree().process_frame  # Wait one frame for everything to initialize
	print("[DEBUG] At battle start: player_pokemon =", player_pokemon)
	print("[DEBUG] At battle start: enemy_pokemon =", enemy_pokemon)

func _on_ready_to_fight_timer_timeout() -> void:
	battle_dialogue_box.visible = false
	battle_text.text = ""
	battle_options.visible = true
	enemy_statblock.visible = true
	own_statblock.visible = true


func setBackground():
	if BattleLogic.isForest:
		background.texture = FOREST

func setPokemonVisible():
	if BattleLogic.is1v1:
		player_1.visible = true
		enemy_1.visible = true
		player_2.visible = false
		enemy_2.visible = false
		player_3.visible = false
		enemy_3.visible = false
		player_4.visible = false
		enemy_4.visible = false
		player_5.visible = false
		enemy_5.visible = false
		player_6.visible = false
		enemy_6.visible = false
	if BattleLogic.is2v2:
		player_1.visible = true
		enemy_1.visible = true
		player_2.visible = true
		enemy_2.visible = true
		player_3.visible = false
		enemy_3.visible = false
		player_4.visible = false
		enemy_4.visible = false
		player_5.visible = false
		enemy_5.visible = false
		player_6.visible = false
		enemy_6.visible = false
	if BattleLogic.is3v3:
		player_1.visible = true
		enemy_1.visible = true
		player_2.visible = true
		enemy_2.visible = true
		player_3.visible = true
		enemy_3.visible = true
		player_4.visible = false
		enemy_4.visible = false
		player_5.visible = false
		enemy_5.visible = false
		player_6.visible = false
		enemy_6.visible = false
	if BattleLogic.is4v4:
		player_1.visible = true
		enemy_1.visible = true
		player_2.visible = true
		enemy_2.visible = true
		player_3.visible = true
		enemy_3.visible = true
		player_4.visible = true
		enemy_4.visible = true
		player_5.visible = false
		enemy_5.visible = false
		player_6.visible = false
		enemy_6.visible = false
	if BattleLogic.is5v5:
		player_1.visible = true
		enemy_1.visible = true
		player_2.visible = true
		enemy_2.visible = true
		player_3.visible = true
		enemy_3.visible = true
		player_4.visible = true
		enemy_4.visible = true
		player_5.visible = true
		enemy_5.visible = true
		player_6.visible = false
		enemy_6.visible = false
	if BattleLogic.is6v6:
		player_1.visible = true
		enemy_1.visible = true
		player_2.visible = true
		enemy_2.visible = true
		player_3.visible = true
		enemy_3.visible = true
		player_4.visible = true
		enemy_4.visible = true
		player_5.visible = true
		enemy_5.visible = true
		player_6.visible = true
		enemy_6.visible = true

func setPokemonSprite():
	# Set player Pokémon sprites
	var player_sprite_nodes = [player_1, player_2, player_3, player_4, player_5, player_6]
	for i in range(player_sprite_nodes.size()):
		var sprite_node = player_sprite_nodes[i]
		if i < player_pokemon.size():
			var poke = player_pokemon[i]
			var tex = null
			if poke.has("PokemonBackSprite") and poke["PokemonBackSprite"]:
				if typeof(poke["PokemonBackSprite"]) == TYPE_STRING:
					tex = load(poke["PokemonBackSprite"])
				else:
					tex = poke["PokemonBackSprite"]
			elif poke.has("pokemon_back_sprite") and poke["pokemon_back_sprite"]:
				if typeof(poke["pokemon_back_sprite"]) == TYPE_STRING:
					tex = load(poke["pokemon_back_sprite"])
				else:
					tex = poke["pokemon_back_sprite"]
			sprite_node.texture = tex
		else:
			sprite_node.texture = null

	# Set enemy Pokémon sprites
	var enemy_sprite_nodes = [enemy_1, enemy_2, enemy_3, enemy_4, enemy_5, enemy_6]
	for i in range(enemy_sprite_nodes.size()):
		var sprite_node = enemy_sprite_nodes[i]
		if i < enemy_pokemon.size():
			var poke = enemy_pokemon[i]
			var tex = null
			if poke.has("PokemonFrontSprite") and poke["PokemonFrontSprite"]:
				if typeof(poke["PokemonFrontSprite"]) == TYPE_STRING:
					tex = load(poke["PokemonFrontSprite"])
				else:
					tex = poke["PokemonFrontSprite"]
			elif poke.has("pokemon_front_sprite") and poke["pokemon_front_sprite"]:
				if typeof(poke["pokemon_front_sprite"]) == TYPE_STRING:
					tex = load(poke["pokemon_front_sprite"])
				else:
					tex = poke["pokemon_front_sprite"]
			sprite_node.texture = tex
		else:
			sprite_node.texture = null

func signalManager():
	var _Interaction = null
	if Engine.has_singleton("Interaction"):
		_Interaction = Engine.get_singleton("Interaction")
	elif has_node("/root/Interaction"):
		_Interaction = get_node("/root/Interaction")
	if _Interaction and not _Interaction.is_connected("request_ready_to_fight", Callable(self, "readyToFight")):
		_Interaction.connect("request_ready_to_fight", Callable(self, "readyToFight"))
	TextManager.connect("playerShoutoutQueue", Callable(self, "_playerShoutoutQueue"))
	TextManager.connect("playerShoutoutDone", Callable(self, "_playerShoutoutDone"))
	TextManager.connect("enemyShoutoutQueue", Callable(self, "_enemyShoutoutQueue"))
	TextManager.connect("enemyShoutoutDone", Callable(self, "_enemyShoutoutDone"))
	add_to_group("BattleUI")
	if StateManager.has_signal("switchedToPM2"):
		StateManager.connect("switchedToPM2", Callable(self, "_on_switchedToPM2"))

#endregion

func getBattlePokemon():
	# Fetch the current active Pokémon for both player and enemy using the new party system
	var battle_logic = null
	if has_node("/root/BattleLogic"):
		battle_logic = get_node("/root/BattleLogic")
	if battle_logic and battle_logic.has_method("get_first_pokemon"):
		@warning_ignore("shadowed_variable")
		var pokemon = battle_logic.get_first_pokemon()
		player_pokemon = pokemon.get("player", [])
		enemy_pokemon = pokemon.get("enemy", [])
