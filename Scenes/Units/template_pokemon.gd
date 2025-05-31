extends CharacterBody2D

#region PokemonVars
# Pokemon info
@export var Name : String                 = "Test"
@export var PokedexNR : int               = 0
@export var TYP: Array[String]            = []
@export var Gender : String               = "Test"


#dynamic stats
@export var currentHP: int                = 0
@export var Move1AP: int                  = 0
@export var Move2AP: int                  = 0
@export var Move3AP: int                  = 0
@export var Move4AP: int                  = 0
@export var StatusEffect: Array[String]   = []

@export var Level: int                    = 0
@export var Exp: int                      = 0
@export var Moves: Array[String]          = []
@export var Ability : Array[String]       = []

# Statblock
@export var maxHP: int                    = 0
@export var Attack: int                   = 0
@export var SPAttack: int                 = 0
@export var Defense: int                  = 0
@export var SPDefense: int                = 0
@export var Iniative: int                 = 0

@export var CatchRate: int                = 0

#endregion
