extends Control

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
	var move_script_name = player_move_name.replace(" ", "")
	var player_move_path = "res://Scripts/Moves/%s.gd" % move_script_name
	if ResourceLoader.exists(player_move_path):
		var move_resource = load(player_move_path)
		player_move_instance = move_resource.new()
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
				if enemy_pokemon.Move1PP > 0 and enemy_pokemon.currentMoves.size() > 0:
					available_moves.append({"name": enemy_pokemon.currentMoves[0], "slot": 1})
				if enemy_pokemon.Move2PP > 0 and enemy_pokemon.currentMoves.size() > 1:
					available_moves.append({"name": enemy_pokemon.currentMoves[1], "slot": 2})
				if enemy_pokemon.Move3PP > 0 and enemy_pokemon.currentMoves.size() > 2:
					available_moves.append({"name": enemy_pokemon.currentMoves[2], "slot": 3})
				if enemy_pokemon.Move4PP > 0 and enemy_pokemon.currentMoves.size() > 3:
					available_moves.append({"name": enemy_pokemon.currentMoves[3], "slot": 4})
				if available_moves.size() > 0:
					var idx = randi() % available_moves.size()
					enemy_move_name = available_moves[idx]["name"]
					var enemy_move_path = "res://Scripts/Moves/%s.gd" % enemy_move_name
					if ResourceLoader.exists(enemy_move_path):
						var move_resource = load(enemy_move_path)
						enemy_move_instance = move_resource.new()
						match available_moves[idx]["slot"]:
							1:
								enemy_pokemon.Move1PP = max(0, enemy_pokemon.Move1PP - 1)
							2:
								enemy_pokemon.Move2PP = max(0, enemy_pokemon.Move2PP - 1)
							3:
								enemy_pokemon.Move3PP = max(0, enemy_pokemon.Move3PP - 1)
							4:
								enemy_pokemon.Move4PP = max(0, enemy_pokemon.Move4PP - 1)
	_last_enemy_move_name = enemy_move_name

	var damage_calculator = get_node("/root").get("damage_calculator") if has_node("/root/damage_calculator") else preload("res://Managers/damage_calculator.gd").new()
	var player_initiative = player_pokemon.currentInitiative if player_pokemon else 0
	var enemy_initiative = enemy_pokemon.currentInitiative if enemy_pokemon else 0
	print("[DEBUG] Player move:", player_move_name, "Enemy move:", enemy_move_name)

	# --- Simpler flinch system ---
	if player_move_instance and enemy_move_instance:
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
	elif player_move_instance:
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
	if move_instance.flinchChance > 0:
		var flinch_roll = randi() % 100 + 1
		if flinch_roll <= move_instance.flinchChance:
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
		battle_text.text = "%s used %s!" % [mon_name, move_name]
	await get_tree().create_timer(1.0).timeout
	TextManager.emit_signal("enemyShoutoutDone")

func _enemyShoutoutDone():
	pass

func _on_move_go_back_pressed() -> void:
	battle_options.visible = true
	move_options.visible = false
