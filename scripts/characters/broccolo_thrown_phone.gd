extends RigidBody3D
## Reports the first contact whose normal points mostly upward.

signal floor_contacted

@export_range(0.3, 0.95, 0.05) var floor_normal_threshold := 0.65

var _floor_contact_reported := false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _floor_contact_reported:
		return
	for contact_index in range(state.get_contact_count()):
		var local_normal: Vector3 = state.get_contact_local_normal(contact_index)
		var world_normal: Vector3 = (state.transform.basis * local_normal).normalized()
		if world_normal.dot(Vector3.UP) >= floor_normal_threshold:
			_floor_contact_reported = true
			call_deferred("_emit_floor_contacted")
			return

func _emit_floor_contacted() -> void:
	if is_inside_tree():
		floor_contacted.emit()
