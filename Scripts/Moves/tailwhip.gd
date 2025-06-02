extends Node

@export var moveType: String = "Normal"
@export var moveCat: String = "Status"
@export var movePower: int = 0
@export var maxPP: int = 30
@export var accuracy: int = 100
@export var effectRange: int = 2    # -1 = 1 ally,  -2 = adjacent allies,  -3 = all allies, 0 = self,  1 = 1 enemy,  2 = adjacent enemies,  3 = all enemies,  4 = random enemy,  5 = everyone  

@export var makesContact: bool = false

@export var effectedByProtect: bool = true
@export var effectedByMagicCoat: bool = true
@export var effectedBySnatch: bool = false
@export var effectedByMirrorMove: bool = true
@export var effectedByKingsRock: bool = false

@export var isPrioMove: bool = false
@export var canInterrupt: int = 0

@export var canBypassFly: bool = false
@export var canBypassBounce: bool = false
@export var canBypassSkydrop: bool = false
@export var canBypassDig: bool = false
@export var canBypassDive: bool = false


# Tail Whip now tracks debuffs per-pokemon using a stat_debuffs dictionary on the Pokémon instance (if available)
func DebuffEnenmyDefensex1(target_pokemon):
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
