extends Node3D

const BRUNO := preload("res://scenes/enemies/bruno_buozzi.tscn")
const VOICE := preload("res://assets/models/enemies/bruno_buozzi/dialogoBruno2_p1_mostro.mp3")
const MOTION := preload("res://scripts/characters/bruno_mouth_motion.gd")
const THEME := preload("res://scenes/ui/project_blob_menu_theme.tres")
const HEAD_FILE := "res://assets/models/enemies/bruno_buozzi/mouth_preview_v6/bruno_head_mouth_preview.glb"

@export_range(1.0, 30.0, 0.5) var excerpt_seconds := 16.0
var bruno: Node3D
var head: MeshInstance3D
var original_head: MeshInstance3D
var animation_player: AnimationPlayer
var mouth: Node
var voice: AudioStreamPlayer
var camera: Camera3D
var _status: Label
var _play_button: Button
var _meter: ProgressBar
var _quarter := false
var _speaking_body := false
var _compare_original := false
var _manual_open := false

func _ready() -> void:
	_build_studio()
	bruno = BRUNO.instantiate() as Node3D
	# Display-only instance: do not run AI, combat, boss audio, or cinematic logic.
	bruno.set_script(null)
	if bruno is CollisionObject3D:
		bruno.collision_layer = 0
		bruno.collision_mask = 0
	add_child(bruno)
	for mesh: Node in bruno.find_children("*", "MeshInstance3D", true, false):
		if mesh.name == &"output_unwrapped":
			head = mesh as MeshInstance3D
			break
	if head == null:
		push_error("Mouth preview: original output_unwrapped head was not found.")
		return
	var replacement := _load_head_mesh()
	if replacement == null:
		return
	var original_material := head.get_active_material(0)
	original_head = MeshInstance3D.new()
	original_head.name = "OriginalHeadComparison"
	original_head.mesh = head.mesh
	original_head.transform = head.transform
	original_head.visible = false
	head.get_parent().add_child(original_head)
	head.mesh = replacement
	head.set_surface_override_material(0, original_material)
	# The recessed interior is deliberately matte and dark in both engines.
	var interior := StandardMaterial3D.new()
	interior.albedo_color = Color(0.015, 0.004, 0.008)
	interior.roughness = 1.0
	interior.cull_mode = BaseMaterial3D.CULL_DISABLED
	interior.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	head.set_surface_override_material(1, interior)
	animation_player = bruno.get_node("BetterBuozzi/AnimationPlayer") as AnimationPlayer
	voice = AudioStreamPlayer.new()
	voice.name = "MouthPreviewVoice"
	voice.stream = VOICE
	voice.bus = &"Master"
	voice.volume_db = 0.0
	add_child(voice)
	mouth = MOTION.new()
	mouth.target_mesh = head
	mouth.voice = voice
	add_child(mouth)
	voice.finished.connect(stop_voice)
	_build_ui()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.fade_out_menu_music(0.1)
	_set_body_animation(false)
	print("BRUNO_MOUTH_PREVIEW_READY head=", head.get_path(), " shapes=", head.mesh.get_blend_shape_count())

func _load_head_mesh() -> ArrayMesh:
	# Read the small variant directly. No full-project/editor import is needed.
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var error := document.append_from_file(HEAD_FILE, state)
	if error != OK:
		push_error("Mouth preview head failed to load: " + str(error))
		return null
	var imported := document.generate_scene(state)
	var result: ArrayMesh
	if imported is MeshInstance3D:
		result = imported.mesh as ArrayMesh
	else:
		for mesh: Node in imported.find_children("*", "MeshInstance3D", true, false):
			result = mesh.mesh as ArrayMesh
			break
	imported.free()
	if result == null or result.get_blend_shape_count() != 3 or result.get_blend_shape_name(0) != &"mouth_open":
		push_error("Mouth preview: exported mouth_open shape is missing.")
		return null
	return result

func _build_studio() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("12101b")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("c6bbd7")
	environment.ambient_light_energy = 0.65
	world.environment = environment
	add_child(world)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-25, -25, 0)
	key.light_energy = 1.1
	add_child(key)
	var fill := OmniLight3D.new()
	fill.position = Vector3(1, 2.5, 1)
	fill.light_color = Color("9e78c5")
	fill.light_energy = 0.8
	fill.omni_range = 5
	add_child(fill)
	camera = Camera3D.new()
	camera.fov = 35
	camera.near = 0.01
	add_child(camera)
	camera.current = true

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var panel := PanelContainer.new()
	panel.theme = THEME
	panel.position = Vector2(24, 24)
	panel.custom_minimum_size = Vector2(360, 0)
	layer.add_child(panel)
	var style := THEME.get_stylebox("panel", "Panel").duplicate() as StyleBoxFlat
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	var title := Label.new()
	title.text = "BRUNO / PROVA BOCCA"
	title.add_theme_font_size_override("font_size", 28)
	column.add_child(title)
	var hint := Label.new()
	hint.text = "Spazio: avvia / ferma   ·   R: riparti\n1: frontale   ·   2: tre quarti\nA: animazione corpo   ·   O: confronto originale\nM: apertura manuale   ·   L: prova risata\n3: forma O   ·   4: sorriso (durante M)"
	hint.add_theme_font_size_override("font_size", 18)
	column.add_child(hint)
	_play_button = Button.new()
	_play_button.text = "ASCOLTA PARLATO E RISATA"
	_play_button.pressed.connect(toggle_voice)
	column.add_child(_play_button)
	var caption := Label.new()
	caption.text = "APERTURA MASSIMA"
	column.add_child(caption)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.01
	slider.value = mouth.max_open
	slider.value_changed.connect(func(value: float) -> void: mouth.max_open = value)
	column.add_child(slider)
	_meter = ProgressBar.new()
	_meter.max_value = 1
	_meter.custom_minimum_size.y = 12
	_meter.show_percentage = false
	column.add_child(_meter)
	_status = Label.new()
	_status.text = "FERMO / BOCCA CHIUSA"
	_status.add_theme_font_size_override("font_size", 18)
	column.add_child(_status)

func _process(_delta: float) -> void:
	if head == null or mouth == null:
		return
	if voice.playing and voice.get_playback_position() >= excerpt_seconds:
		stop_voice()
	mouth.laughing = voice.playing and voice.get_playback_position() >= 11.55
	if _speaking_body and not animation_player.is_playing():
		animation_player.play(&"mie/talking1")
	if _manual_open:
		head.set_blend_shape_value(0, mouth.max_open)
	_meter.value = head.get_blend_shape_value(0)
	_status.text = ("ORIGINALE" if _compare_original else "VARIANTE") + (" / PARLA" if voice.playing else " / FERMO")
	_update_camera()

func _update_camera() -> void:
	var center := head.global_transform * Vector3(0, -0.12, 0)
	var direction := Vector3(0.45, 0.04, 1) if _quarter else Vector3(0, 0.02, 1)
	# Keep framing the head as its original bone animates.
	var orientation := head.global_basis.orthonormalized()
	camera.global_position = center + orientation * direction.normalized() * 0.90
	camera.look_at(center, orientation.y)

func toggle_voice() -> void:
	if voice.playing:
		stop_voice()
	else:
		restart_voice()

func restart_voice() -> void:
	stop_voice()
	_manual_open = false
	mouth.set_process(true)
	voice.play()
	_play_button.text = "FERMA"

func stop_voice() -> void:
	voice.stop()
	_manual_open = false
	mouth.set_process(true)
	mouth.reset_mouth()
	if _play_button != null:
		_play_button.text = "ASCOLTA PARLATO E RISATA"

func _set_body_animation(enabled: bool) -> void:
	_speaking_body = enabled
	var name: StringName = &"mie/talking1" if enabled else &"mie/breathing_idle"
	if not animation_player.has_animation(name):
		push_error("Preview animation missing: " + String(name))
		return
	animation_player.play(name)
	if not enabled:
		animation_player.seek(0.0, true)
		animation_player.pause()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or mouth == null:
		return
	match event.keycode:
		KEY_SPACE: toggle_voice()
		KEY_R: restart_voice()
		KEY_L:
			restart_voice()
			voice.seek(11.55)
		KEY_3:
			if _manual_open:
				head.set_blend_shape_value(1, 0.65 if head.get_blend_shape_value(1) == 0.0 else 0.0)
		KEY_4:
			if _manual_open:
				head.set_blend_shape_value(2, 0.85 if head.get_blend_shape_value(2) == 0.0 else 0.0)
		KEY_1: _quarter = false
		KEY_2: _quarter = true
		KEY_A: _set_body_animation(not _speaking_body)
		KEY_O:
			_compare_original = not _compare_original
			head.visible = not _compare_original
			original_head.visible = _compare_original
		KEY_M:
			var enabled := not _manual_open
			stop_voice()
			_manual_open = enabled
			mouth.set_process(not enabled)
	get_viewport().set_input_as_handled()
