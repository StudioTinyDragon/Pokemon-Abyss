extends Node

@export_enum("Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark", "none") var moveType = "Normal"
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

func RecoilDamage(attacker):
	# Calculate recoil damage based on the attacker's max HP and the recoil percentage
	if not attacker or not attacker.has_method("get_stat") or not attacker.has_method("set_stat"):
		print("[Struggle] Invalid attacker or missing stat methods.")
		return
	var currentMaxHP = attacker.get_stat("currentMaxHP")
	var currentHP = attacker.get_stat("currentHP")
	var recoil_damage = int(currentMaxHP / isRecoil)
	if recoil_damage < 1:
		recoil_damage = 1  # Ensure at least 1 HP recoil
	attacker.set_stat("currentHP", max(0, currentHP - recoil_damage))
	print("[Struggle] Attacker takes %d recoil damage." % recoil_damage)

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
