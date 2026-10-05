extends Node3D


# ============================================================
# BRUNO BOSS SPOTLIGHT
# ============================================================
#
# Questo nodo resta fisso sulla torre e ruota soltanto per
# puntare Bruno dall'alto.
#
# SAFE:
# - non modifica Bruno;
# - non modifica la cinematic;
# - non modifica il combat;
# - si attiva automaticamente solo quando Bruno entra davvero
#   nella boss fight (ai_active=true e cinematic_locked=false).
# ============================================================


@export_category("Target")
@export var target: Node3D
@export_range(0.0, 3.0, 0.05) var target_height: float = 1.10

@export_category("Spotlight")
@export var spotlight: SpotLight3D
@export var start_disabled: bool = true

@export_category("Tracking")
@export_range(0.1, 20.0, 0.1) var tracking_speed: float = 4.0
@export var auto_activate_from_bruno_state: bool = true

@export_category("Debug")
@export var debug_force_active: bool = false
@export var debug_logging: bool = true


var tracking_active: bool = false


func _ready() -> void:
	if spotlight == null:
		spotlight = get_node_or_null("SpotLight3D") as SpotLight3D

	if spotlight == null:
		push_error(
			"BrunoBossSpotlight: SpotLight3D non assegnata."
		)
		return

	if start_disabled:
		spotlight.visible = false

	if debug_force_active:
		activate_spotlight()


func _process(delta: float) -> void:
	if spotlight == null:
		return

	if target == null or not is_instance_valid(target):
		return

	if (
		not tracking_active
		and auto_activate_from_bruno_state
		and _bruno_fight_is_active()
	):
		activate_spotlight()

	if not tracking_active:
		return

	_track_target(delta)


func activate_spotlight() -> void:
	if spotlight == null:
		return

	tracking_active = true
	spotlight.visible = true

	# Al primo frame punta subito Bruno, evitando che il fascio
	# attraversi la scena partendo dalla vecchia rotazione.
	_snap_to_target()

	if debug_logging:
		print(
			"[BOSS SPOTLIGHT] ATTIVO | target=",
			target.get_path() if target != null else "<null>"
		)


func deactivate_spotlight() -> void:
	tracking_active = false

	if spotlight != null:
		spotlight.visible = false

	if debug_logging:
		print("[BOSS SPOTLIGHT] SPENTO")


func _bruno_fight_is_active() -> bool:
	if target == null:
		return false

	# Bruno espone già questi due stati:
	# - prima/durante cinematic: ai_active=false / cinematic_locked=true
	# - boss fight:             ai_active=true  / cinematic_locked=false
	var ai_value: Variant = target.get("ai_active")
	var cinematic_value: Variant = target.get("cinematic_locked")

	if not ai_value is bool:
		return false

	if not cinematic_value is bool:
		return false

	return (
		bool(ai_value)
		and not bool(cinematic_value)
	)


func _snap_to_target() -> void:
	if target == null:
		return

	var target_position := (
		target.global_position
		+ Vector3.UP * target_height
	)

	var direction := (
		target_position
		- global_position
	)

	if direction.length_squared() <= 0.000001:
		return

	# Node3D / SpotLight3D puntano lungo -Z.
	var desired_basis := Basis.looking_at(
		direction.normalized(),
		Vector3.UP
	)

	global_basis = desired_basis


func _track_target(delta: float) -> void:
	var target_position := (
		target.global_position
		+ Vector3.UP * target_height
	)

	var direction := (
		target_position
		- global_position
	)

	if direction.length_squared() <= 0.000001:
		return

	var desired_basis := Basis.looking_at(
		direction.normalized(),
		Vector3.UP
	)

	var current_rotation := global_basis.get_rotation_quaternion()
	var desired_rotation := desired_basis.get_rotation_quaternion()

	var weight := clampf(
		tracking_speed * delta,
		0.0,
		1.0
	)

	var smoothed_rotation := current_rotation.slerp(
		desired_rotation,
		weight
	)

	global_basis = Basis(smoothed_rotation)
