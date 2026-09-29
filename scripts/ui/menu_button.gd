extends Button

@export var hover_scale := 1.025
@export var hover_shift := 8.0
@export var animation_time := 0.12

@export var label_visible_height := 34.0
@export_range(0.0, 1.0, 0.01) var alpha_threshold := 0.04

const UI_HOVER := preload(
	"res://assets/audio/ui/ui_hover.wav"
)

const UI_CLICK := preload(
	"res://assets/audio/ui/ui_click.wav"
)

const UI_BACK := preload(
	"res://assets/audio/ui/ui_back.wav"
)

var base_scale := Vector2.ONE
var base_position := Vector2.ZERO
var hover_tween: Tween

var label_image: TextureRect
var normal_texture: Texture2D
var selected_texture: Texture2D

var normal_display_texture: Texture2D
var selected_display_texture: Texture2D

var normal_display_size := Vector2.ZERO
var selected_display_size := Vector2.ZERO

var original_text := ""

var hover_player: AudioStreamPlayer
var click_player: AudioStreamPlayer


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	base_scale = scale
	base_position = position
	original_text = text.strip_edges().to_upper()

	_create_ui_audio_players()

	resized.connect(_update_pivot)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

	_update_pivot()
	_setup_image_label()


func _create_ui_audio_players() -> void:
	hover_player = AudioStreamPlayer.new()
	hover_player.name = "UIHoverAudio"
	hover_player.bus = &"UI"
	hover_player.stream = UI_HOVER
	hover_player.volume_db = -4.0
	add_child(hover_player)

	click_player = AudioStreamPlayer.new()
	click_player.name = "UIClickAudio"
	click_player.bus = &"UI"
	click_player.volume_db = -2.0
	add_child(click_player)


func _play_hover_sound() -> void:
	if hover_player == null:
		return

	hover_player.stop()
	hover_player.play()


func _play_click_sound() -> void:
	if click_player == null:
		return

	if original_text in [
		"INDIETRO",
		"MENU PRINCIPALE",
		"ESCI"
	]:
		click_player.stream = UI_BACK
	else:
		click_player.stream = UI_CLICK

	click_player.stop()
	click_player.play()


func _setup_image_label() -> void:
	var texture_paths := _get_texture_paths(original_text)

	if texture_paths.is_empty():
		return

	var normal_path: String = texture_paths["normal"]
	var selected_path: String = texture_paths["selected"]

	if not ResourceLoader.exists(normal_path):
		return

	normal_texture = load(normal_path)

	if ResourceLoader.exists(selected_path):
		selected_texture = load(selected_path)
	else:
		selected_texture = normal_texture

	var normal_bounds := _get_visible_bounds(normal_texture)
	var selected_bounds := _get_visible_bounds(selected_texture)

	if normal_bounds.size.y <= 0:
		return

	var pixel_scale := (
		label_visible_height
		/ float(normal_bounds.size.y)
	)

	normal_display_texture = _make_cropped_texture(
		normal_texture,
		normal_bounds
	)

	selected_display_texture = _make_cropped_texture(
		selected_texture,
		selected_bounds
	)

	normal_display_size = Vector2(
		normal_bounds.size
	) * pixel_scale

	selected_display_size = Vector2(
		selected_bounds.size
	) * pixel_scale

	text = ""

	label_image = TextureRect.new()
	label_image.name = "ImageLabel"
	label_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	label_image.stretch_mode = TextureRect.STRETCH_SCALE
	label_image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

	add_child(label_image)

	_refresh_image()


func _get_texture_paths(label: String) -> Dictionary:
	match label:
		"NUOVA PARTITA":
			return {
				"normal":
					"res://assets/ui/nuova_partita.png",
				"selected":
					"res://assets/ui/nuova_partita_blob.png"
			}

		"OPZIONI":
			return {
				"normal":
					"res://assets/ui/opzioni.png",
				"selected":
					"res://assets/ui/opzioni_blob.png"
			}

		"ESCI":
			return {
				"normal":
					"res://assets/ui/esci.png",
				"selected":
					"res://assets/ui/esci_blob.png"
			}

		"APPLICA":
			return {
				"normal":
					"res://assets/ui/applica.png",
				"selected":
					"res://assets/ui/applica_blob.png"
			}

		"INDIETRO":
			return {
				"normal":
					"res://assets/ui/indietro.png",
				"selected":
					"res://assets/ui/indietro_blob.png"
			}

		"RIPRENDI":
			return {
				"normal":
					"res://assets/ui/riprendi.png",
				"selected":
					"res://assets/ui/riprendi_blob.png"
			}

		"MENU PRINCIPALE":
			return {
				"normal":
					"res://assets/ui/menu_principale.png",
				"selected":
					"res://assets/ui/menu_principale_blob.png"
			}

	return {}


func _get_visible_bounds(texture: Texture2D) -> Rect2i:
	if texture == null:
		return Rect2i()

	var image := texture.get_image()

	if image == null or image.is_empty():
		return Rect2i(
			Vector2i.ZERO,
			Vector2i(
				texture.get_width(),
				texture.get_height()
			)
		)

	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1

	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a <= alpha_threshold:
				continue

			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)

	if max_x < min_x or max_y < min_y:
		return Rect2i(
			Vector2i.ZERO,
			Vector2i(
				image.get_width(),
				image.get_height()
			)
		)

	return Rect2i(
		Vector2i(min_x, min_y),
		Vector2i(
			max_x - min_x + 1,
			max_y - min_y + 1
		)
	)


func _make_cropped_texture(
	texture: Texture2D,
	region: Rect2i
) -> Texture2D:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(region)

	return atlas


func _apply_label_texture(
	texture: Texture2D,
	display_size: Vector2
) -> void:
	if label_image == null:
		return

	label_image.texture = texture
	label_image.size = display_size

	label_image.position = Vector2(
		(size.x - display_size.x) * 0.5,
		(size.y - display_size.y) * 0.5
	)


func _refresh_image() -> void:
	if label_image == null:
		return

	if is_hovered() or has_focus():
		_apply_label_texture(
			selected_display_texture,
			selected_display_size
		)
	else:
		_apply_label_texture(
			normal_display_texture,
			normal_display_size
		)


func _is_container_managed() -> bool:
	return get_parent() is Container


func _update_pivot() -> void:
	if _is_container_managed():
		pivot_offset = size * 0.5
	else:
		pivot_offset = Vector2(
			0.0,
			size.y * 0.5
		)

	if label_image != null:
		_refresh_image()


func _kill_tween() -> void:
	if hover_tween != null:
		hover_tween.kill()


func _hover_target_x() -> float:
	# I Container gestiscono autonomamente la posizione dei figli.
	# Spostare position.x dentro HBox/VBox causa sovrapposizioni.
	if _is_container_managed():
		return base_position.x

	return base_position.x + hover_shift


func _animate_to(
	target_scale: Vector2,
	target_x: float,
	duration: float
) -> void:
	_kill_tween()

	hover_tween = create_tween()
	hover_tween.set_parallel(true)

	hover_tween.tween_property(
		self,
		"scale",
		target_scale,
		duration
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	# Non tocchiamo position.x dei Button gestiti da Container.
	if not _is_container_managed():
		hover_tween.tween_property(
			self,
			"position:x",
			target_x,
			duration
		).set_trans(
			Tween.TRANS_QUAD
		).set_ease(
			Tween.EASE_OUT
		)


func _on_mouse_entered() -> void:
	_animate_to(
		base_scale * hover_scale,
		_hover_target_x(),
		animation_time
	)

	_refresh_image()
	_play_hover_sound()


func _on_mouse_exited() -> void:
	if has_focus():
		return

	_animate_to(
		base_scale,
		base_position.x,
		animation_time
	)

	_refresh_image()


func _on_focus_entered() -> void:
	_animate_to(
		base_scale * hover_scale,
		_hover_target_x(),
		animation_time
	)

	_refresh_image()

	if not is_hovered():
		_play_hover_sound()


func _on_focus_exited() -> void:
	if is_hovered():
		return

	_animate_to(
		base_scale,
		base_position.x,
		animation_time
	)

	_refresh_image()


func _on_button_down() -> void:
	_kill_tween()

	hover_tween = create_tween()

	hover_tween.tween_property(
		self,
		"scale",
		base_scale * 0.985,
		0.055
	)

	_play_click_sound()
	_refresh_image()


func _on_button_up() -> void:
	if is_hovered() or has_focus():
		_on_mouse_entered()
	else:
		_on_mouse_exited()
