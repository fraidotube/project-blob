extends CanvasLayer

var overlay: ColorRect
var panel: VBoxContainer
var title_label: Label
var progress_bar: ProgressBar
var percent_label: Label
var spinner_label: Label

var _busy := false
var _spinner_phase := 0.0


func _ready() -> void:
	layer = 10000
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return

	_spinner_phase += delta * 5.0

	var frames := [
		"● ○ ○",
		"○ ● ○",
		"○ ○ ●"
	]

	spinner_label.text = frames[
		int(_spinner_phase) % frames.size()
	]


func _build_ui() -> void:
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	overlay.color = Color(0.0, 0.0, 0.0, 1.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	panel = VBoxContainer.new()
	panel.set_anchors_preset(
		Control.PRESET_CENTER
	)
	panel.position = Vector2(-210.0, -70.0)
	panel.size = Vector2(420.0, 140.0)
	panel.add_theme_constant_override(
		"separation",
		10
	)
	overlay.add_child(panel)

	title_label = Label.new()
	title_label.text = "CARICAMENTO"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override(
		"font_size",
		28
	)
	panel.add_child(title_label)

	spinner_label = Label.new()
	spinner_label.text = "● ○ ○"
	spinner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spinner_label.add_theme_color_override(
		"font_color",
		Color(0.80, 0.25, 1.0, 1.0)
	)
	spinner_label.add_theme_font_size_override(
		"font_size",
		22
	)
	panel.add_child(spinner_label)

	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(
		420.0,
		14.0
	)
	panel.add_child(progress_bar)

	percent_label = Label.new()
	percent_label.text = "0%"
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(percent_label)


func cover_black() -> void:
	visible = true
	overlay.modulate.a = 1.0
	panel.visible = false


func reveal(
	duration: float = 0.35
) -> void:
	visible = true
	overlay.modulate.a = 1.0

	var tween := create_tween()
	tween.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)

	tween.tween_property(
		overlay,
		"modulate:a",
		0.0,
		duration
	)

	await tween.finished
	visible = false
	overlay.modulate.a = 1.0


func transition_to(
	scene_path: String,
	show_loading: bool = true
) -> void:
	if _busy:
		return

	if not ResourceLoader.exists(scene_path):
		push_error(
			"SceneTransition: scena non trovata: "
			+ scene_path
		)
		return

	_busy = true
	visible = true
	overlay.modulate.a = 0.0
	panel.visible = show_loading
	progress_bar.value = 0.0
	percent_label.text = "0%"

	var fade_in := create_tween()
	fade_in.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)
	fade_in.tween_property(
		overlay,
		"modulate:a",
		1.0,
		0.22
	)
	await fade_in.finished

	var error := ResourceLoader.load_threaded_request(
		scene_path
	)

	if error != OK:
		push_error(
			"SceneTransition: errore richiesta caricamento: "
			+ str(error)
		)
		_busy = false
		return

	var progress := []
	var status := ResourceLoader.THREAD_LOAD_IN_PROGRESS

	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		status = ResourceLoader.load_threaded_get_status(
			scene_path,
			progress
		)

		if progress.size() > 0:
			var pct := clampf(
				float(progress[0]) * 100.0,
				0.0,
				100.0
			)
			progress_bar.value = pct
			percent_label.text = "%d%%" % roundi(pct)

		await get_tree().process_frame

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_error(
			"SceneTransition: caricamento fallito, stato "
			+ str(status)
		)
		_busy = false
		return

	progress_bar.value = 100.0
	percent_label.text = "100%"

	var packed := ResourceLoader.load_threaded_get(
		scene_path
	) as PackedScene

	if packed == null:
		push_error(
			"SceneTransition: risorsa non è PackedScene"
		)
		_busy = false
		return

	# L'instanziazione può richiedere ancora qualche millisecondo,
	# ma avviene interamente dietro lo schermo nero.
	var next_scene := packed.instantiate()

	var current := get_tree().current_scene

	if current != null:
		current.queue_free()

	get_tree().root.add_child(next_scene)
	get_tree().current_scene = next_scene

	await get_tree().process_frame
	await get_tree().process_frame

	panel.visible = false

	var fade_out := create_tween()
	fade_out.set_pause_mode(
		Tween.TWEEN_PAUSE_PROCESS
	)
	fade_out.tween_property(
		overlay,
		"modulate:a",
		0.0,
		0.38
	)
	await fade_out.finished

	visible = false
	overlay.modulate.a = 1.0
	_busy = false
