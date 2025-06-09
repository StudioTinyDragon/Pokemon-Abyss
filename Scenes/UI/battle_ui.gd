extends Control

func _get_move_name(move_entry):
	if typeof(move_entry) == TYPE_STRING:
		return move_entry
	elif typeof(move_entry) == TYPE_OBJECT and move_entry is PackedScene:
		var path = move_entry.resource_path
		if path != "":
			var move_name = path.get_file().get_basename()
			return move_name
	elif typeof(move_entry) == TYPE_STRING_NAME:
		return str(move_entry)
	return ""

@onready var battle_options: Panel = $BattleOptions
@onready var battle_button: Button = $BattleOptions/battleButton
@onready var button_2: Button = $BattleOptions/Button2
@onready var button_3: Button = $BattleOptions/Button3
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
@onready var own_statblock: Panel = $OwnStatblock
@onready var pokemon_name: Label = $OwnStatblock/PokemonName
@onready var current_pokemon_hp: Label = $OwnStatblock/CurrentPokemonHP
@onready var current_pokemon_status: Label = $OwnStatblock/CurrentPokemonStatus
@onready var battle_dialogue_box: Panel = $battleDialogueBox
@onready var battle_text: RichTextLabel = $battleDialogueBox/battleText
@onready var ready_to_fight_timer: Timer = $battleDialogueBox/readyToFightTimer
@onready var attack_shoutout_timer: Timer = $battleDialogueBox/attackShoutoutTimer
@onready var enemy_level: Label = $EnemyStatblock/EnemyLevel
@onready var own_level: Label = $OwnStatblock/OwnLevel
@onready var enemy_gender_sprite: Sprite2D = $EnemyStatblock/GenderPanel/EnemyGenderSprite
@onready var player_gender_sprite: Sprite2D = $OwnStatblock/GenderPanel/PlayerGenderSprite
@onready var held_item_icon_player: Sprite2D = $OwnStatblock/heldItemPlayer/heldItemIconPlayer
@onready var held_item_label_player: Label = $OwnStatblock/heldItemPlayer/heldItemLabelPlayer
@onready var held_item_icon_enemy: Sprite2D = $EnemyStatblock/heldItemEnemy/heldItemIconEnemy
@onready var held_item_label_enemy: Label = $EnemyStatblock/heldItemEnemy/heldItemLabelEnemy
@onready var nature_label_enemy: Label = $EnemyStatblock/nature/natureLabelEnemy
@onready var ability_label_enemy: Label = $EnemyStatblock/ablility/abilityLabelEnemy
@onready var nature_label_player: Label = $OwnStatblock/nature/natureLabelPlayer
@onready var ability_label_player: Label = $OwnStatblock/ablility/abilityLabelPlayer



const FEMALE_SIGN = preload("res://Assets/Icons/FemaleSign.png")
const MALE_SIGN = preload("res://Assets/Icons/MaleSign.png")

var _last_enemy_move_name: String = ""
var _last_player_move_name: String = ""
var _battle_started := false
var player_pokemon = null
var enemy_pokemon = null
var enemyMaxHP
var playerMaxHP
var test_battle = get_parent()
var pokemon
var EnemyCurrentHP
var PlayerCurrentHP

# Shows a message in the battle dialogue box
func show_battle_message(msg: String) -> void:
	if battle_dialogue_box:
		battle_dialogue_box.visible = true
	if battle_text:
		battle_text.text = msg

func _ready() -> void:
	# Connect the battle start signal ONCE, and only here
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

#region timer


func readyToFight():
	if _battle_started:
		return
	_battle_started = true
	battle_dialogue_box.visible = true
	battle_options.visible = false
	battle_text.text = "It's time to fight"
	# Fetch Pokémon data from parent TestBattle
	test_battle = get_parent()
	if test_battle and test_battle.has_method("_get_battle_pokemon"):
		pokemon = test_battle._get_battle_pokemon()
		player_pokemon = pokemon.get("player", null)
		enemy_pokemon = pokemon.get("enemy", null)
	getBattlePokemon()
	showPokemonNames()
	setPokemonPosition()

	if test_battle and test_battle.has_method("_get_battle_pokemon"):
		pokemon = test_battle._get_battle_pokemon()
		player_pokemon = pokemon.get("player", null)
		enemy_pokemon = pokemon.get("enemy", null)
	ready_to_fight_timer.start()
	current_enemy_hp.text = str(EnemyCurrentHP, " / ", enemyMaxHP)
	current_pokemon_hp.text = str(PlayerCurrentHP, " / ", playerMaxHP)
	if own_level and player_pokemon and "currentLevel" in player_pokemon:
		own_level.text = str(int(player_pokemon.currentLevel))
	if enemy_level and enemy_pokemon and "currentLevel" in enemy_pokemon:
		enemy_level.text = str(int(enemy_pokemon.currentLevel))
	
	# Set gender icons for player and enemy
	_set_gender_sprite(player_pokemon, player_gender_sprite)
	_set_gender_sprite(enemy_pokemon, enemy_gender_sprite)
	
	_set_held_item(player_pokemon, held_item_label_player)
	_set_held_item(enemy_pokemon, held_item_label_enemy)
	
	
	_set_ability_label(player_pokemon, ability_label_player)
	_set_ability_label(enemy_pokemon, ability_label_enemy)
	
	_set_nature_label(player_pokemon, nature_label_player)
	_set_nature_label(enemy_pokemon, nature_label_enemy)
	
	await get_tree().process_frame  # Wait one frame for everything to initialize
	print("[DEBUG] At battle start: enemy_pokemon.currentMoves =", enemy_pokemon.currentMoves)
	print("[DEBUG] At battle start: enemy_pokemon Move1PP-4PP =", enemy_pokemon.Move1PP, enemy_pokemon.Move2PP, enemy_pokemon.Move3PP, enemy_pokemon.Move4PP)

func _on_ready_to_fight_timer_timeout() -> void:
	battle_dialogue_box.visible = false
	battle_text.text = ""
	battle_options.visible = true
	enemy_statblock.visible = true
	own_statblock.visible = true



#endregion

#region names


func showPokemonNames():
	if player_pokemon and "Name" in player_pokemon:
		pokemon_name.text = str(player_pokemon.Name)
	else:
		pokemon_name.text = "aa"
	if enemy_pokemon and "Name" in enemy_pokemon:
		enemy_name.text = str(enemy_pokemon.Name)
	else:
		enemy_name.text = "-"

func setPokemonPosition():
	var player_battle_pos = Vector2(StateManager.player_position.x - 125, StateManager.player_position.y - 15)
	var enemy_battle_pos = Vector2(StateManager.player_position.x + 120, StateManager.player_position.y - 35)

	if player_pokemon:
		player_pokemon.global_position = player_battle_pos
		if player_pokemon.has_node("PokemonBackSprite"):
			var back_sprite = player_pokemon.get_node("PokemonBackSprite")
			back_sprite.visible = true
			back_sprite.scale = Vector2(2.0, 2.0)
		if player_pokemon.has_node("PokemonFrontSprite"):
			player_pokemon.get_node("PokemonFrontSprite").visible = false

	if enemy_pokemon:
		enemy_pokemon.global_position = enemy_battle_pos
		if enemy_pokemon.has_node("PokemonFrontSprite"):
			var front_sprite = enemy_pokemon.get_node("PokemonFrontSprite")
			front_sprite.visible = true
			front_sprite.scale = Vector2(0.8, 0.8)
		if enemy_pokemon.has_node("PokemonBackSprite"):
			enemy_pokemon.get_node("PokemonBackSprite").visible = false


#endregion



func getBattlePokemon():
	if test_battle and test_battle.has_method("_get_battle_pokemon"):
		pokemon = test_battle._get_battle_pokemon()
		player_pokemon = pokemon.get("player", null)
		enemy_pokemon = pokemon.get("enemy", null)
	if enemy_pokemon and "currentHP" in enemy_pokemon:
		EnemyCurrentHP = enemy_pokemon.currentHP
	if player_pokemon and "currentHP" in player_pokemon:
		PlayerCurrentHP = player_pokemon.currentHP
	if enemy_pokemon and "currentMaxHP" in enemy_pokemon:
		enemyMaxHP = enemy_pokemon.currentMaxHP
	if player_pokemon and "currentMaxHP" in player_pokemon:
		playerMaxHP = player_pokemon.currentMaxHP

	# Set status effect labels for player and enemy
	if current_pokemon_status and player_pokemon:
		current_pokemon_status.text = _get_status_text(player_pokemon)
	if current_enemy_status and enemy_pokemon:
		current_enemy_status.text = _get_status_text(enemy_pokemon)



func _on_battle_button_pressed() -> void:
	battle_options.visible = false
	move_options.visible = true

	# Set move button text to moves from StateManager.player_party[0]
	if StateManager.player_party.size() > 0:
		var moves = StateManager.player_party[0]["moves"]
		if moves.size() > 0:
			move_1_button.text = moves[0]["name"] + " (" + str(moves[0]["pp"]) + "/" + str(moves[0]["max_pp"]) + ")"
		else:
			move_1_button.text = "-"
		if moves.size() > 1:
			move_2_button.text = moves[1]["name"] + " (" + str(moves[1]["pp"]) + "/" + str(moves[1]["max_pp"]) + ")"
		else:
			move_2_button.text = "-"
		if moves.size() > 2:
			move_3_button.text = moves[2]["name"] + " (" + str(moves[2]["pp"]) + "/" + str(moves[2]["max_pp"]) + ")"
		else:
			move_3_button.text = "-"
		if moves.size() > 3:
			move_4_button.text = moves[3]["name"] + " (" + str(moves[3]["pp"]) + "/" + str(moves[3]["max_pp"]) + ")"
		else:
			move_4_button.text = "-"
	else:
		move_1_button.text = "-"
		move_2_button.text = "-"
		move_3_button.text = "-"
		move_4_button.text = "-"

	# Output enemy HP in the console (optional debug)
	if enemy_pokemon and "currentHP" in enemy_pokemon:
		print("Enemy HP:", enemy_pokemon.currentHP)

func _on_move_1_button_pressed() -> void:
	_handle_move_button(0)

func _on_move_2_button_pressed() -> void:
	_handle_move_button(1)

func _on_move_3_button_pressed() -> void:
	_handle_move_button(2)

func _on_move_4_button_pressed() -> void:
	_handle_move_button(3)


func _handle_move_button(move_index: int) -> void:
	if StateManager.player_party.size() == 0:
		return
	var moves = StateManager.player_party[0]["moves"]
	if moves.size() <= move_index or moves[move_index]["pp"] <= 0:
		return
	var player_move_name = moves[move_index]["name"]
	_last_player_move_name = player_move_name
	var player_move_instance = null
	var move_scene_name = player_move_name.replace(" ", "")
	var move_scene_path = "res://Scripts/Moves/%s.tscn" % move_scene_name
	if ResourceLoader.exists(move_scene_path):
		var move_scene = load(move_scene_path)
		player_move_instance = move_scene.instantiate()
	print("[DEBUG] Before decrement: %s" % [str(moves)])
	moves[move_index]["pp"] = max(0, moves[move_index]["pp"] - 1)
	print("[DEBUG] After decrement: %s" % [str(moves)])
	refresh_move_buttons()

	if enemy_pokemon:
		enemy_pokemon.checkIfStruggle()
	var enemy_is_struggling = enemy_pokemon and enemy_pokemon.isStruggling
	var enemy_move_name = null
	var enemy_move_instance = null
	if enemy_pokemon:
		if enemy_is_struggling:
			enemy_move_name = "Struggle"
			var struggle_path = "res://Scripts/Moves/struggle.gd"
			if ResourceLoader.exists(struggle_path):
				var move_resource = load(struggle_path)
				enemy_move_instance = move_resource.new()
		else:
			var all_pp_zero = true
			var move_pps = [enemy_pokemon.Move1PP, enemy_pokemon.Move2PP, enemy_pokemon.Move3PP, enemy_pokemon.Move4PP]
			for pp in move_pps:
				if pp > 0:
					all_pp_zero = false
					break
			if all_pp_zero:
				enemy_move_name = "Struggle"
				var struggle_path = "res://Scripts/Moves/struggle.gd"
				if ResourceLoader.exists(struggle_path):
					var move_resource = load(struggle_path)
					enemy_move_instance = move_resource.new()
			else:
				var available_moves = []
				print("[DEBUG] enemy_pokemon.currentMoves:", enemy_pokemon.currentMoves)
				print("[DEBUG] enemy_pokemon Move1PP-4PP:", enemy_pokemon.Move1PP, enemy_pokemon.Move2PP, enemy_pokemon.Move3PP, enemy_pokemon.Move4PP)
				if enemy_pokemon.Move1PP > 0 and enemy_pokemon.currentMoves.size() > 0:
					var move1_name = _get_move_name(enemy_pokemon.currentMoves[0])
					print("[DEBUG] Move1 candidate:", move1_name)
					available_moves.append({"name": move1_name, "slot": 1})
				if enemy_pokemon.Move2PP > 0 and enemy_pokemon.currentMoves.size() > 1:
					var move2_name = _get_move_name(enemy_pokemon.currentMoves[1])
					print("[DEBUG] Move2 candidate:", move2_name)
					available_moves.append({"name": move2_name, "slot": 2})
				if enemy_pokemon.Move3PP > 0 and enemy_pokemon.currentMoves.size() > 2:
					var move3_name = _get_move_name(enemy_pokemon.currentMoves[2])
					print("[DEBUG] Move3 candidate:", move3_name)
					available_moves.append({"name": move3_name, "slot": 3})
				if enemy_pokemon.Move4PP > 0 and enemy_pokemon.currentMoves.size() > 3:
					var move4_name = _get_move_name(enemy_pokemon.currentMoves[3])
					print("[DEBUG] Move4 candidate:", move4_name)
					available_moves.append({"name": move4_name, "slot": 4})
				print("[DEBUG] available_moves:", available_moves)
				if available_moves.size() > 0:
					var idx = randi() % available_moves.size()
					enemy_move_name = available_moves[idx]["name"]
					print("[DEBUG] Chosen enemy_move_name:", enemy_move_name)
					var enemy_move_scene_path = "res://Scripts/Moves/%s.tscn" % enemy_move_name
					print("[DEBUG] enemy_move_scene_path:", enemy_move_scene_path)
					if ResourceLoader.exists(enemy_move_scene_path):
						var move_scene = load(enemy_move_scene_path)
						enemy_move_instance = move_scene.instantiate()
						print("[DEBUG] Instantiated enemy_move_instance:", enemy_move_instance)
						# Decrement PP for the used move
						match available_moves[idx]["slot"]:
							1:
								enemy_pokemon.Move1PP = max(0, enemy_pokemon.Move1PP - 1)
							2:
								enemy_pokemon.Move2PP = max(0, enemy_pokemon.Move2PP - 1)
							3:
								enemy_pokemon.Move3PP = max(0, enemy_pokemon.Move3PP - 1)
							4:
								enemy_pokemon.Move4PP = max(0, enemy_pokemon.Move4PP - 1)
					else:
						print("[DEBUG] Move scene does not exist for:", enemy_move_scene_path)
	_last_enemy_move_name = enemy_move_name

	var damage_calculator = get_node("/root").get("damage_calculator") if has_node("/root/damage_calculator") else preload("res://Managers/damage_calculator.gd").new()
	var player_initiative = player_pokemon.currentInitiative if player_pokemon else 0
	var enemy_initiative = enemy_pokemon.currentInitiative if enemy_pokemon else 0

	# --- PrioMove/Initiative system ---
	if player_move_instance and enemy_move_instance:
		var player_prio = 0
		var enemy_prio = 0
		if "PrioMove" in player_move_instance:
			player_prio = player_move_instance.PrioMove
		if "PrioMove" in enemy_move_instance:
			enemy_prio = enemy_move_instance.PrioMove
		print("[DEBUG] Player move:", player_move_name, "PrioMove:", player_prio, "Enemy move:", enemy_move_name, "PrioMove:", enemy_prio)

		# If both PrioMove == 0, use initiative
		if player_prio == 0 and enemy_prio == 0:
			print("[DEBUG] Both moves PrioMove == 0, using initiative.")
			if player_initiative > enemy_initiative:
				# Player goes first
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone
			elif enemy_initiative > player_initiative:
				# Enemy goes first
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
			else:
				# Initiative tie: player first, then enemy
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone

		# If one or both PrioMove > 0, higher PrioMove goes first
		elif player_prio > 0 or enemy_prio > 0:
			print("[DEBUG] At least one move has PrioMove > 0, higher PrioMove goes first.")
			if player_prio > enemy_prio:
				# Player goes first
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone
			elif enemy_prio > player_prio:
				# Enemy goes first
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
			else:
				# PrioMove tie, player first
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone

		# If one or both PrioMove < 0, lower PrioMove goes last
		elif player_prio < 0 or enemy_prio < 0:
			print("[DEBUG] At least one move has PrioMove < 0, lower PrioMove goes last.")
			if player_prio < enemy_prio:
				# Enemy goes first (player's PrioMove is lower)
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
			elif enemy_prio < player_prio:
				# Player goes first (enemy's PrioMove is lower)
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone
			else:
				# PrioMove tie, player first
				if player_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % player_pokemon.Name)
					player_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, true, false)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("playerShoutoutQueue")
					await TextManager.playerShoutoutDone
				if enemy_pokemon.flinched:
					show_battle_message("%s flinched and couldn't move!" % enemy_pokemon.Name)
					enemy_pokemon.flinched = false
					await get_tree().create_timer(1.0).timeout
				else:
					execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, false, true)
					await get_tree().create_timer(0.1).timeout
					TextManager.emit_signal("enemyShoutoutQueue")
					await TextManager.enemyShoutoutDone
	else:
		# Only one move present
		if player_move_instance:
			execute_move(player_pokemon, enemy_pokemon, player_move_instance, player_move_name, damage_calculator, true, false)
			await get_tree().create_timer(0.1).timeout
			TextManager.emit_signal("playerShoutoutQueue")
			await TextManager.playerShoutoutDone
		elif enemy_move_instance:
			execute_move(enemy_pokemon, player_pokemon, enemy_move_instance, enemy_move_name, damage_calculator, true, false)
			await get_tree().create_timer(0.1).timeout
			TextManager.emit_signal("enemyShoutoutQueue")
			await TextManager.enemyShoutoutDone
		else:
			print("No valid moves to execute.")
	# After all shoutouts, hide the message box and show battle options
	if battle_dialogue_box:
		battle_dialogue_box.visible = false
	if battle_text:
		battle_text.text = ""
	battle_options.visible = true
	enemy_statblock.visible = true
	own_statblock.visible = true
	refresh_move_buttons()


func execute_move(attacker, defender, move_instance, move_name, damage_calculator, _is_first_attacker := false, _is_second_attacker := false):
	move_options.visible = false
	var _effectiveness = 1.0
	if move_instance and defender and "TYP" in defender:
		var move_types = []
		if typeof(move_instance.moveType) == TYPE_ARRAY:
			move_types = move_instance.moveType
		else:
			move_types = [move_instance.moveType]
		var defender_types = defender.TYP
		if has_node("/root/damage_calculator"):
			var dc = get_node("/root/damage_calculator")
			_effectiveness = dc.get_type_multiplier(move_types, defender_types)
	var _status_msg = ""
	print("[DEBUG] execute_move: attacker=%s, defender=%s, move_name=%s, moveCat=%s" % [attacker.Name if attacker else "None", defender.Name if defender else "None", move_name, move_instance.moveCat if move_instance else "None"])
	# Handle Status moves (like Tail Whip) separately
	if move_instance.moveCat == "Status":
			# Set status effect labels for player and enemy
		if current_pokemon_status and player_pokemon:
			current_pokemon_status.text = _get_status_text(player_pokemon)
		if current_enemy_status and enemy_pokemon:
			current_enemy_status.text = _get_status_text(enemy_pokemon)
		if move_instance.has_method("DebuffEnenmyDefensex1"):
			if attacker.is_in_group("player_pokemon") and defender != attacker and defender.has_method("set_stat") and defender.has_method("get_stat") and defender.is_in_group("enemy_pokemon"):
				move_instance.DebuffEnenmyDefensex1(defender)
			elif attacker.is_in_group("enemy_pokemon") and defender != attacker and defender.has_method("set_stat") and defender.has_method("get_stat") and defender.is_in_group("player_pokemon"):
				move_instance.DebuffEnenmyDefensex1(defender)
			else:
				print("[Tail Whip] No valid enemy target for debuff. Defender: ", defender)
		else:
			print("Status move %s has no effect function implemented." % move_name)
		return

	# --- Accuracy check ---
	var move_accuracy = move_instance.moveAccuracy if "moveAccuracy" in move_instance else 100
	var attacker_accuracy = attacker.pokemonAccuracy if "pokemonAccuracy" in attacker else 100
	var defender_evasion = defender.evasion if "evasion" in defender else 0
	var hit_chance = damage_calculator.calculate_accuracy(move_accuracy, attacker_accuracy, defender_evasion)
	var roll = randi() % 100 + 1 # 1-100
	if roll > hit_chance:
		# Missed!
		if attacker.is_in_group("player_pokemon"):
			_last_player_move_name = move_name + " (missed)"
		elif attacker.is_in_group("enemy_pokemon"):
			_last_enemy_move_name = move_name + " (missed)"
		print("[Battle] %s's %s missed! (roll=%d, hit_chance=%.2f)" % [attacker.Name, move_name, roll, hit_chance])
		return

	# --- Flinch check (only for damaging moves with flinch chance) ---
	if move_instance.flinchChance > 0 and move_instance.has_method("try_flinch_opponent"):
		if move_instance.try_flinch_opponent():
			defender.flinched = true
			print("[Battle] %s flinched!" % defender.Name)

	var damage = 0
	if move_instance.moveCat == "Physical":
		damage = damage_calculator.calculate_move_damage(attacker, defender, move_instance)
	elif move_instance.moveCat == "Special":
		damage = damage_calculator.calculate_special_move_damage(attacker, defender, move_instance)
	else:
		print("Move category not supported for damage calculation.")
	if "currentHP" in defender:
		defender.currentHP = max(0, defender.currentHP - damage)
		# Sync HP to party dictionary if this is a player Pokémon
		if defender.has_method("is_in_group") and defender.is_in_group("player_pokemon") and "uniquePokemonID" in defender:
			StateManager.update_pokemon_field(defender.uniquePokemonID, "current_hp", defender.currentHP)
		# HP UI update (not part of shoutout system)
		if attacker.has_method("is_in_group") and attacker.is_in_group("player_pokemon"):
			current_pokemon_hp.text = str(attacker.currentHP, " / ", attacker.currentMaxHP)
			current_enemy_hp.text = str(defender.currentHP, " / ", defender.currentMaxHP)
		elif defender.has_method("is_in_group") and defender.is_in_group("player_pokemon"):
			current_pokemon_hp.text = str(defender.currentHP, " / ", defender.currentMaxHP)
			current_enemy_hp.text = str(attacker.currentHP, " / ", attacker.currentMaxHP)
		if attacker.has_method("is_in_group") and attacker.is_in_group("enemy_pokemon"):
			current_enemy_hp.text = str(attacker.currentHP, " / ", attacker.currentMaxHP)
			current_pokemon_hp.text = str(defender.currentHP, " / ", defender.currentMaxHP)
		elif defender.has_method("is_in_group") and defender.is_in_group("enemy_pokemon"):
			current_enemy_hp.text = str(defender.currentHP, " / ", defender.currentMaxHP)
			current_pokemon_hp.text = str(attacker.currentHP, " / ", attacker.currentMaxHP)
		# Apply Struggle recoil if move is Struggle
		if move_name == "Struggle" and move_instance.has_method("RecoilDamage"):
			move_instance.RecoilDamage(attacker)
			current_pokemon_hp.text = str(attacker.currentHP, " / ", attacker.currentMaxHP)
			current_enemy_hp.text = str(defender.currentHP, " / ", defender.currentMaxHP)
	else:
		print("No valid defender HP.")


func refresh_move_buttons() -> void:
	if StateManager.player_party.size() > 0:
		var moves = StateManager.player_party[0]["moves"]
		if moves.size() > 0:
			move_1_button.text = moves[0]["name"] + " (" + str(moves[0]["pp"]) + "/" + str(moves[0]["max_pp"]) + ")"
		else:
			move_1_button.text = "-"
		if moves.size() > 1:
			move_2_button.text = moves[1]["name"] + " (" + str(moves[1]["pp"]) + "/" + str(moves[1]["max_pp"]) + ")"
		else:
			move_2_button.text = "-"
		if moves.size() > 2:
			move_3_button.text = moves[2]["name"] + " (" + str(moves[2]["pp"]) + "/" + str(moves[2]["max_pp"]) + ")"
		else:
			move_3_button.text = "-"
		if moves.size() > 3:
			move_4_button.text = moves[3]["name"] + " (" + str(moves[3]["pp"]) + "/" + str(moves[3]["max_pp"]) + ")"
		else:
			move_4_button.text = "-"
	else:
		move_1_button.text = "-"
		move_2_button.text = "-"
		move_3_button.text = "-"
		move_4_button.text = "-"


func _on_flee_button_pressed():
	battle_options.visible = false
	move_options.visible = false
	enemy_statblock.visible = false
	own_statblock.visible = false
	_battle_started = false
	player_pokemon.get_node("PokemonBackSprite").visible = false
	enemy_pokemon.get_node("PokemonFrontSprite").visible = false
	StateManager.emit_signal("player_fled_battle")


func _playerShoutoutQueue():
	if battle_dialogue_box:
		battle_dialogue_box.visible = true
	if battle_text:
		var mon_name = player_pokemon.Name if player_pokemon and "Name" in player_pokemon else "Player Pokémon"
		var move_name = _last_player_move_name if _last_player_move_name != null else "Move"
		battle_text.text = "Your %s used %s!" % [mon_name, move_name]
	await get_tree().create_timer(1.0).timeout
	TextManager.emit_signal("playerShoutoutDone")

func _playerShoutoutDone():
	pass

func _enemyShoutoutQueue():
	if battle_dialogue_box:
		battle_dialogue_box.visible = true
	if battle_text:
		var mon_name = enemy_pokemon.Name if enemy_pokemon and "Name" in enemy_pokemon else "Enemy Pokémon"
		var move_name = _last_enemy_move_name if _last_enemy_move_name != null else "Move"
		battle_text.text = "Enemy %s used %s!" % [mon_name, move_name]
	await get_tree().create_timer(1.0).timeout
	TextManager.emit_signal("enemyShoutoutDone")

func _enemyShoutoutDone():
	pass

# Set gender icons for player and enemy
@warning_ignore("shadowed_variable")
func _set_gender_sprite(pokemon, sprite):
	if not pokemon or not sprite:
		return
	var gender = ""
	# Handle both string and enum/int
	if "Gender" in pokemon:
		gender = str(pokemon.Gender)
	if gender == "Female" or gender == "0":
		sprite.texture = FEMALE_SIGN
	elif gender == "Male" or gender == "1":
		sprite.texture = MALE_SIGN
	else:
		sprite.texture = null

@warning_ignore("shadowed_variable")
func _set_held_item(pokemon, ilabel):
	if not pokemon or not ilabel:
		return
	var heldItem = ""
	if "heldItem" in pokemon:
		heldItem = str(pokemon.heldItem)
	if not heldItem == "":
		#isprite.texture = 
		ilabel.text = heldItem

@warning_ignore("shadowed_variable")
func _set_ability_label(pokemon, label):
	if not pokemon or not label:
		return
	var ability = ""
	if "Ability" in pokemon:
		ability = str(pokemon.Ability)
	if ability != "":
		label.text = ability

@warning_ignore("shadowed_variable")
func _set_nature_label(pokemon, label):
	if not pokemon or not label:
		return
	var nature = ""
	if "Nature" in pokemon:
		nature = str(pokemon.Nature)
	if nature != "":
		label.text = nature

@warning_ignore("shadowed_variable")
func _get_status_text(pokemon) -> String:
	var status_list = []
	# Stat debuffs: check both stat_debuffs in meta and as property
	var debuffs = {}
	if "stat_debuffs" in pokemon:
		debuffs = pokemon.stat_debuffs if typeof(pokemon.stat_debuffs) == TYPE_DICTIONARY else {}
	elif pokemon.has_method("get_meta") and pokemon.has_meta("stat_debuffs"):
		debuffs = pokemon.get_meta("stat_debuffs")
	if "defense" in debuffs and debuffs["defense"] > 0.0:
		status_list.append("DEF↓")
	if "attack" in debuffs and debuffs["attack"] > 0.0:
		status_list.append("ATK↓")
	# Status effects array (e.g. burn, flying, etc.)
	if "StatusEffect" in pokemon and typeof(pokemon.StatusEffect) == TYPE_ARRAY:
		for effect in pokemon.StatusEffect:
			if effect != "none":
				status_list.append(str(effect).capitalize())
	# If nothing, show "OK" or blank
	if status_list.size() == 0:
		return "OK"
	return ", ".join(status_list)
