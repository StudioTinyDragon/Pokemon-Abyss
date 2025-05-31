extends Node

@export var moveType: String = "Normal"
@export var moveCat: String = "Status"
@export var movePower: int = 0
@export var maxPP: int = 30
@export var accuracy: int = 100
@export var makesContact: bool = false
@export var effectedByProtect: bool = true
@export var effectedByMagicCoat: bool = true
@export var effectedBySnatch: bool = false
@export var effectedByMirrorMove: bool = true
@export var effectedByKingsRock: bool = false
@export var isPrioMove: bool = false
@export var canInterrupt: int = 0

# Tracks the cumulative percentage of Defense debuffed by Tail Whip (max 30%)
static var DebuffEnemyDefenseTracker := {} # id: {"original": value, "debuffed": percent}

func DebuffEnenmyDefensex1(target_pokemon):
	if not target_pokemon or not target_pokemon.has_method("set_stat") or not target_pokemon.has_method("get_stat") or not target_pokemon.has_method("get_instance_id"):
		print("[Tail Whip] Invalid target or missing stat methods.")
		return
	var id = target_pokemon.get_instance_id()
	# Debug: print tracker state
	print("[Tail Whip DEBUG] id:", id, " tracker:", DebuffEnemyDefenseTracker)
	# Store original defense if not already tracked (must be the first time, before any debuff)
	if not DebuffEnemyDefenseTracker.has(id):
		DebuffEnemyDefenseTracker[id] = {"original": target_pokemon.get_stat("currentDefense"), "debuffed": 0.0}
	var tracker = DebuffEnemyDefenseTracker[id]
	var original_def = tracker["original"]
	if tracker["debuffed"] >= 0.3:
		print("[Tail Whip] Target's Defense cannot be reduced further (max 30%).")
		return
	# Calculate debuff as 5% of original defense, but don't exceed 30% total
	var debuff_percent = min(0.05, 0.3 - tracker["debuffed"])
	tracker["debuffed"] += debuff_percent
	var new_def = max(1, original_def * (1.0 - tracker["debuffed"]))
	target_pokemon.set_stat("currentDefense", new_def)
	print("[Tail Whip] Target's Defense reduced by %.0f%% (%.0f%% total, max 30%%) from %s to %s" % [debuff_percent*100, tracker["debuffed"]*100, original_def, new_def])
