extends Node

const HEAD_FILE := "res://assets/models/enemies/Angelastri/mouth_preview_v2/angelastri_head_mouth.glb"
const MOTION := preload("res://scripts/characters/bruno_mouth_motion.gd")
@export var voice: Node
var head: MeshInstance3D
var motion: Node
var ready_for_mouth := false

func _ready() -> void:
	call_deferred("_setup")

func _setup() -> void:
	head = get_parent().get_node_or_null("sgt_Angelastri/Armature/GeneralSkeleton/mixamorig_Neck/Testa") as MeshInstance3D
	if head == null:
		push_error("Angelastri mouth: official Testa mesh missing")
		return
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	if document.append_from_file(HEAD_FILE, state) != OK:
		push_error("Angelastri mouth: variant could not load")
		return
	var imported := document.generate_scene(state)
	var mesh: ArrayMesh
	if imported is MeshInstance3D:
		mesh = imported.mesh as ArrayMesh
	else:
		for node in imported.find_children("*", "MeshInstance3D", true, false):
			mesh = node.mesh as ArrayMesh
			break
	imported.free()
	if mesh == null or mesh.get_blend_shape_count() != 3:
		push_error("Angelastri mouth: expected open/round/smile shapes")
		return
	var original_material := head.get_active_material(0)
	head.mesh = mesh
	head.set_surface_override_material(0, original_material)
	var cavity := StandardMaterial3D.new()
	cavity.albedo_color = Color(0.015, 0.004, 0.008)
	cavity.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cavity.cull_mode = BaseMaterial3D.CULL_DISABLED
	head.set_surface_override_material(1, cavity)
	ready_for_mouth = true
	_configure_motion()
	print("ANGELASTRI_MOUTH_READY shapes=", head.mesh.get_blend_shape_count())

func bind_voice(next_voice: Node) -> void:
	voice = next_voice
	if motion != null:
		if next_voice != null:
			motion.bind_voice(next_voice)
		else:
			motion.free()
			motion = null
			set_expression(0, 0, 0)
	else:
		_configure_motion()

func _configure_motion() -> void:
	if not ready_for_mouth or not is_instance_valid(voice) or motion != null: return
	motion = MOTION.new()
	motion.target_mesh = head
	motion.voice = voice
	add_child(motion)

func set_expression(opening: float, rounded: float = 0.0, smile: float = 0.0) -> void:
	if not ready_for_mouth: return
	for entry in [[&"mouth_open", opening], [&"mouth_round", rounded], [&"mouth_smile", smile]]:
		head.set_blend_shape_value(head.find_blend_shape_by_name(entry[0]), clampf(entry[1], 0, 1))
