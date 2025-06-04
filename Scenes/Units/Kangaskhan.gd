extends Node2D

#region PokemonVars
@export_category("Pokemon Info")
@export var Name : String                 = "Kangaskhan"
@export var PokedexNR : int               = 115
@export var OwndexNR: int                 
@export var TYP: Array[String]            = ["Normal"]
@export_enum("Female", "Male") var Gender = "No standard Gender"
@export_enum("Hardy") var Nature          = "No standard Nature"
@export var canBeShiny: bool              = true
@export var isShiny: bool                 = false

@export var uniquePokemonID: int

@export var PotentialGenders: Array[String] = ["Female"]
@export var PotentialNatures: Array[String] = ["Hardy"]

@export_subgroup("Sprites")
@export_file("*.png") var PokemonFront             = ""
@export_file("*.png") var PokemonBack              = ""
@export_file("*.png") var PokemonIcon              = ""
@export_file("*.png") var PokemonFrontShiny        = ""
@export_file("*.png") var PokemonBackShiny         = ""
@export_file("*.png") var PokemonImage             = ""

#region Evolve Info
@export_subgroup("evolve info")
@export var canEvolve :bool                 = false
@export var EvolveLvl :int
@export var EvolveItem :String
@export var EvolveLocation :String
@export var EvolveETC :String

#endregion

#region currentBattleStats

#dynamic stats
var currentHP: int                = 13
var Move1PP: int                  = 0
var Move2PP: int                  = 0
var Move3PP: int                  = 0
var Move4PP: int                  = 0
var StatusEffect: Array[String]   = []
@export_group("Stats")
@export var heldItem: String

@export_range(0, 100, 1.0) var currentLevel   = 1.0
@export var Exp: int                          = 0
@export var Moves: Array[String]              = []
@export var Ability : String
var pokemonAccuracy: int                      = 100
var evasion : int                             = 0

#endregion

# Statblock
#region MinStats
@export_subgroup("Lvl1 Stats")
@export var Lvl1HP: int                         = 13
@export var Lvl1Attack: int                     = 6
@export var Lvl1Defense: int                    = 6
@export var Lvl1SPAttack: int                   = 5
@export var Lvl1SPDefense: int                  = 6
@export var Lvl1Initiative: int                 = 6

#endregion

#region MaxStats
@export_subgroup("Max Lvl Stats")
@export var maxLvlHP: int                 = 320
@export var maxLvlAttack: int             = 195
@export var maxLvlDefense: int            = 165
@export var maxLvlSPAttack: int           = 85
@export var maxLvlSPDefense: int          = 165
@export var maxLvlInitiative: int         = 185

#endregion

#region TrainingLvl
@export_subgroup("Training Modifier")
@export var TraingnigHP :int                   =0
@export var TraingnigAttack :int               =0
@export var TraingnigDefense :int              =0
@export var TraingnigSPAttack :int             =0
@export var TraingnigSPDefense :int            =0
@export var TraingnigInitiative :int           =0 
#TODO TrainingLvl erhöhen können + MaxLvl dafür ( ist schon in der Stat berechnung eingebunden, momentan für 1% Bonus pro TrainingLvl)

#endregion

#region currentStats
@export_subgroup("Current Stats")
@warning_ignore("narrowing_conversion")
@export var currentMaxHP :int             = ((maxLvlHP - Lvl1HP) /99.0 * (currentLevel - 1.0) +Lvl1HP) * (1 + (0.1 * TraingnigHP))
@warning_ignore("narrowing_conversion")
@export var currentAttack :int            = ((maxLvlAttack - Lvl1Attack) /99.0 * (currentLevel - 1.0) +Lvl1Attack) * (1 + (0.01 * TraingnigAttack))
@warning_ignore("narrowing_conversion")
@export var currentDefense :int           = ((maxLvlDefense - Lvl1Defense) /99.0 * (currentLevel - 1.0) +Lvl1Defense) * (1 + (0.01 * TraingnigDefense))
@warning_ignore("narrowing_conversion")
@export var currentSPAttack :int          = ((maxLvlSPAttack - Lvl1SPAttack) /99.0 * (currentLevel - 1.0) +Lvl1SPAttack) * (1 + (0.01 * TraingnigSPAttack))
@warning_ignore("narrowing_conversion")
@export var currentSPDefense :int         = ((maxLvlSPDefense - Lvl1SPDefense) /99.0 * (currentLevel - 1.0) +Lvl1SPDefense) * (1 + (0.01 * TraingnigSPDefense))
@warning_ignore("narrowing_conversion")
@export var currentInitiative :int        = ((maxLvlInitiative - Lvl1Initiative) /99.0 * (currentLevel - 1.0) +Lvl1Initiative) * (1 + (0.01 * TraingnigInitiative))

#endregion

@export var CatchRate: int                = 45 #Higher Catchrate = easier

@export var currentMoves: Array[String] = []
@export_subgroup("Potential")
@export var potentialMoves: Array[String] = []
@export var potentialAbilities: Array[String] = ["Early Bird", "Scrappy", "Inner Focus"]
@export var potentialHeldItems: Array[String] = ["Bitter Berry"]

#region MoveLvlLocked
@export_subgroup("Moves per Level")
var move_levels = {
	"Pound": 1,
	"TailWhip": 1,
	"Growl": 4,
	"FakeOut": 8,
	"Bite": 12
}

#endregion

#endregion

#region State

var isFainted
var settingMove = false
var isStruggling: bool = false

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
	shinyProbabilityGenerator()
	setPokemonSprites()

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
