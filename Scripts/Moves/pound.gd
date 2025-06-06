extends Node


@export_enum("Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark") var moveType = "Normal"
@export_enum("Physical", "Special", "Status") var moveCat = "Physical"
@export_enum("ally", "adjacent allies", "all allies", "self", "enemy", "adjacent enemies", "all enemies", "everyone", "random enemy") var effectRange = "enemy"
@export var movePower: int = 40
@export var maxPP: int = 35
@export_range(0, 100, 1.0) var moveAccuracy = 100.0
@export var canCrit: bool = true
@export_range(0, 100, 1.0) var BonusCritChance = 0.0
@export_range(0, 100, 1.0) var interruptChance = 0.0

@export var isPrioMove: bool = false

@export var makesContact: bool = true

@export var effectedByProtect: bool = true
@export var effectedByMagicCoat: bool = false
@export var effectedBySnatch: bool = false
@export var effectedByMirrorMove: bool = true
@export var effectedByKingsRock: bool = true


@export var canBypassFly: bool = false
@export var canBypassBounce: bool = false
@export var canBypassSkydrop: bool = false
@export var canBypassDig: bool = false
@export var canBypassDive: bool = false

@export var isRecoil: int = 0
