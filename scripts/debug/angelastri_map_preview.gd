extends Node

const PRESENTATION := preload("res://scripts/debug/angelastri_mouth_preview.gd")
@export var enabled := false
var presentation: Node3D
var busy := false
var generation := 0
var warmed := false
var background_music: AudioStreamPlayer
var background_was_paused := false
var background_held := false
var menu_music: AudioStreamPlayer
var menu_was_paused := false
var menu_held := false

func _ready() -> void:
	SaveManager.restore_completed.connect(clear_preview)
	print("ANGELASTRI_MAP_READY debug_keys=", enabled)

func _unhandled_input(event: InputEvent) -> void:
	if not enabled or get_tree().paused or not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode not in [KEY_F10, KEY_F11, KEY_F12]: return
	if event.keycode == KEY_F12:
		clear_preview()
	else:
		var player := get_parent().get_node("Player")
		if busy or bool(player.get("is_dead")) or not player.is_physics_processing(): return
		spawn_preview(event.keycode == KEY_F11)
	get_viewport().set_input_as_handled()

func warmup_presentation() -> void:
	if busy or is_instance_valid(presentation): return
	var scene := get_parent() as Node3D
	var marker := scene.find_child("Angelastri", true, false) as Node3D
	if marker == null: return
	busy = true
	var request := generation
	await get_tree().process_frame
	if not is_inside_tree() or request != generation: return
	var point := marker.global_position
	var ray := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 2.0, point - Vector3.UP * 3.0, 1)
	var player_body := scene.get_node("Player") as CollisionObject3D
	ray.exclude = [player_body.get_rid()]
	if is_instance_valid(presentation) and is_instance_valid(presentation.model):
		ray.exclude = [player_body.get_rid(), presentation.model.get_rid()]
	var floor_hit := scene.get_world_3d().direct_space_state.intersect_ray(ray)
	if floor_hit.is_empty() or floor_hit.normal.y < 0.7:
		busy = false
		return
	point.y = floor_hit.position.y
	var direction := marker.global_basis.z
	var yaw := atan2(direction.x, direction.z)
	presentation = PRESENTATION.new()
	presentation.name = "AngelastriPrewarmedPresentation"
	presentation.map_presentation = true
	presentation.automatic_preview = false
	presentation.preview_main_dialogue = false
	presentation.visible = false
	presentation.transform = scene.global_transform.affine_inverse() * Transform3D(Basis(Vector3.UP, yaw), point)
	presentation.presentation_loaded.connect(func():
		busy = false
		warmed = true
	, CONNECT_ONE_SHOT)
	scene.add_child(presentation)

func spawn_preview(main_dialogue: bool = false, automatic: bool = true, face_player: bool = true) -> void:
	var scene := get_parent() as Node3D
	var marker := scene.find_child("Angelastri", true, false) as Node3D
	if marker == null:
		GameplayUI.notify("Angelastri: salva nella mappa il marker Angelastri.")
		return
	var point := marker.global_position
	if main_dialogue and is_instance_valid(presentation):
		point = presentation.model.global_position
	var player := scene.get_node("Player") as Node3D
	var direction := player.global_position - point
	if not face_player: direction = marker.global_basis.z
	var yaw := atan2(direction.x, direction.z)
	var reuse := is_instance_valid(presentation) and is_instance_valid(presentation.model) and not busy
	if not reuse:
		clear_preview()
	busy = true
	var request := generation
	await get_tree().process_frame
	if not is_inside_tree() or request != generation: return
	var ray := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 2.0, point - Vector3.UP * 3.0, 1)
	var player_body := scene.get_node("Player") as CollisionObject3D
	ray.exclude = [player_body.get_rid()]
	if is_instance_valid(presentation) and is_instance_valid(presentation.model):
		ray.exclude = [player_body.get_rid(), presentation.model.get_rid()]
	var floor_hit := scene.get_world_3d().direct_space_state.intersect_ray(ray)
	if floor_hit.is_empty() or floor_hit.normal.y < 0.7:
		busy = false
		GameplayUI.notify("Angelastri: punto di prova senza pavimento.")
		return
	point.y = floor_hit.position.y
	if reuse and is_instance_valid(presentation):
		_hold_background_music()
		presentation.map_presentation = true
		presentation.automatic_preview = automatic
		presentation.preview_main_dialogue = main_dialogue
		presentation.global_transform = Transform3D(Basis(Vector3.UP, yaw), point)
		presentation.model.transform = Transform3D.IDENTITY
		presentation.visible = true
		warmed = false
		busy = false
		if automatic: presentation.start_presentation()
		print("ANGELASTRI_MAP_USE_PREWARMED main=", main_dialogue, " position=", point)
		return
	_hold_background_music()
	presentation = PRESENTATION.new()
	presentation.name = "AngelastriTestPresentation"
	presentation.map_presentation = true
	presentation.automatic_preview = automatic
	presentation.preview_main_dialogue = main_dialogue
	presentation.transform = scene.global_transform.affine_inverse() * Transform3D(Basis(Vector3.UP, yaw), point)
	presentation.presentation_loaded.connect(func():
		busy = false
		if enabled: GameplayUI.notify("Angelastri: discorso principale" if main_dialogue else "Angelastri: intro e balletto — F11 discorso / F12 rimuovi"), CONNECT_ONE_SHOT)
	scene.add_child(presentation)
	print("ANGELASTRI_MAP_SPAWN main=", main_dialogue, " position=", point)

func clear_preview() -> void:
	generation += 1
	busy = false
	if is_instance_valid(presentation):
		presentation.queue_free()
	presentation = null
	warmed = false
	_release_background_music()

func _hold_background_music() -> void:
	if background_held: return
	menu_music = AudioManager.music_player
	if is_instance_valid(menu_music):
		menu_was_paused = menu_music.stream_paused
		menu_music.stream_paused = true
		menu_held = true
	background_music = get_parent().get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if background_music == null: return
	background_was_paused = background_music.stream_paused
	background_music.stream_paused = true
	background_held = true

func _release_background_music() -> void:
	if menu_held and is_instance_valid(menu_music):
		menu_music.stream_paused = menu_was_paused
	menu_held = false
	if background_held and is_instance_valid(background_music):
		background_music.stream_paused = background_was_paused
	background_held = false

func _process(_delta: float) -> void:
	if is_instance_valid(presentation):
		var player := get_parent().get_node_or_null("Player")
		if player == null or bool(player.get("is_dead")): clear_preview()
		elif presentation.presentation_stage in ["rest", "combat_ready"]: _release_background_music()
		else:
			if background_held and is_instance_valid(background_music): background_music.stream_paused = true
			if menu_held and is_instance_valid(menu_music): menu_music.stream_paused = true

func _exit_tree() -> void:
	clear_preview()
