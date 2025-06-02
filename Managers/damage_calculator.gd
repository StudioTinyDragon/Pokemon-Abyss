extends Node

# Type effectiveness chart and loader
var type_chart = {}
var type_chart_loaded = false

# Loads the type effectiveness chart from EffectiveChart.txt into a nested dictionary
func load_type_chart():
	if type_chart_loaded:
		return
	var file = FileAccess.open("res://Managers/EffectiveChart.txt", FileAccess.READ)
	if not file:
		print("[TypeChart] Could not open EffectiveChart.txt!")
		return
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.begins_with("#") and "x" in line and "=" in line:
			# Example: # Fire   x Grass = 2x
			var parts = line.substr(1).strip_edges().split("=")
			if parts.size() != 2:
				continue
			var left = parts[0].strip_edges()
			var right = parts[1].strip_edges()
			var left_parts = left.split("x")
			if left_parts.size() != 2:
				continue
			var attacker = left_parts[0].strip_edges()
			var defender = left_parts[1].strip_edges()
			var multiplier = right.replace("x", "").to_float()
			if not type_chart.has(attacker):
				type_chart[attacker] = {}
			type_chart[attacker][defender] = multiplier
	file.close()
	type_chart_loaded = true

# Returns the total type effectiveness multiplier for given attacker and defender types
func get_type_multiplier(attacker_types: Array, defender_types: Array) -> float:
	load_type_chart()
	var multiplier = 1.0
	for atk_type in attacker_types:
		if not type_chart.has(atk_type):
			continue
		for def_type in defender_types:
			var m = type_chart[atk_type].get(def_type, 1.0)
			multiplier *= m
	return multiplier

func calculate_damage(level: int, move_power: int, attack: int, defense: int) -> int:
	var damage = (((((2.0 * level) / 5.0) + 2.0) * move_power * attack / defense) / 50.0) + 2.0
	return int(damage)

func calculate_accuracy(moveAccuracy: int, pokemonAccuracy: int, evasion: int):
	var hitChance = (moveAccuracy * pokemonAccuracy / 100) - evasion
	return int(hitChance)

func calculate_move_damage(attacker, defender, move) -> int:
	# attacker: instance of the attacking Pokémon
	# defender: instance of the defending Pokémon
	# move: instance of the move (e.g., Pound)
	var move_power = move.movePower
	var level = attacker.currentLevel
	var attack = attacker.currentAttack
	var defense = defender.currentDefense
	var base_damage = calculate_damage(level, move_power, attack, defense)
	# Get types
	var move_types = []
	if "moveType" in move:
		if typeof(move.moveType) == TYPE_ARRAY:
			move_types = move.moveType
		else:
			move_types = [move.moveType]
	var defender_types = []
	if "TYP" in defender:
		defender_types = defender.TYP
	else:
		defender_types = []
	var type_multiplier = get_type_multiplier(move_types, defender_types)
	# STAB (Same Type Attack Bonus): if attacker has any type matching move type, increase by 1.5x
	var stab = 1.0
	if "TYP" in attacker:
		for t in move_types:
			if t in attacker.TYP:
				stab = 1.5
				break
	return int(base_damage * type_multiplier * stab)

func calculate_special_move_damage(attacker, defender, move) -> int:
	# attacker: instance of the attacking Pokémon
	# defender: instance of the defending Pokémon
	# move: instance of the move (e.g., a special move)
	var move_power = move.movePower
	var level = attacker.currentLevel
	var sp_attack = attacker.currentSPAttack
	var sp_defense = defender.currentSPDefense
	var base_damage = calculate_damage(level, move_power, sp_attack, sp_defense)
	# Get types
	var move_types = []
	if "moveType" in move:
		if typeof(move.moveType) == TYPE_ARRAY:
			move_types = move.moveType
		else:
			move_types = [move.moveType]
	var defender_types = []
	if "TYP" in defender:
		defender_types = defender.TYP
	else:
		defender_types = []
	var type_multiplier = get_type_multiplier(move_types, defender_types)
	# STAB (Same Type Attack Bonus): if attacker has any type matching move type, increase by 1.5x
	var stab = 1.0
	if "TYP" in attacker:
		for t in move_types:
			if t in attacker.TYP:
				stab = 1.5
				break
	return int(base_damage * type_multiplier * stab)
