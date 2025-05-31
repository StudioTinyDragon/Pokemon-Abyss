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
var DebuffEnenmyDefenseTracker := {}

func DebuffEnenmyDefensex1(target_pokemon):
	if not target_pokemon or not target_pokemon.has_method("set_stat") or not target_pokemon.has_method("get_stat") or not target_pokemon.has_method("get_instance_id"):
		print("[Tail Whip] Invalid target or missing stat methods.")
		return
	var id = target_pokemon.get_instance_id()
	if not DebuffEnenmyDefenseTracker.has(id):
		DebuffEnenmyDefenseTracker[id] = 0.0
	var current_debuff = DebuffEnenmyDefenseTracker[id]
	if current_debuff >= 0.3:
		print("[Tail Whip] Target's Defense cannot be reduced further (max 30%).")
		return
	var current_def = target_pokemon.get_stat("currentDefense")
	var debuff_percent = min(0.05, 0.3 - current_debuff)
	var debuff_amount = current_def * debuff_percent
	var new_def = max(1, current_def - debuff_amount)
	target_pokemon.set_stat("currentDefense", new_def)
	DebuffEnenmyDefenseTracker[id] += debuff_percent
	print("[Tail Whip] Target's Defense reduced by %.0f%% (%.0f%% total, max 30%%) from %s to %s" % [debuff_percent*100, DebuffEnenmyDefenseTracker[id]*100, current_def, new_def])
