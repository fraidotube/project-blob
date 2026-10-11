extends RefCounted

var armed := false
var blackout_count := 0
var stage := "dormant"
var remaining := 0.0
var restored_power := false

func arm(delay: float) -> void:
	if armed: return
	armed = true
	stage = "countdown"
	remaining = delay

func tick(delta: float, inside: bool, powered: bool) -> bool:
	if stage != "countdown" or not inside or not powered: return false
	remaining = maxf(0.0, remaining - delta)
	if remaining > 0.0: return false
	blackout_count = mini(3, blackout_count + 1)
	stage = "blackout"
	restored_power = false
	return true

func power_changed(on: bool) -> void:
	if stage == "blackout": restored_power = on

func crossed(outward: bool, delay: float) -> bool:
	if outward:
		if stage == "blackout" and blackout_count == 3:
			stage = "performance"
			return true
	elif stage == "blackout" and blackout_count < 3 and restored_power:
		stage = "countdown"
		remaining = delay
	return false

func snapshot() -> Dictionary:
	return {"armed": armed, "blackout_count": blackout_count, "stage": stage,
		"remaining": remaining, "restored_power": restored_power}

func restore(data: Dictionary) -> void:
	armed = bool(data.get("armed", false))
	blackout_count = clampi(int(data.get("blackout_count", 0)), 0, 3)
	stage = String(data.get("stage", "dormant"))
	if stage not in ["dormant", "countdown", "blackout", "waiting", "fight_ready", "defeated"]: stage = "blackout"
	remaining = maxf(0.0, float(data.get("remaining", 0.0)))
	restored_power = bool(data.get("restored_power", false))
