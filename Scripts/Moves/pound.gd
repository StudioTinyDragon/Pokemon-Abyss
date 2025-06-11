extends Node

@export_enum("Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark") var moveType
@export_enum("Physical", "Special", "Status") var moveCat
@export_enum("ally", "adjacent allies", "all allies", "self", "enemy", "adjacent enemies", "all enemies", "everyone", "random enemy") var effectRange = "enemy"
@export_enum("none", "DebuffEnenmyDefensex1") var Effect
@export var movePower: int
@export var maxPP: int
@export_range(0, 100, 1.0) var moveAccuracy: float
@export var canCrit: bool
@export_range(0, 4, 1.0) var BonusCritChance: float
# 0 = 5%, 1 = 25%, 2 = 50%, 3 = 75%, 4 = 100%
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

var critChance: int
@warning_ignore("unused_private_class_variable")
var _last_crit: bool = false
var last_move_effectiveness: float = 1.0

func try_flinch_opponent() -> bool:
	var roll = randf() * 100.0
	return roll < flinchChance

func initialize_from_inspector():
	movePower = movePower
	moveCat = moveCat
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
	# Fix: ensure moveType is always a string, not an int, for STAB logic
	if typeof(moveType) == TYPE_INT:
		var type_names = ["Normal", "Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark"]
		moveType = type_names[int(moveType)]
	if typeof(moveCat) == TYPE_INT:
		var cat_names = ["Physical", "Special", "Status"]
		moveCat = cat_names[int(moveCat)]
	critManager() # Ensure critChance is set from BonusCritChance/canCrit

func critManager():
	if canCrit == false:
		critChance = 0
	if BonusCritChance == 0 && canCrit == true:
		critChance = 5
	if BonusCritChance == 1 && canCrit == true:
		critChance = 25
	if BonusCritChance == 2 && canCrit == true:
		critChance = 50
	if BonusCritChance == 3 && canCrit == true:
		critChance = 75
	if BonusCritChance == 4 && canCrit == true:
		critChance = 100

func DebuffEnenmyDefensex1(target_pokemon):
	# Effect is an int (enum index), so compare to the correct value
	# 0 = "none", 1 = "DebuffEnenmyDefensex1"
	if Effect != 1:
		print("[Tail Whip] Effect enum is not set to DebuffEnenmyDefensex1, skipping debuff.")
		return
	if not target_pokemon or not target_pokemon.has_method("set_stat") or not target_pokemon.has_method("get_stat"):
		print("[Tail Whip] Invalid target or missing stat methods.")
		return
	# Ensure stat_debuffs exists and is a dictionary
	var stat_debuffs = target_pokemon.get_meta("stat_debuffs") if target_pokemon.has_meta("stat_debuffs") else {}
	if typeof(stat_debuffs) != TYPE_DICTIONARY:
		stat_debuffs = {}
	if not stat_debuffs.has("defense"):
		stat_debuffs["defense"] = 0.0
	var current_debuff = stat_debuffs["defense"]
	if current_debuff >= 0.3:
		print("[Tail Whip] Target's Defense cannot be reduced further (max 30%).")
		
		return
	var original_def = target_pokemon.get_stat("currentDefense") / (1.0 - current_debuff) if current_debuff > 0.0 else target_pokemon.get_stat("currentDefense")
	var debuff_percent = min(0.05, 0.3 - current_debuff)
	stat_debuffs["defense"] += debuff_percent
	var new_def = max(1, original_def * (1.0 - stat_debuffs["defense"]))
	target_pokemon.set_stat("currentDefense", new_def)
	target_pokemon.set_meta("stat_debuffs", stat_debuffs)
	print("[Tail Whip] Target's Defense reduced by %.0f%% (%.0f%% total, max 30%%) from %s to %s" % [debuff_percent*100, stat_debuffs["defense"]*100, original_def, new_def])
