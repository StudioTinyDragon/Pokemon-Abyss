extends Node

@export var moveType: String = ""
@export var moveCat: String = "Physical"
@export var movePower: int = 50
@export var maxPP: int = 200
@export var accuracy: int = 100
@export var makesContact: bool = true
@export var effectedByProtect: bool = true
@export var effectedByMagicCoat: bool = false
@export var effectedBySnatch: bool = false
@export var effectedByMirrorMove: bool = false
@export var effectedByKingsRock: bool = true
@export var isPrioMove: bool = false
@export var canInterrupt: int = 0
@export var isRecoil: int = 4

func RecoilDamage(attacker):
	# Calculate recoil damage based on the attacker's current HP and the recoil percentage
	if not attacker or not attacker.has_method("get_stat") or not attacker.has_method("set_stat"):
		print("[Struggle] Invalid attacker or missing stat methods.")
		return
	var currentMaxHP = attacker.get_stat("currentMaxHP")
	var recoil_damage = int(currentMaxHP / isRecoil)
	if recoil_damage < 1:
		recoil_damage = 1  # Ensure at least 1 HP recoil
	attacker.set_stat("currentMaxHP", max(0, currentMaxHP - recoil_damage))
	print("[Struggle] Attacker takes %d recoil damage." % recoil_damage)
