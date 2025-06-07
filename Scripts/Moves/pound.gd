extends Node

@export_enum("Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark") var moveType = "Normal"
@export_enum("Physical", "Special", "Status") var moveCat = "Physical"
@export_enum("ally", "adjacent allies", "all allies", "self", "enemy", "adjacent enemies", "all enemies", "everyone", "random enemy") var effectRange = "enemy"
@export var movePower: int
@export var maxPP: int
@export_range(0, 100, 1.0) var moveAccuracy: float
@export var canCrit: bool
@export_range(0, 100, 1.0) var BonusCritChance: float
@export_range(0, 100, 1.0) var flinchChance: float

@export_range(-7, 5, 1) var PrioMove: float

@export var makesContact: bool

@export var effectedByProtect: bool
@export var effectedByMagicCoat: bool
@export var effectedBySnatch: bool
@export var effectedByMirrorMove: bool
@export var effectedByKingsRock: bool


@export var canBypassFly: bool
@export var canBypassBounce: bool
@export var canBypassSkydrop: bool
@export var canBypassDig: bool
@export var canBypassDive: bool

@export var isRecoil: int

func try_flinch_opponent() -> bool:
	var roll = randf() * 100.0
	return roll < flinchChance

func initialize_from_inspector():
	movePower = movePower
	maxPP = maxPP
	flinchChance = flinchChance
	BonusCritChance = BonusCritChance
	moveAccuracy = moveAccuracy
	canCrit = canCrit
	PrioMove = PrioMove
	makesContact = makesContact
	effectedByProtect = effectedByProtect
	effectedByMagicCoat = effectedByMagicCoat
	effectedBySnatch = effectedBySnatch
	effectedByMirrorMove = effectedByMirrorMove
	effectedByKingsRock = effectedByKingsRock
	canBypassFly = canBypassFly
	canBypassBounce = canBypassBounce
	canBypassSkydrop = canBypassSkydrop
	canBypassDig = canBypassDig
	canBypassDive = canBypassDive
	isRecoil = isRecoil
