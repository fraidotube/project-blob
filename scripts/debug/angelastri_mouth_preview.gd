extends Node3D

const CHARACTER := preload("res://scenes/enemies/angelastri.tscn")
const AUDIO_ROOT := "res://assets/models/enemies/Angelastri/"
const AUDIO_FILES := ["Angelastri_intro_vampire.mp3", "Angelastri_discorso_principale_vampire.mp3", "risata_vampire.mp3", "thriller.mp3"]
const DANCES: Array[StringName] = [&"mie/thrller_1", &"mie/thrller_2", &"mie/thrller_3", &"mie/thrller_4"]
@export var automatic_preview := true
@export var preview_main_dialogue := false
@export var map_presentation := false
signal presentation_loaded
signal combat_preview_ready
var world_motion: Array[Dictionary] = []
var world_motion_scale := 1.0
@export_range(0.0, 10.0, 0.1) var dance_start_delay := 1.0
@export_range(0.0, 20.0, 0.1) var intro_pointing_time := 12.0
@export_range(0.1, 2.0, 0.05) var rest_blend_seconds := 0.6
# Vocal entry supplied by the user, relative to the music (not the full intro).
@export_range(-1.0, 130.0, 0.1) var singing_start_seconds := 73.5
@export_range(0.0, 60.0, 0.1) var main_secret_start := 44.0
@export_range(0.1, 1.5, 0.05) var dialogue_blend_seconds := 0.55
var main_secret_end := 0.0
var presentation_stage := ""
var presentation_paused := false
var music_last_position := 0.0
var music_wrap_offset := 0.0
# Draft phrase timings: transcription has no timestamps. Editable in the preview.
const CUES := [
	[[0.0, "head_nod"], [2.0, "opening"], [5.0, "quick_bow"], [8.0, "risata"], [12.0, "pointing"], [15.6, "pointing2"], [18.0, "opening"]],
	[],
	[[0.0, "risata"]]
]
var model: Node3D
var component: Node
var head: MeshInstance3D
var original: MeshInstance3D
var animation: AnimationPlayer
var skeleton: Skeleton3D
var voice: AudioStreamPlayer
var main_dialogue_stream: AudioStream
var camera: Camera3D
var opening := 0.72
var rounded := false
var smiling := false
var manual := false
var quarter := false
var status: Label
var music: AudioStreamPlayer
var audio_index := 0
var sequence := false
var closeup := false
var orbit := 0.0
var zoom := 1.0
var cue_index := -1
var timeline: HSlider
var cue_time: SpinBox
var cue_selector: OptionButton
var clip_names: Array[StringName] = []
var draft_cues: Array = CUES.duplicate(true)

# Evaluate after the RMS controller. A mixed song has a nearly continuous
# envelope, so singing needs explicit articulation rather than a sustained jaw.
# This is stylized articulation, not phoneme recognition.
class SingingArticulation extends Node:
	var preview: Node
	var current_open := 0.0

	func _process(delta: float) -> void:
		if not is_instance_valid(preview.component) or not preview.component.ready_for_mouth: return
		var motion: Node = preview.component.motion
		if motion == null or preview.component.voice != preview.music:
			current_open = 0.0
			return
		var target := 0.0
		var articulation := 0.0
		if preview.music.playing and not preview.music.stream_paused and not get_tree().paused:
			var time: float = preview.music_sequence_position() - preview.singing_start_seconds
			var phase := time * TAU * 2.8 + 0.4 * sin(time * TAU * 0.7)
			articulation = pow(maxf(0.0, sin(phase)), 0.85)
			target = motion.current_open * articulation
		var duration := 0.03 if target > current_open else 0.045
		current_open = lerpf(current_open, target, 1.0 - exp(-delta / duration))
		if current_open < 0.0001: current_open = 0.0
		preview.component.set_expression(current_open, motion.current_round * articulation, motion.current_smile * articulation)

func _ready() -> void:
	draft_cues[0][4][0] = intro_pointing_time
	if not map_presentation: _studio_lighting()
	model = CHARACTER.instantiate() as Node3D
	add_child(model)
	head = model.get_node("sgt_Angelastri/Armature/GeneralSkeleton/mixamorig_Neck/Testa") as MeshInstance3D
	original = MeshInstance3D.new()
	original.name = "OriginalHeadComparison"
	original.mesh = head.mesh
	original.transform = head.transform
	original.hide()
	head.get_parent().add_child(original)
	component = model.get_node("MouthPresentation")
	voice = AudioStreamPlayer.new()
	voice.stream = load(AUDIO_ROOT + AUDIO_FILES[0])
	main_dialogue_stream = load(AUDIO_ROOT + AUDIO_FILES[1])
	voice.bus = &"SFX"
	add_child(voice)
	component.bind_voice(voice)
	music = AudioStreamPlayer.new()
	music.bus = &"Music"
	# Read the supplied MP3 directly so replacing it does not reuse an older import.
	var music_stream := AudioStreamMP3.new()
	music_stream.data = FileAccess.get_file_as_bytes(AUDIO_ROOT + AUDIO_FILES[3])
	music.stream = music_stream
	add_child(music)
	animation = model.get_node("sgt_Angelastri/AnimationPlayer") as AnimationPlayer
	_build_main_cues()
	draft_cues[0][5][0] = intro_pointing_time + animation.get_animation(&"mie/pointing").length
	draft_cues[0].sort_custom(func(a: Array, b: Array): return a[0] < b[0])
	skeleton = model.get_node("sgt_Angelastri/Armature/GeneralSkeleton") as Skeleton3D
	var source_library := animation.get_animation_library(&"mie")
	var library := AnimationLibrary.new()
	for name in source_library.get_animation_list():
		library.add_animation(name, source_library.get_animation(name).duplicate(true))
	animation.remove_animation_library(&"mie")
	animation.add_animation_library(&"mie", library)
	for clip in library.get_animation_list():
		library.get_animation(clip).loop_mode = Animation.LOOP_NONE
		clip_names.append(StringName("mie/" + String(clip)))
		print("ANGELASTRI_CLIP ", clip, " duration=", library.get_animation(clip).length)
	if map_presentation: _prepare_world_motion(library)
	elif preview_main_dialogue: _normalize_main_positions(library)
	library.get_animation(&"looking").loop_mode = Animation.LOOP_LINEAR
	animation.play(&"mie/looking")
	animation.seek(0, true)
	animation.pause()
	if not map_presentation:
		camera = Camera3D.new()
		camera.fov = 35
		camera.near = 0.01
		add_child(camera)
		camera.current = true
	await get_tree().process_frame
	if not map_presentation: _build_ui()
	var articulation := SingingArticulation.new()
	articulation.preview = self
	articulation.process_priority = 10
	articulation.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(articulation)
	if not map_presentation:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		AudioManager.fade_out_menu_music(0.1)
	print("ANGELASTRI_PREVIEW_READY")
	if automatic_preview: start_presentation()
	presentation_loaded.emit()

func _studio_lighting() -> void:
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("16141b")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("d2ccdf")
	environment.environment.ambient_light_energy = 0.55
	add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-25, -25, 0)
	light.light_energy = 1.0
	add_child(light)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size.x = 350
	layer.add_child(panel)
	var column := VBoxContainer.new()
	panel.add_child(column)
	if automatic_preview:
		var title := Label.new()
		title.text = "ANGELASTRI — DISCORSO PRINCIPALE" if preview_main_dialogue else "ANGELASTRI — INTRO E BALLETTO"
		column.add_child(title)
		_button(column, "Rivedi dall'inizio", start_presentation)
		_button(column, "Pausa / riprendi", toggle_presentation_pause)
		_button(column, "Figura intera / volto", func(): closeup = not closeup)
		status = Label.new()
		column.add_child(status)
		return
	var title := Label.new()
	title.text = "ANGELASTRI / MODELLO, VOCE E BALLETTO"
	column.add_child(title)
	var hint := Label.new()
	hint.text = "M: bocca manuale   3/4: O/sorriso   O: originale\n1/2: frontale / tre quarti   F: volto / figura intera\nTrascina col destro: ruota   Rotella: zoom\nSpazio: audio scelto   Tempi gesti: BOZZA da rifinire"
	column.add_child(hint)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 1
	slider.step = 0.01
	slider.value = opening
	slider.value_changed.connect(func(value: float): opening = value)
	column.add_child(slider)
	var selector := OptionButton.new()
	selector.add_item("Corpo fermo")
	for name in animation.get_animation_list():
		if String(name).begins_with("mie/"):
			selector.add_item("%s (%.2f s)" % [name, animation.get_animation(name).length])
			selector.set_item_metadata(selector.item_count - 1, name)
	selector.item_selected.connect(func(index: int):
		stop_sequence()
		if index == 0:
			animation.play(&"mie/looking")
			animation.seek(0, true)
			animation.pause()
		else: animation.play(selector.get_item_metadata(index))
	)
	column.add_child(selector)
	_button(column, "Riproduci / pausa clip", func():
		if animation.is_playing(): animation.pause()
		else: animation.play())
	_button(column, "Riavvia clip", func(): animation.seek(0, true); animation.play())
	var speed := SpinBox.new()
	speed.min_value = 0.25
	speed.max_value = 2.0
	speed.step = 0.05
	speed.value = 1.0
	speed.prefix = "Velocità clip "
	speed.value_changed.connect(func(value: float):
		if not sequence: animation.speed_scale = value)
	column.add_child(speed)
	timeline = HSlider.new()
	timeline.step = 0.01
	timeline.value_changed.connect(func(value: float):
		if not sequence: animation.seek(value, true))
	column.add_child(timeline)
	var audio_selector := OptionButton.new()
	for label in ["Intro", "Discorso principale", "Risata", "Thriller (solo musica)"]: audio_selector.add_item(label)
	audio_selector.item_selected.connect(func(index: int):
		stop_sequence()
		audio_index = index
		if index < 3: voice.stream = load(AUDIO_ROOT + AUDIO_FILES[index]))
	column.add_child(audio_selector)
	_button(column, "Avvia audio", play_audio)
	_button(column, "Leggi trascrizione del dialogo", func():
		if audio_index > 1: return
		var dialog := AcceptDialog.new()
		dialog.title = "Trascrizione — tempi dei gesti da verificare"
		dialog.dialog_text = FileAccess.get_file_as_string(AUDIO_ROOT + ("Angelastri_intro.txt" if audio_index == 0 else "Angelastri_discorso_principale.txt"))
		dialog.dialog_autowrap = true
		add_child(dialog)
		dialog.popup_centered(Vector2i(800, 400))
		dialog.confirmed.connect(dialog.queue_free)
		dialog.canceled.connect(dialog.queue_free))
	_button(column, "Dialogo + gesti / Balletto + Thriller", start_sequence)
	_button(column, "Pausa / riprendi sequenza", func():
		voice.stream_paused = not voice.stream_paused
		music.stream_paused = voice.stream_paused)
	_button(column, "Ferma audio e sequenza", stop_sequence)
	_button(column, "Figura intera / volto", func(): closeup = not closeup)
	_button(column, "Reset vista", func(): orbit = 0; zoom = 1; quarter = false)
	cue_selector = OptionButton.new()
	for clip in clip_names: cue_selector.add_item(clip)
	column.add_child(cue_selector)
	cue_time = SpinBox.new()
	cue_time.max_value = 120
	cue_time.step = 0.1
	cue_time.prefix = "Cue a secondi "
	column.add_child(cue_time)
	_button(column, "Aggiungi/sostituisci cue (solo questa sessione)", func():
		if audio_index >= 3: return
		var cues: Array = draft_cues[audio_index]
		for i in range(cues.size() - 1, -1, -1):
			if absf(float(cues[i][0]) - cue_time.value) < 0.05: cues.remove_at(i)
		cues.append([cue_time.value, String(clip_names[cue_selector.selected]).trim_prefix("mie/")])
		cues.sort_custom(func(a: Array, b: Array): return a[0] < b[0])
		cue_index = -1
		print("ANGELASTRI_DRAFT_CUES ", audio_index, " ", JSON.stringify(cues)))
	status = Label.new()
	column.add_child(status)

func _button(parent: Node, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)

func play_audio() -> void:
	stop_sequence()
	music.volume_db = 0.0
	music.stream.loop = false
	music_last_position = 0.0
	music_wrap_offset = 0.0
	if audio_index == 3: music.play()
	else: voice.play()

func start_sequence() -> void:
	play_audio()
	if audio_index == 3: music.stream.loop = dance_start_delay + dance_duration() > music.stream.get_length()
	sequence = true
	cue_index = -1
	animation.speed_scale = 1.0

func start_presentation() -> void:
	audio_index = 1 if preview_main_dialogue else 0
	voice.stream = main_dialogue_stream if preview_main_dialogue else load(AUDIO_ROOT + AUDIO_FILES[audio_index])
	voice.volume_db = 6.0 if preview_main_dialogue else 0.0
	if preview_main_dialogue:
		# Patrol loops idle_new on this same private library. The dialogue tail
		# must finish the clip once before talk_to_combat and the fight handoff.
		animation.get_animation(&"mie/idle_new").loop_mode = Animation.LOOP_NONE
		animation.get_animation(&"mie/talk_to_combat").loop_mode = Animation.LOOP_NONE
	start_sequence()
	presentation_stage = "main_dialogue" if preview_main_dialogue else "intro"
	presentation_paused = false
	if preview_main_dialogue:
		animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE
	closeup = false
	zoom = 1.0
	quarter = false
	orbit = 0.0
	head.show()
	original.hide()
	sync_sequence(0.0)
	print("ANGELASTRI_PRESENTATION ", presentation_stage)

func toggle_presentation_pause() -> void:
	presentation_paused = not presentation_paused
	voice.stream_paused = presentation_paused
	music.stream_paused = presentation_paused
	if presentation_stage in ["rest", "main_dialogue", "finish_idle", "prepare_combat"]:
		if presentation_paused: animation.pause()
		else: animation.play()

func advance_presentation() -> void:
	if presentation_stage == "intro":
		audio_index = 3
		start_sequence()
		presentation_stage = "dance"
		sync_sequence(0.0)
		print("ANGELASTRI_PRESENTATION dance")
	elif presentation_stage == "main_dialogue":
		stop_voice()
		sequence = false
		if map_presentation:
			# Voice completion starts the camera return immediately. This short
			# transition plays during the return, instead of an eight-second idle.
			presentation_stage = "combat_ready"
			animation.play(&"mie/talk_to_combat", dialogue_blend_seconds)
			combat_preview_ready.emit()
			return
		presentation_stage = "finish_idle"
		_play_main_clip(&"mie/idle_new")
	elif presentation_stage == "dance":
		if map_presentation: _apply_world_motion(dance_start_delay + dance_duration())
		stop_sequence()
		presentation_stage = "rest"
		# Rest runs continuously: the engine can now advance the blend normally.
		animation.play(&"mie/looking", rest_blend_seconds)
		print("ANGELASTRI_PRESENTATION rest")

func stop_sequence() -> void:
	presentation_stage = ""
	presentation_paused = false
	sequence = false
	stop_voice()
	music.stop()
	music.stream_paused = false
	animation.pause()
	animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_IDLE

func _build_main_cues() -> void:
	# Complete each gesture before changing; retain the salute near the name.
	var time := 0.0
	draft_cues[1] = []
	for name in ["talking2", "pointing", "angry_point", "talking", "talking2", "talking", "salute", "pointing2", "talking3", "talking2", "angry_point"]:
		draft_cues[1].append([time, name])
		time += animation.get_animation("mie/" + name).length
	draft_cues[1].append([maxf(main_secret_start, time), "talking_secret"])
	main_secret_end = load(AUDIO_ROOT + AUDIO_FILES[1]).get_length()

func _play_main_clip(clip: StringName) -> void:
	if animation.assigned_animation != clip:
		if presentation_stage == "main_dialogue" and animation.is_playing() and animation.current_animation_position < animation.current_animation_length - 0.025: return
		animation.play(clip, dialogue_blend_seconds)

func _normalize_main_positions(library: AnimationLibrary) -> void:
	# Only private spoken clips are stationary; dance tracks retain all motion.
	var names: Array[String] = ["idle_new", "talk_to_combat", "looking"]
	for cue: Array in draft_cues[1]:
		if not names.has(cue[1]): names.append(cue[1])
	var bone := skeleton.get_bone_name(0)
	for name in names:
		var clip := library.get_animation(name)
		for track in clip.get_track_count():
			var path := clip.track_get_path(track)
			if clip.track_get_type(track) != Animation.TYPE_POSITION_3D or path.get_subname_count() == 0 or path.get_subname(0) != bone: continue
			for key in clip.track_get_key_count(track):
				var position: Vector3 = clip.track_get_key_value(track, key)
				position.x = 0.0
				position.z = 0.0
				clip.track_set_key_value(track, key, position)
			print("ANGELASTRI_STATIONARY_CLIP ", name)

func _main_tail(_delta: float) -> void:
	if presentation_paused: return
	var clip: StringName = &"mie/idle_new" if presentation_stage == "finish_idle" else &"mie/talk_to_combat"
	if animation.assigned_animation == clip and not animation.is_playing():
		if presentation_stage == "finish_idle":
			presentation_stage = "prepare_combat"
			_play_main_clip(&"mie/talk_to_combat")
		else:
			presentation_stage = "combat_ready"
			animation.pause()
			combat_preview_ready.emit()
			print("ANGELASTRI_PREVIEW_COMBAT_READY")

func sync_sequence(time: float) -> void:
	if presentation_stage == "main_dialogue":
		var cues: Array = draft_cues[1]
		var index := 0
		for i in cues.size():
			if time >= float(cues[i][0]): index = i
		cue_index = index
		var clip := StringName("mie/" + String(cues[index][1]))
		_play_main_clip(clip)
		return
	var clip: StringName
	var local_time := 0.0
	if audio_index == 3:
		var total := dance_start_delay + dance_duration()
		music.volume_db = linear_to_db(clampf((total - time) / 1.0, 0.001, 1.0))
		if time >= total:
			if presentation_stage == "dance": advance_presentation()
			else:
				stop_sequence()
				animation.play(&"mie/looking", rest_blend_seconds)
			return
		update_singing(time)
		if map_presentation: _apply_world_motion(time)
		if time < dance_start_delay:
			clip = &"mie/looking"
			local_time = fmod(time, animation.get_animation(clip).length)
		else:
			local_time = time - dance_start_delay
			for dance in DANCES:
				clip = dance
				var duration := animation.get_animation(dance).length
				if local_time < duration: break
				local_time -= duration
	else:
		var cues: Array = draft_cues[audio_index]
		var index := 0
		for i in cues.size():
			if time >= float(cues[i][0]): index = i
		cue_index = index
		clip = StringName("mie/" + String(cues[index][1]))
		local_time = time - float(cues[index][0])
		if clip in [&"mie/talk_to_combat", &"mie/talking", &"mie/talking2", &"mie/talking3"]:
			local_time = fmod(local_time, animation.get_animation(clip).length)
		elif presentation_stage == "main_dialogue":
			var gesture_duration := animation.get_animation(clip).length
			if clip == &"mie/looking":
				local_time = fmod(local_time, gesture_duration)
			elif local_time >= gesture_duration:
				clip = &"mie/talking"
				local_time = fmod(local_time - gesture_duration, animation.get_animation(clip).length)
		if presentation_stage == "main_dialogue" and time >= main_secret_start and time < main_secret_end:
			clip = &"mie/talking_secret"
			local_time = minf(time - main_secret_start, animation.get_animation(clip).length)
	if presentation_stage == "main_dialogue": component.motion.laughing = clip == &"mie/risata"
	# A paused blend never progresses, so it keeps displaying the previous pose.
	# Audio drives pose time directly: switch without a pending AnimationPlayer blend.
	if animation.assigned_animation != clip: animation.play(clip, 0.0)
	animation.seek(minf(local_time, animation.get_animation(clip).length), true)
	animation.pause()

func update_singing(time: float) -> void:
	var singing := singing_start_seconds >= 0.0 and time >= singing_start_seconds
	var source := music if singing else voice
	if component.voice != source: component.bind_voice(source)

func dance_duration() -> float:
	var total := 0.0
	for dance in DANCES: total += animation.get_animation(dance).length
	return total

func music_sequence_position() -> float:
	var position := music.get_playback_position()
	if position < music_last_position - 1.0:
		music_wrap_offset += music.stream.get_length()
	music_last_position = position
	return music_wrap_offset + position

func _process(delta: float) -> void:
	if head == null or not component.ready_for_mouth: return
	if sequence and not presentation_paused:
		var player := music if audio_index == 3 else voice
		if player.playing:
			sync_sequence(music_sequence_position() if audio_index == 3 else player.get_playback_position())
		elif presentation_stage in ["intro", "dance", "main_dialogue"]: advance_presentation()
		else: stop_sequence()
	if presentation_stage in ["finish_idle", "prepare_combat"]: _main_tail(delta)
	if manual: component.set_expression(opening, 0.65 if rounded else 0, 0.85 if smiling else 0)
	if map_presentation: return
	var hips := skeleton.global_transform * skeleton.get_bone_global_pose(0).origin
	var center := head.global_transform * Vector3(0, -0.025, 0) if closeup else hips + Vector3(0, 0.1, 0)
	var orientation := head.global_basis.orthonormalized() if closeup else Basis.IDENTITY
	var direction := Vector3(0.45, 0.02, 1) if quarter else Vector3(0, 0.02, 1)
	direction = direction.rotated(Vector3.UP, orbit)
	camera.global_position = center + orientation * direction.normalized() * (0.78 if closeup else 4.8) * zoom
	camera.look_at(center, orientation.y)
	if timeline != null and not animation.assigned_animation.is_empty():
		timeline.max_value = animation.current_animation_length
		timeline.set_value_no_signal(animation.current_animation_position)
	if status != null:
		if automatic_preview:
			status.text = "%s%s\n%s" % [{"intro": "Introduzione", "main_dialogue": "Discorso principale", "dance": "Balletto", "rest": "Attesa / looking", "finish_idle": "Fine dialogo / nuovo idle", "prepare_combat": "Preparazione al combattimento", "combat_ready": "Punto di avvio combattimento"}.get(presentation_stage, "Fermo"), " — pausa" if presentation_paused else "", animation.assigned_animation]
		else:
			status.text = "%s  %.2f s\nAudio %.2f s / Bocca %.2f\nCue BOZZA %d" % [animation.assigned_animation, animation.current_animation_position, music.get_playback_position() if audio_index == 3 else voice.get_playback_position(), head.get_blend_shape_value(0), cue_index]

func stop_voice() -> void:
	voice.stop()
	voice.stream_paused = false
	if component.voice != voice: component.bind_voice(voice)
	component.motion.reset_mouth()
	component.motion.laughing = false
	component.motion.set_process(true)
	manual = false
	rounded = false
	smiling = false

func _unhandled_input(event: InputEvent) -> void:
	if map_presentation: return
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		orbit -= event.relative.x * 0.01
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: zoom = maxf(0.3, zoom * 0.9)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: zoom = minf(3.0, zoom * 1.1)
	if not event is InputEventKey or not event.pressed or event.echo or not component.ready_for_mouth: return
	match event.keycode:
		KEY_SPACE:
			if automatic_preview: toggle_presentation_pause()
			elif voice.playing or music.playing: stop_sequence()
			else: play_audio()
		KEY_M:
			var enabled := not manual
			stop_sequence()
			manual = enabled
			component.motion.set_process(not manual)
		KEY_1: quarter = false
		KEY_2: quarter = true
		KEY_F: closeup = not closeup
		KEY_3: rounded = not rounded
		KEY_4: smiling = not smiling
		KEY_O:
			head.visible = not head.visible
			original.visible = not head.visible
	get_viewport().set_input_as_handled()

func _prepare_world_motion(library: AnimationLibrary) -> void:
	var bone := skeleton.get_bone_name(0)
	var prefix := Vector3.ZERO
	for dance in DANCES:
		var clip := library.get_animation(String(dance).trim_prefix("mie/"))
		for track in clip.get_track_count():
			var path := clip.track_get_path(track)
			if clip.track_get_type(track) != Animation.TYPE_POSITION_3D or path.get_subname_count() == 0 or path.get_subname(0) != bone: continue
			var start := clip.position_track_interpolate(track, 0.0)
			var end := clip.position_track_interpolate(track, clip.length)
			world_motion.append({"curve": clip.duplicate(true), "track": track, "start": start, "prefix": prefix})
			prefix += Vector3(end.x - start.x, 0, end.z - start.z)
			break
	# Transfer horizontal travel from the hips to the actual model node.
	for name in library.get_animation_list():
		var clip := library.get_animation(name)
		for track in clip.get_track_count():
			var path := clip.track_get_path(track)
			if clip.track_get_type(track) != Animation.TYPE_POSITION_3D or path.get_subname_count() == 0 or path.get_subname(0) != bone: continue
			for key in clip.track_get_key_count(track):
				var value: Vector3 = clip.track_get_key_value(track, key)
				value.x = 0.0
				value.z = 0.0
				clip.track_set_key_value(track, key, value)

func world_motion_offset(time: float) -> Vector3:
	var local_time := maxf(time - dance_start_delay, 0.0)
	for i in world_motion.size():
		var data: Dictionary = world_motion[i]
		var curve: Animation = data.curve
		if local_time < curve.length or i == world_motion.size() - 1:
			var point := curve.position_track_interpolate(data.track, minf(local_time, curve.length))
			var start: Vector3 = data.start
			return data.prefix + Vector3(point.x - start.x, 0, point.z - start.z)
		local_time -= curve.length
	return Vector3.ZERO

func _apply_world_motion(time: float) -> void:
	model.position = world_motion_offset(time) * world_motion_scale
	var point := model.global_position
	var query := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 2.0, point - Vector3.UP * 3.0, 1)
	var player := get_tree().get_first_node_in_group("player") as CollisionObject3D
	query.exclude = [model.get_rid()]
	if player != null: query.exclude = [player.get_rid(), model.get_rid()]
	var floor_hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not floor_hit.is_empty() and floor_hit.normal.y > 0.7:
		model.global_position.y = floor_hit.position.y
