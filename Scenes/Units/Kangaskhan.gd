extends CharacterBody2D

#region PokemonVars
# Pokemon info
@export var Name : String                 = "Kangaskhan"
@export var PokedexNR : int               = 115
@export var TYP: Array[String]            = ["Normal"]
@export var Gender : String               = ""
@export var Nature: String                = ""

@export var PotentialGenders: Array[String] = ["Female"]
@export var PotentialNatures: Array[String] = ["Hardy"]

#dynamic stats
@export var currentHP: int                = 13
@export var Move1AP: int                  = 0
@export var Move2AP: int                  = 0
@export var Move3AP: int                  = 0
@export var Move4AP: int                  = 0
@export var StatusEffect: Array[String]   = []
@export var heldItem: String              = ""

@export var currentLevel: int             = 1
@export var Exp: int                      = 0
@export var Moves: Array[String]          = []
@export var Ability : String              = ""



# Statblock
@export var maxHP: int                    = 13
@export var Attack: int                   = 6
@export var Defense: int                  = 6
@export var SPAttack: int                 = 5
@export var SPDefense: int                = 6
@export var Iniative: int                 = 6

@export var maxLvlHp: int                 = 320
@export var maxLvlAttack: int             = 195
@export var maxLvlDefense: int            = 165
@export var maxLvlSPAttack: int           = 85
@export var maxLvlSPDefense: int          = 165
@export var maxLvlInitiative: int         = 185

@export var maxLvlUpPoints: int = 1311
@export var pointsPerLvlUp: int = 7

@export var CatchRate: int                = 45 #Higher Catchrate = easier

@export var currentMoves: Array[String] = []
@export var potentialMoves: Array[String] = []
@export var potentialAbilities: Array[String] = ["Early Bird", "Scrappy", "Inner Focus"]


var move_levels = {
	"Pound": 1,
	"TailWhip": 1,
	"Growl": 4,
	"FakeOut": 8,
	"Bite": 12
}

#endregion

#region State

var isFainted


#endregion


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

func _ready():
	add_to_group("player_pokemon")
