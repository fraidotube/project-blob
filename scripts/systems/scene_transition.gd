extends CanvasLayer

const MENU_THEME := preload("res://scenes/ui/project_blob_menu_theme.tres")
const FRAME := preload("res://scripts/ui/blob_inventory_panel.gd")
const BLOB := preload("res://scripts/ui/loading_blob.gd")
var overlay: ColorRect
var panel: VBoxContainer
var title_label: Label
var progress_bar: ProgressBar
var percent_label: Label
var spinner_label: Label
var _card: Control
var _busy := false
var _target := 0.0
var _started := 0
var _saved_master_mute := false
var _loading_audio_muted := false

func _ready() -> void:
	layer = 10000
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	progress_bar.value = move_toward(progress_bar.value, _target, delta * 90.0)
	percent_label.text = "%d%%" % roundi(progress_bar.value)

func _build_ui() -> void:
	overlay = ColorRect.new()
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color("07050d")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_card = Control.new()
	_card.set_script(FRAME)
	_card.set("show_decorations", false)
	_card.theme = MENU_THEME
	overlay.add_child(_card)
	panel = VBoxContainer.new()
	panel.position = Vector2(48, 52)
	panel.size = Vector2(564, 396)
	panel.add_theme_constant_override("separation", 14)
	_card.add_child(panel)
	var brand := Label.new()
	brand.text = "PROJECT BLOB"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_font_size_override("font_size", 22)
	brand.add_theme_color_override("font_color", Color("aa72c7"))
	panel.add_child(brand)
	var blob := Control.new()
	blob.set_script(BLOB)
	blob.custom_minimum_size = Vector2(0, 170)
	panel.add_child(blob)
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color("f4eafa"))
	panel.add_child(title_label)
	spinner_label = Label.new()
	spinner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spinner_label.add_theme_font_size_override("font_size", 18)
	spinner_label.add_theme_color_override("font_color", Color("bbaac8"))
	panel.add_child(spinner_label)
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(0, 10)
	for style_name in ["background", "fill"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("24182e") if style_name == "background" else Color("b14cdb")
		style.set_corner_radius_all(5)
		progress_bar.add_theme_stylebox_override(style_name, style)
	panel.add_child(progress_bar)
	percent_label = Label.new()
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent_label.add_theme_font_size_override("font_size", 20)
	percent_label.add_theme_color_override("font_color", Color("70ddeb"))
	panel.add_child(percent_label)
	overlay.resized.connect(_layout)
	_layout()

func _layout() -> void:
	var factor := clampf(minf(overlay.size.x / 720.0, overlay.size.y / 560.0), 0.2, 1.0)
	_card.size = Vector2(660, 500)
	_card.scale = Vector2.ONE * factor
	_card.position = (overlay.size - _card.size * factor) * 0.5

func cover_black() -> void:
	visible = true
	overlay.modulate.a = 1.0
	_card.visible = false

func set_stage(value: float, caption: String) -> void:
	_target = value
	spinner_label.text = caption

func cancel_loading() -> void:
	visible = false
	overlay.modulate.a = 1.0
	_busy = false
	if _loading_audio_muted:
		AudioServer.set_bus_mute(0, _saved_master_mute)
		_loading_audio_muted = false

func reveal(duration: float = 0.35) -> void:
	if _card.visible and _busy:
		set_stage(100.0, "Pronto")
		while progress_bar.value < 99.9 or Time.get_ticks_msec() - _started < 700:
			await get_tree().process_frame
		await get_tree().create_timer(0.12, true).timeout
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(overlay, "modulate:a", 0.0, duration)
	await tween.finished
	cancel_loading()

# Leaves the scene covered until the caller has finished initialization/restoration.
func load_scene(scene_path: String, caption: String, show_loading: bool = true, mute_loading_audio: bool = true) -> PackedScene:
	if _busy:
		return null
	if not ResourceLoader.exists(scene_path):
		push_error("SceneTransition: scena non trovata: " + scene_path)
		return null
	_busy = true
	if mute_loading_audio:
		_saved_master_mute = AudioServer.is_bus_mute(0)
		_loading_audio_muted = true
		AudioServer.set_bus_mute(0, true)
	_started = Time.get_ticks_msec()
	visible = true
	_card.visible = show_loading
	panel.visible = true
	overlay.modulate.a = 0.0
	progress_bar.value = 0.0
	title_label.text = caption
	set_stage(0.0, "Caricamento in corso")
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.22)
	await tween.finished
	var error := ResourceLoader.load_threaded_request(scene_path)
	if error != OK:
		push_error("SceneTransition: richiesta fallita: " + str(error))
		cancel_loading()
		return null
	var progress: Array = []
	var status := ResourceLoader.THREAD_LOAD_IN_PROGRESS
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		status = ResourceLoader.load_threaded_get_status(scene_path, progress)
		if not progress.is_empty():
			_target = clampf(float(progress[0]) * 88.0, 0.0, 88.0)
		await get_tree().process_frame
	if status != ResourceLoader.THREAD_LOAD_LOADED:
		push_error("SceneTransition: caricamento fallito: " + str(status))
		cancel_loading()
		return null
	var packed := ResourceLoader.load_threaded_get(scene_path) as PackedScene
	if packed == null:
		push_error("SceneTransition: risorsa non PackedScene")
		cancel_loading()
		return null
	set_stage(90.0, "Preparazione della partita")
	return packed

## Il boot conserva la musica continua; il gameplay silenzia la preparazione per default.
func transition_to(scene_path: String, show_loading: bool = true, mute_loading_audio: bool = true) -> void:
	var packed := await load_scene(scene_path, "NUOVA PARTITA", show_loading, mute_loading_audio)
	if packed == null:
		return
	var was_paused := get_tree().paused
	get_tree().paused = true
	if get_tree().change_scene_to_packed(packed) != OK:
		get_tree().paused = was_paused
		cancel_loading()
		return
	await get_tree().process_frame
	await get_tree().process_frame
	await wait_scene_initialization()
	await prepare_scene_for_reveal()
	await reveal()
	get_tree().paused = was_paused

## Le scene possono registrare componenti nel gruppo scene_loading_preparation.
## Non fa avanzare il gameplay mentre SaveManager mantiene l'albero in pausa.
func wait_scene_initialization() -> void:
	for component in get_tree().get_nodes_in_group("scene_loading_preparation"):
		if component.has_method("wait_for_initialization"):
			await component.wait_for_initialization()

func prepare_scene_for_reveal() -> void:
	set_stage(97.0, "Preparazione audio ed effetti")
	for component in get_tree().get_nodes_in_group("scene_loading_preparation"):
		if component.has_method("prepare_for_reveal"):
			await component.prepare_for_reveal()
	# Render the prepared scene under the opaque overlay before fading it out.
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
