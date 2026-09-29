extends Node3D

@export var power_system: Node
@export var led_red: Light3D
@export var led_green: Light3D
@export var interaction_name := "CONTATORE"

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var interaction_color := Color("b86cff")
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015
@export var interaction_visual_roots: Array[NodePath] = []

@export_group("Meter Audio")
@export var switch_sound: AudioStream
@export var power_on_sound: AudioStream
@export var power_off_sound: AudioStream
@export var hum_loop_sound: AudioStream
@export_range(-40.0, 12.0, 0.5) var switch_volume_db := 0.0
@export_range(-40.0, 12.0, 0.5) var power_volume_db := 0.0
@export_range(-40.0, 12.0, 0.5) var hum_volume_db := -8.0
@export_range(1.0, 50.0, 0.5) var audio_max_distance := 12.0
@export_range(1.0, 50.0, 0.5) var hum_max_distance := 8.0

var outline_material: ShaderMaterial
var outlined_meshes: Array[GeometryInstance3D] = []

var switch_audio: AudioStreamPlayer3D
var power_audio: AudioStreamPlayer3D
var hum_audio: AudioStreamPlayer3D


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
	_setup_audio()

	if power_system:
		power_system.power_changed.connect(_on_power_changed)

		var is_on: bool = bool(power_system.is_power_on())

		_update_leds(is_on)
		_update_hum_state(is_on)
	else:
		_update_leds(false)
		_update_hum_state(false)

	_setup_interaction_outline()


func _setup_audio() -> void:
	switch_audio = AudioStreamPlayer3D.new()
	switch_audio.name = "MeterSwitchAudio"
	switch_audio.bus = &"SFX"
	switch_audio.volume_db = switch_volume_db
	switch_audio.max_distance = audio_max_distance
	add_child(switch_audio)

	power_audio = AudioStreamPlayer3D.new()
	power_audio.name = "MeterPowerAudio"
	power_audio.bus = &"SFX"
	power_audio.volume_db = power_volume_db
	power_audio.max_distance = audio_max_distance
	add_child(power_audio)

	hum_audio = AudioStreamPlayer3D.new()
	hum_audio.name = "MeterHumAudio"
	hum_audio.bus = &"SFX"
	hum_audio.volume_db = hum_volume_db
	hum_audio.max_distance = hum_max_distance
	add_child(hum_audio)


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	if power_system == null:
		return "USA"

	return "DISATTIVA" if bool(power_system.is_power_on()) else "ATTIVA"


func interact(_player: Node) -> void:
	toggle_meter()


func toggle_meter() -> void:
	if power_system == null:
		return

	_play_switch_sound()
	power_system.toggle_power()


func _on_power_changed(is_on: bool) -> void:
	_update_leds(is_on)

	if is_on:
		_play_power_sound(power_on_sound)
	else:
		_play_power_sound(power_off_sound)

	_update_hum_state(is_on)


func _play_switch_sound() -> void:
	if switch_audio == null or switch_sound == null:
		return

	switch_audio.stop()
	switch_audio.stream = switch_sound
	switch_audio.volume_db = switch_volume_db
	switch_audio.max_distance = audio_max_distance
	switch_audio.play()


func _play_power_sound(stream: AudioStream) -> void:
	if power_audio == null or stream == null:
		return

	power_audio.stop()
	power_audio.stream = stream
	power_audio.volume_db = power_volume_db
	power_audio.max_distance = audio_max_distance
	power_audio.play()


func _update_hum_state(is_on: bool) -> void:
	if hum_audio == null:
		return

	if not is_on or hum_loop_sound == null:
		hum_audio.stop()
		return

	hum_audio.stream = hum_loop_sound
	hum_audio.volume_db = hum_volume_db
	hum_audio.max_distance = hum_max_distance

	if not hum_audio.playing:
		hum_audio.play()


func _update_leds(is_on: bool) -> void:
	if led_red:
		led_red.visible = not is_on

	if led_green:
		led_green.visible = is_on
