extends Node

const MOTION := preload("res://scripts/characters/bruno_mouth_motion.gd")
const HEAD_FILE := "res://assets/models/enemies/bruno_buozzi/mouth_preview_v6/bruno_head_mouth_preview.glb"
const INTRO_SCRIPT := "res://scripts/cinematics/bruno_intro_controller.gd"
var boss: Node
var head: MeshInstance3D
var motion: Node
var intro: Node
var combat_voice: Node
var death_voice: Node
var dialogue_voice: Node
var animation: AnimationPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_priority = -10
	set_process(false)
	call_deferred("_setup")

func _setup() -> void:
	boss = get_parent()
	# The isolated preview intentionally strips the boss script.
	if boss.get_script() == null:
		return
	head = boss.get_node_or_null("BetterBuozzi/Armature/GeneralSkeleton/mixamorig_Head/output_unwrapped") as MeshInstance3D
	combat_voice = boss.get("boss_voice_player")
	if head == null or combat_voice == null:
		push_error("Bruno mouth integration: verified head/voice missing")
		return
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	if document.append_from_file(HEAD_FILE, state) != OK:
		push_error("Bruno mouth integration: variant could not load")
		return
	var imported := document.generate_scene(state)
	var mesh: ArrayMesh
	for node in imported.find_children("*", "MeshInstance3D", true, false):
		mesh = node.mesh as ArrayMesh
		break
	if imported is MeshInstance3D:
		mesh = imported.mesh as ArrayMesh
	imported.free()
	if mesh == null or mesh.get_blend_shape_count() != 3:
		push_error("Bruno mouth integration: expected three expressions")
		return
	var material := head.get_active_material(0)
	head.mesh = mesh
	head.set_surface_override_material(0, material)
	var cavity := StandardMaterial3D.new()
	cavity.albedo_color = Color(0.015, 0.004, 0.008)
	cavity.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cavity.cull_mode = BaseMaterial3D.CULL_DISABLED
	head.set_surface_override_material(1, cavity)
	animation = boss.get_node("BetterBuozzi/AnimationPlayer") as AnimationPlayer
	for node in get_tree().root.find_children("*", "Node", true, false):
		var script = node.get_script()
		if script != null and script.resource_path == INTRO_SCRIPT and node.get("bruno") == boss:
			intro = node
			break
	death_voice = boss.get_node_or_null("BrunoDeathAudio")
	if is_instance_valid(intro):
		dialogue_voice = intro.get("dialogue_player")
	motion = MOTION.new()
	motion.target_mesh = head
	motion.voice = combat_voice
	add_child(motion)
	set_process(true)
	print("BRUNO_MOUTH_INTEGRATED ", boss.get_path())

func _process(_delta: float) -> void:
	if motion == null:
		return
	if not is_instance_valid(death_voice):
		death_voice = boss.get_node_or_null("BrunoDeathAudio")
	if is_instance_valid(intro) and not is_instance_valid(dialogue_voice):
		dialogue_voice = intro.get("dialogue_player")
	var selected := combat_voice
	if is_instance_valid(dialogue_voice) and dialogue_voice.get("playing"):
		selected = dialogue_voice
	if is_instance_valid(death_voice) and death_voice.get("playing"):
		selected = death_voice
	motion.bind_voice(selected)
	var stream: AudioStream = selected.get("stream")
	var path := stream.resource_path.to_lower() if stream != null else ""
	var reaction := selected == death_voice or "dolore" in path or "caduta" in path
	motion.expressive_speech = not reaction
	motion.laughing = not reaction and "laugh" in String(animation.current_animation).to_lower()
