extends Node

func calculate_damage(level: int, move_power: int, attack: int, defense: int) -> int:
	var damage = (((((2.0 * level) / 5.0) + 2.0) * move_power * attack / defense) / 50.0) + 2.0
	return int(damage)



func calculate_move_damage(attacker, defender, move) -> int:
	# attacker: instance of the attacking Pokémon
	# defender: instance of the defending Pokémon
	# move: instance of the move (e.g., Pound)
	var move_power = move.movePower
	var level = attacker.currentLevel
	var attack = attacker.Attack
	var defense = defender.Defense
	return calculate_damage(level, move_power, attack, defense)

func calculate_special_move_damage(attacker, defender, move) -> int:
	# attacker: instance of the attacking Pokémon
	# defender: instance of the defending Pokémon
	# move: instance of the move (e.g., a special move)
	var move_power = move.movePower
	var level = attacker.currentLevel
	var sp_attack = attacker.SPAttack
	var sp_defense = defender.SPDefense
	return calculate_damage(level, move_power, sp_attack, sp_defense)
