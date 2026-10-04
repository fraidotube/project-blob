extends Area3D

@export var tv_controller: Node
@export var cinematic_controller: Node
@export var interaction_name := "TELECOMANDO"

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var interaction_color := Color("b86cff")
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015
@export var interaction_visual_roots: Array[NodePath] = []

@export_group("Remote Audio")
@export var remote_sound: AudioStream
@export_range(-40.0, 12.0, 0.5) var remote_volume_db := 0.0
@export_range(1.0, 50.0, 0.5) var audio_max_distance := 6.0

var outline_material: ShaderMaterial
var outlined_meshes: Array[GeometryInstance3D] = []
var remote_audio: AudioStreamPlayer3D


func _setup_interaction_outline() -> void:
	outline_material = ShaderMaterial.new()
	outline_material.shader = OUTLINE_SHADER
	outline_material.set_shader_parameter(
		"outline_color",
		interaction_color
	)
	outline_material.set_shader_parameter(
		"outline_width",
		outline_width
	)

	outlined_meshes.clear()

	if interaction_visual_roots.is_empty():
		_collect_interaction_geometry(self)
	else:
		for path: NodePath in interaction_visual_roots:
			var visual_root := get_node_or_null(path)
			if visual_root != null:
				_collect_interaction_geometry(visual_root)

	set_interaction_focus(false)


func _collect_interaction_geometry(node: Node) -> void:
	if node.name == "InteractionOutline":
		return
	if node.name == "OutlineBuilder":
		return
	if node.name == "InteractionOutlineProxy":
		return

	if node is GeometryInstance3D:
		outlined_meshes.append(node as GeometryInstance3D)

	for child: Node in node.get_children():
		_collect_interaction_geometry(child)


func set_interaction_focus(enabled: bool) -> void:
	for mesh: GeometryInstance3D in outlined_meshes:
		if not is_instance_valid(mesh):
			continue

		mesh.material_overlay = outline_material if enabled else null


func get_interaction_color() -> Color:
	return interaction_color


func _ready() -> void:
	_setup_remote_audio()
	_setup_interaction_outline()


func _setup_remote_audio() -> void:
	remote_audio = AudioStreamPlayer3D.new()
	remote_audio.name = "RemoteAudio"
	remote_audio.bus = &"SFX"
	remote_audio.volume_db = remote_volume_db
	remote_audio.max_distance = audio_max_distance
	add_child(remote_audio)


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "USA"


func interact(_player: Node) -> void:
	if tv_controller == null:
		return

	_play_remote_sound()

	if not tv_controller.has_method("toggle_tv"):
		return

	var tv_started := bool(
		tv_controller.call(
			"toggle_tv"
		)
	)

	# La cinematic parte SOLO se la TV si è realmente accesa.
	# Se il contatore è spento, toggle_tv() restituisce false.
	if not tv_started:
		return

	if (
		cinematic_controller != null
		and cinematic_controller.has_method(
			"start_intro"
		)
	):
		cinematic_controller.call(
			"start_intro"
		)


func _play_remote_sound() -> void:
	if remote_audio == null:
		return

	if remote_sound == null:
		return

	remote_audio.stop()
	remote_audio.stream = remote_sound
	remote_audio.volume_db = remote_volume_db
	remote_audio.max_distance = audio_max_distance
	remote_audio.play()
