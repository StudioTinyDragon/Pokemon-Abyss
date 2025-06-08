extends Node2D

#region PokemonVars
var move_instances: Array = [] # Stores instantiated move objects

@export_category("Pokemon Info")
@export var Name : String
@export var PokedexNR: int
@export var OwndexNR: int
@export var TYP: Array[String]
@export_enum("Female", "Male") var Gender
@export_enum("Hardy") var Nature
@export var canBeShiny: bool
@export var isShiny: bool
@export var isWild: bool

@export var uniquePokemonID: int

@export var PotentialGenders: Array[String]
@export var PotentialNatures: Array[String]

@export_subgroup("Sprites")
@export_file("*.png") var PokemonFront             = ""
@export_file("*.png") var PokemonBack              = ""
@export_file("*.png") var PokemonIcon              = ""
@export_file("*.png") var PokemonFrontShiny        = ""
@export_file("*.png") var PokemonBackShiny         = ""
@export_file("*.png") var PokemonImage             = ""

#region Evolve Info
@export_subgroup("evolve info")
@export var canEvolve :bool
@export var EvolveLvl :int
@export var EvolveItem :String
@export var EvolveLocation :String
@export var EvolveETC :String

#endregion

#region currentBattleStats

#dynamic stats
var currentHP: int
var Move1PP: int
var Move2PP: int
var Move3PP: int
var Move4PP: int
var StatusEffect: Array[String]   = []
@export_group("Stats")
@export var heldItem: String

@export_range(0, 100, 1.0) var currentLevel
@export var Exp: int
@export var Moves: Array[String]
@export var Ability : String
@export var pokemonAccuracy: int
@export var evasion : int
@export var CatchRate: int

#endregion

# Statblock
#region MinStats
@export_subgroup("Lvl1 Stats")
@export var Lvl1HP: int
@export var Lvl1Attack: int
@export var Lvl1Defense: int
@export var Lvl1SPAttack: int
@export var Lvl1SPDefense: int
@export var Lvl1Initiative: int

#endregion

#region MaxStats
@export_subgroup("Max Lvl Stats")
@export var maxLvlHP: int
@export var maxLvlAttack: int
@export var maxLvlDefense: int
@export var maxLvlSPAttack: int
@export var maxLvlSPDefense: int
@export var maxLvlInitiative: int

#endregion

#region TrainingLvl
@export_subgroup("Training Modifier")
@export var TraingnigHP :int
@export var TraingnigAttack :int
@export var TraingnigDefense :int
@export var TraingnigSPAttack :int
@export var TraingnigSPDefense :int
@export var TraingnigInitiative :int
#TODO TrainingLvl erhöhen können + MaxLvl dafür ( ist schon in der Stat berechnung eingebunden, momentan für 1% Bonus pro TrainingLvl)

#endregion

#region currentStats

var currentMaxHP :int
var currentAttack :int
var currentDefense :int
var currentSPAttack :int
var currentSPDefense :int
var currentInitiative :int

#endregion

@export var currentMoves: Array[String]
@export_subgroup("Potential")
@export var potentialMoves: Array[String]
@export var potentialAbilities: Array[String]
@export var potentialHeldItems: Dictionary

#region MoveLvlLocked
@export_subgroup("Moves per Level")
@export var move_levels = {

}

#endregion

#endregion

#region State

var levelRange: int = 0
var isFainted
var settingMove = false
var isStruggling: bool = false
var flinched = false

#endregion


@onready var pokemon_front_sprite: Sprite2D = $PokemonFrontSprite
@onready var pokemon_back_sprite: Sprite2D = $PokemonBackSprite
@onready var pokemon_icon: Sprite2D = $PokemonIcon
@onready var animated_front: AnimatedSprite2D = $AnimatedFront
@onready var animated_back: AnimatedSprite2D = $AnimatedBack
@onready var pokemon_front_sprite_shiny: Sprite2D = $PokemonFrontSpriteShiny
@onready var pokemon_back_sprite_shiny: Sprite2D = $PokemonBackSpriteShiny
@onready var pokemon_image: Sprite2D = $PokemonImage


func _ready():
	setPokemonSprites()
	_recalculate_stats()
	initializeInspector()
	move_instances.clear()
	call_deferred("instantiate_moves")
	if isWild == true:
		WildGenerator()
		shinyProbabilityGenerator()
		initializeInspector()

# Setter for currentLevel and stat recalculation
func set_currentLevel(val):
	currentLevel = val
	_recalculate_stats()

# Call this after changing any stat-affecting exported var
func _recalculate_stats():
	currentMaxHP = int(((maxLvlHP - Lvl1HP) / 99.0 * (currentLevel - 1.0) + Lvl1HP) * (1 + (0.1 * TraingnigHP)))
	currentAttack = int(((maxLvlAttack - Lvl1Attack) / 99.0 * (currentLevel - 1.0) + Lvl1Attack) * (1 + (0.01 * TraingnigAttack)))
	currentDefense = int(((maxLvlDefense - Lvl1Defense) / 99.0 * (currentLevel - 1.0) + Lvl1Defense) * (1 + (0.01 * TraingnigDefense)))
	currentSPAttack = int(((maxLvlSPAttack - Lvl1SPAttack) / 99.0 * (currentLevel - 1.0) + Lvl1SPAttack) * (1 + (0.01 * TraingnigSPAttack)))
	currentSPDefense = int(((maxLvlSPDefense - Lvl1SPDefense) / 99.0 * (currentLevel - 1.0) + Lvl1SPDefense) * (1 + (0.01 * TraingnigSPDefense)))
	currentInitiative = int(((maxLvlInitiative - Lvl1Initiative) / 99.0 * (currentLevel - 1.0) + Lvl1Initiative) * (1 + (0.01 * TraingnigInitiative)))

func instantiate_moves():
	for move_name in currentMoves:
		var move_scene_path = "res://Scripts/Moves/%s.tscn" % move_name
		if ResourceLoader.exists(move_scene_path):
			var move_scene = load(move_scene_path)
			var move_instance = move_scene.instantiate()
			if move_instance.has_method("initialize_from_inspector"):
				move_instance.initialize_from_inspector()
			move_instances.append(move_instance)
			var prop_names = []
			for p in move_instance.get_property_list():
				prop_names.append(p.name)

func setPokemonSprites():
	animated_front.play()
	if isShiny == true:
		if PokemonFrontShiny != "":
			var FrontShiny = load(PokemonFront)
			if FrontShiny:
				pokemon_front_sprite.texture = FrontShiny
		if PokemonBackShiny != "":
			var BackShiny = load(PokemonBack)
			if BackShiny:
				pokemon_back_sprite.texture = BackShiny
	else:
		if PokemonFront != "":
			var Front = load(PokemonFront)
			if Front:
				pokemon_front_sprite.texture = Front
		if PokemonBack != "":
			var Back = load(PokemonBack)
			if Back:
				pokemon_back_sprite.texture = Back
		if PokemonIcon != "":
			var Icon = load(PokemonIcon)
			if Icon:
				pokemon_icon.texture = Icon

func shinyProbabilityGenerator():
	if randi() % 4000 == 0 && canBeShiny == true:
		isShiny = true
	else:
		isShiny = false

func fainting():
	if currentHP > 0:
		isFainted = false
	elif currentHP <= 0:
		isFainted = true

func SetPotentiellMoves():
	for move in move_levels.keys():
		if currentLevel >= move_levels[move]:
			if not potentialMoves.has(move):
				potentialMoves.append(move)

func SetMoves():
	for move in potentialMoves:
		if not currentMoves.has(move) and currentMoves.size() < 4:
			currentMoves.append(move)
			settingMove = true


# Utility methods for stat manipulation (needed for status moves like Tail Whip)
func _has_exported_property(stat_name: String) -> bool:
	for prop in get_property_list():
		if prop.name == stat_name:
			return true
	return false

func set_stat(stat_name: String, value):
	if _has_exported_property(stat_name):
		self.set(stat_name, value)
	else:
		print("[Kangaskhan] set_stat: Stat not found:", stat_name)

func get_stat(stat_name: String):
	if _has_exported_property(stat_name):
		return self.get(stat_name)
	else:
		print("[Kangaskhan] get_stat: Stat not found:", stat_name)
		return null

func setMove1PP():
	if settingMove == true and currentMoves.size() > 0:
		var move_name = currentMoves[0]
		var move_path = "res://Scripts/Moves/%s.gd" % move_name
		if ResourceLoader.exists(move_path):
			var move_resource = load(move_path)
			var move_instance = move_resource.new()
			var has_max_pp = false
			for prop in move_instance.get_property_list():
				if prop.name == "maxPP":
					has_max_pp = true
					break
			if has_max_pp:
				Move1PP = move_instance.maxPP
			else:
				print("[Kangaskhan] Move script for %s does not have maxPP." % move_name)
		else:
			print("[Kangaskhan] Move script not found for %s" % move_name)


func setMove2PP():
	if settingMove == true and currentMoves.size() > 1:
		var move_name = currentMoves[1]
		var move_path = "res://Scripts/Moves/%s.gd" % move_name
		if ResourceLoader.exists(move_path):
			var move_resource = load(move_path)
			var move_instance = move_resource.new()
			var has_max_pp = false
			for prop in move_instance.get_property_list():
				if prop.name == "maxPP":
					has_max_pp = true
					break
			if has_max_pp:
				Move2PP = move_instance.maxPP
			else:
				print("[Kangaskhan] Move script for %s does not have maxPP." % move_name)
		else:
			print("[Kangaskhan] Move script not found for %s" % move_name)

func setMove3PP():
	if settingMove == true and currentMoves.size() > 2:
		var move_name = currentMoves[2]
		var move_path = "res://Scripts/Moves/%s.gd" % move_name
		if ResourceLoader.exists(move_path):
			var move_resource = load(move_path)
			var move_instance = move_resource.new()
			var has_max_pp = false
			for prop in move_instance.get_property_list():
				if prop.name == "maxPP":
					has_max_pp = true
					break
			if has_max_pp:
				Move3PP = move_instance.maxPP
			else:
				print("[Kangaskhan] Move script for %s does not have maxPP." % move_name)
		else:
			print("[Kangaskhan] Move script not found for %s" % move_name)

func setMove4PP():
	if settingMove == true and currentMoves.size() > 3:
		var move_name = currentMoves[3]
		var move_path = "res://Scripts/Moves/%s.gd" % move_name
		if ResourceLoader.exists(move_path):
			var move_resource = load(move_path)
			var move_instance = move_resource.new()
			var has_max_pp = false
			for prop in move_instance.get_property_list():
				if prop.name == "maxPP":
					has_max_pp = true
					break
			if has_max_pp:
				Move4PP = move_instance.maxPP
			else:
				print("[Kangaskhan] Move script for %s does not have maxPP." % move_name)
		else:
			print("[Kangaskhan] Move script not found for %s" % move_name)

func checkIfStruggle():
	if Move1PP == 0 && Move2PP == 0 && Move3PP == 0 && Move4PP == 0:
		isStruggling = true

func set_all_move_pp_from_current_moves():
	for i in range(currentMoves.size()):
		var move_name = currentMoves[i]
		var move_scene_path = "res://Scripts/Moves/%s.tscn" % move_name
		if ResourceLoader.exists(move_scene_path):
			var move_scene = load(move_scene_path)
			var move_instance = move_scene.instantiate()
			var max_pp = move_instance.maxPP if "maxPP" in move_instance else 0
			match i:
				0:
					Move1PP = max_pp
				1:
					Move2PP = max_pp
				2:
					Move3PP = max_pp
				3:
					Move4PP = max_pp

func setCurrentHP():
	currentHP = currentMaxHP

func setLevel(level: int):
	currentLevel = level

func setLevelRange(levelRange: int):
	self.levelRange = levelRange

func randomizeHeldItem(heldItemChance):
	pass

func WildGenerator():
	# Randomize current level within [currentLevel - levelRange, currentLevel + levelRange], clamped 1-100
	var min_level = max(1, currentLevel - levelRange)
	var max_level = min(100, currentLevel + levelRange)
	currentLevel = randi_range(min_level, max_level)
	# randomly set current moves from potentiell moves
	# randomize abilities from potentiell abilities
	# randomize nature from potentiell natures
	if isWild and (Gender == "" or Gender == null):
		if PotentialGenders.size() > 0:
			Gender = PotentialGenders[randi() % PotentialGenders.size()]
	# randomize held item from potentiell items
	_recalculate_stats()

func initializeInspector():
	Name = Name
	PokedexNR = PokedexNR
	OwndexNR = OwndexNR
	TYP = TYP
	Gender = Gender
	Nature = Nature
	canBeShiny = canBeShiny
	isShiny = isShiny
	isWild = isWild
	
	uniquePokemonID = uniquePokemonID
	PotentialGenders = PotentialGenders
	PotentialNatures = PotentialNatures
	canEvolve = canEvolve
	EvolveLvl = EvolveLvl
	EvolveItem = EvolveItem
	EvolveLocation = EvolveLocation
	EvolveETC = EvolveETC
	currentHP = currentHP
	Move1PP = Move1PP
	Move2PP = Move2PP
	Move3PP = Move3PP
	Move4PP = Move4PP
	StatusEffect = StatusEffect

	currentLevel = currentLevel
	Exp = Exp
	Moves = Moves
	Ability = Ability
	pokemonAccuracy = pokemonAccuracy
	evasion = evasion

	Lvl1HP = Lvl1HP
	Lvl1Attack = Lvl1Attack
	Lvl1Defense = Lvl1Defense
	Lvl1SPAttack = Lvl1SPAttack
	Lvl1SPDefense = Lvl1SPDefense
	Lvl1Initiative = Lvl1Initiative

	maxLvlHP = maxLvlHP
	maxLvlAttack = maxLvlAttack
	maxLvlDefense = maxLvlDefense
	maxLvlSPAttack = maxLvlSPAttack
	maxLvlSPDefense = maxLvlSPDefense
	maxLvlInitiative = maxLvlInitiative

	TraingnigHP = TraingnigHP
	TraingnigAttack = TraingnigAttack
	TraingnigDefense = TraingnigDefense
	TraingnigSPAttack = TraingnigSPAttack
	TraingnigSPDefense = TraingnigSPDefense
	TraingnigInitiative = TraingnigInitiative
