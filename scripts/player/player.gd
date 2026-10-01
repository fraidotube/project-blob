extends CharacterBody3D

const WALK_SPEED := 5.0
const SPRINT_SPEED := 8.0
const CROUCH_SPEED := 2.8
const JUMP_VELOCITY := 4.5

const BASE_MOUSE_SENSITIVITY := 0.004
const SETTINGS_PATH := "user://settings.cfg"

const STAND_HEIGHT := 1.6
const CROUCH_HEIGHT := 1

const STAND_HEAD_Y := 0.80
const CROUCH_HEAD_Y := 0.35

const CROUCH_TRANSITION_SPEED := 8.0

const FOOTSTEP_WALK_INTERVAL := 0.45
const FOOTSTEP_SPRINT_INTERVAL := 0.30
const FOOTSTEP_CROUCH_INTERVAL := 0.60

const LAND_MIN_SPEED := -2.0

const DEATH_TITLE_TEXTURE := preload(
	"res://assets/ui/sei_morto.png"
)

const DEATH_CONTINUE_TEXTURE := preload(
	"res://assets/ui/n_continua.png"
)

@export var max_health := 100

@export var footsteps_parquet: AudioStream

@export var footsteps_tile: AudioStream
@export var footsteps_tile_run: AudioStream

@export var footsteps_rock: AudioStream
@export var footsteps_rock_run: AudioStream

@export var jump_tile_start: AudioStream
@export var jump_tile_land: AudioStream

@export var jump_rock_start: AudioStream
@export var jump_rock_land: AudioStream

@export_group("Player Voice")
@export var damage_voice_sounds: Array[AudioStream] = []
@export var jump_voice_sounds: Array[AudioStream] = []
@export var landing_voice_sounds: Array[AudioStream] = []
@export var sprint_breath_sounds: Array[AudioStream] = []
@export var death_voice_sounds: Array[AudioStream] = []

@export_range(-40.0, 12.0, 0.5) var voice_volume_db: float = 0.0
@export_range(0.0, 5.0, 0.1) var damage_voice_cooldown: float = 0.8
@export_range(0.5, 20.0, 0.1) var sprint_breath_interval_min: float = 2.5
@export_range(0.5, 20.0, 0.1) var sprint_breath_interval_max: float = 4.5

@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var weapon: Node3D = $Head/Camera3D/WeaponHolder
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay

@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var footstep_timer: Timer = $FootstepTimer
@onready var footstep_ray: RayCast3D = $FootstepRay

@onready var jump_audio: AudioStreamPlayer3D = $JumpAudio
@onready var land_audio: AudioStreamPlayer3D = $LandAudio

var health: int
var is_dead := false
var is_crouched := false
var mouse_sensitivity := BASE_MOUSE_SENSITIVITY

var voice_audio: AudioStreamPlayer
var sprint_breath_audio: AudioStreamPlayer
var sprint_breath_timer: Timer
var damage_voice_timer: Timer


func _ready() -> void:
	_load_mouse_sensitivity()
	_setup_voice_audio()

	health = max_health
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	get_tree().call_group(
		"hud",
		"update_health",
		health,
		max_health
	)


func _setup_voice_audio() -> void:
	voice_audio = AudioStreamPlayer.new()
	voice_audio.name = "PlayerVoiceAudio"
	voice_audio.bus = &"Player"
	voice_audio.volume_db = voice_volume_db
	add_child(voice_audio)

	sprint_breath_audio = AudioStreamPlayer.new()
	sprint_breath_audio.name = "SprintBreathAudio"
	sprint_breath_audio.bus = &"Player"
	sprint_breath_audio.volume_db = voice_volume_db
	add_child(sprint_breath_audio)

	sprint_breath_timer = Timer.new()
	sprint_breath_timer.name = "SprintBreathTimer"
	sprint_breath_timer.one_shot = true
	sprint_breath_timer.timeout.connect(_on_sprint_breath_timer_timeout)
	add_child(sprint_breath_timer)

	damage_voice_timer = Timer.new()
	damage_voice_timer.name = "DamageVoiceCooldown"
	damage_voice_timer.one_shot = true
	add_child(damage_voice_timer)


func _load_mouse_sensitivity() -> void:
	var config := ConfigFile.new()

	if config.load(SETTINGS_PATH) != OK:
		mouse_sensitivity = BASE_MOUSE_SENSITIVITY
		return

	var multiplier := float(
		config.get_value(
			"controls",
			"mouse_sensitivity",
			1.0
		)
	)

	mouse_sensitivity = (
		BASE_MOUSE_SENSITIVITY
		* clampf(multiplier, 0.25, 2.50)
	)


func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		if (
			event is InputEventKey
			and event.pressed
			and not event.echo
			and (
				event.keycode == KEY_N
				or event.physical_keycode == KEY_N
			)
		):
			get_tree().reload_current_scene()

		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-89.0),
			deg_to_rad(89.0)
		)

	if event.is_action_pressed("weapon_slot_1"):
		weapon.select_weapon_slot(1)

	if event.is_action_pressed("weapon_slot_2"):
		weapon.select_weapon_slot(2)

	if event.is_action_pressed("weapon_slot_3"):
		weapon.select_weapon_slot(3)

	if event.is_action_pressed("flashlight_toggle"):
		weapon.toggle_flashlight()

	if event.is_action_pressed("fire"):
		weapon.fire()

	if event.is_action_pressed("reload"):
		weapon.reload()

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		footstep_timer.stop()
		sprint_breath_timer.stop()

		if sprint_breath_audio.playing:
			sprint_breath_audio.stop()

		return

	var was_on_floor := is_on_floor()

	_update_crouch(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if (
		Input.is_action_just_pressed("jump")
		and is_on_floor()
		and not is_crouched
	):
		_play_jump_sound()
		_play_random_voice(jump_voice_sounds)
		velocity.y = JUMP_VELOCITY

	var is_sprinting := (
		Input.is_action_pressed("sprint")
		and not is_crouched
	)

	var speed := WALK_SPEED

	if is_crouched:
		speed = CROUCH_SPEED
	elif is_sprinting:
		speed = SPRINT_SPEED

	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := (
		transform.basis
		* Vector3(input_dir.x, 0.0, input_dir.y)
	).normalized()

	var is_moving := direction != Vector3.ZERO

	if is_moving:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	var vertical_speed_before_move := velocity.y

	move_and_slide()

	var just_landed := (
		not was_on_floor
		and is_on_floor()
	)

	if just_landed:
		_play_landing_sound(vertical_speed_before_move)

		if vertical_speed_before_move <= LAND_MIN_SPEED:
			_play_random_voice(landing_voice_sounds)

	weapon.set_movement_state(
		is_moving,
		is_sprinting
	)

	_update_footsteps(
		is_sprinting,
		just_landed
	)

	_update_sprint_breathing(
		is_moving,
		is_sprinting
	)


func _update_sprint_breathing(
	is_moving: bool,
	is_sprinting: bool
) -> void:
	if not is_moving or not is_sprinting:
		sprint_breath_timer.stop()

		if sprint_breath_audio.playing:
			sprint_breath_audio.stop()

		return

	var valid := _get_valid_voice_sounds(
		sprint_breath_sounds
	)

	if valid.is_empty():
		sprint_breath_timer.stop()

		if sprint_breath_audio.playing:
			sprint_breath_audio.stop()

		return

	if sprint_breath_audio.playing:
		return

	if sprint_breath_timer.is_stopped():
		sprint_breath_audio.stream = valid.pick_random()
		sprint_breath_audio.volume_db = voice_volume_db
		sprint_breath_audio.play()
		_start_next_sprint_breath_timer()


func _on_sprint_breath_timer_timeout() -> void:
	pass


func _start_next_sprint_breath_timer() -> void:
	var minimum := minf(
		sprint_breath_interval_min,
		sprint_breath_interval_max
	)
	var maximum := maxf(
		sprint_breath_interval_min,
		sprint_breath_interval_max
	)

	sprint_breath_timer.start(
		randf_range(minimum, maximum)
	)


func _play_random_voice(streams: Array[AudioStream]) -> void:
	var valid := _get_valid_voice_sounds(streams)

	if valid.is_empty():
		return

	voice_audio.stop()
	voice_audio.stream = valid.pick_random()
	voice_audio.volume_db = voice_volume_db
	voice_audio.play()


func _get_valid_voice_sounds(
	streams: Array[AudioStream]
) -> Array[AudioStream]:
	var valid: Array[AudioStream] = []

	for stream: AudioStream in streams:
		if stream != null:
			valid.append(stream)

	return valid


func _update_footsteps(
	is_sprinting: bool,
	just_landed: bool
) -> void:
	if not is_on_floor():
		footstep_timer.stop()
		return

	var horizontal_speed := Vector2(
		velocity.x,
		velocity.z
	).length()

	if horizontal_speed < 0.2:
		footstep_timer.stop()
		return

	var interval := _get_footstep_interval(is_sprinting)

	if just_landed:
		footstep_timer.start(interval)
		return

	if footstep_timer.is_stopped():
		var footstep_stream := _get_footstep_stream(is_sprinting)

		if footstep_stream == null:
			return

		footstep_audio.stream = footstep_stream
		footstep_audio.play()
		footstep_timer.start(interval)


func _get_footstep_interval(is_sprinting: bool) -> float:
	if is_crouched:
		return FOOTSTEP_CROUCH_INTERVAL
	if is_sprinting:
		return FOOTSTEP_SPRINT_INTERVAL
	return FOOTSTEP_WALK_INTERVAL


func _get_surface_type() -> String:
	footstep_ray.force_raycast_update()

	if not footstep_ray.is_colliding():
		return ""

	var collider := footstep_ray.get_collider()

	if collider == null:
		return ""

	var current_node: Node = collider

	while current_node != null:
		if current_node.is_in_group("surface_rock"):
			return "rock"
		if current_node.is_in_group("surface_tile"):
			return "tile"
		if current_node.is_in_group("surface_parquet"):
			return "parquet"

		current_node = current_node.get_parent()

	return ""


func _get_footstep_stream(is_sprinting: bool) -> AudioStream:
	var surface_type := _get_surface_type()

	match surface_type:
		"rock":
			if is_sprinting and footsteps_rock_run != null:
				return footsteps_rock_run
			return footsteps_rock

		"tile":
			if is_sprinting and footsteps_tile_run != null:
				return footsteps_tile_run
			return footsteps_tile

		"parquet":
			return footsteps_parquet

	return null


func _play_jump_sound() -> void:
	var surface_type := _get_surface_type()

	match surface_type:
		"rock":
			if jump_rock_start != null:
				jump_audio.stream = jump_rock_start
				jump_audio.play()

		"tile":
			if jump_tile_start != null:
				jump_audio.stream = jump_tile_start
				jump_audio.play()


func _play_landing_sound(vertical_speed: float) -> void:
	if vertical_speed > LAND_MIN_SPEED:
		return

	var surface_type := _get_surface_type()

	match surface_type:
		"rock":
			if jump_rock_land != null:
				land_audio.stream = jump_rock_land
				land_audio.play()

		"tile":
			if jump_tile_land != null:
				land_audio.stream = jump_tile_land
				land_audio.play()


func _update_crouch(delta: float) -> void:
	var wants_to_crouch := Input.is_action_pressed("crouch")

	if wants_to_crouch:
		is_crouched = true
	elif is_crouched and _can_stand_up():
		is_crouched = false

	var target_height := STAND_HEIGHT
	var target_head_y := STAND_HEAD_Y

	if is_crouched:
		target_height = CROUCH_HEIGHT
		target_head_y = CROUCH_HEAD_Y

	var capsule := collision_shape.shape as CapsuleShape3D

	if capsule == null:
		return

	var new_height := move_toward(
		capsule.height,
		target_height,
		CROUCH_TRANSITION_SPEED * delta
	)

	capsule.height = new_height

	collision_shape.position.y = -(
		STAND_HEIGHT - new_height
	) * 0.5

	head.position.y = move_toward(
		head.position.y,
		target_head_y,
		CROUCH_TRANSITION_SPEED * delta
	)


func _can_stand_up() -> bool:
	var capsule := collision_shape.shape as CapsuleShape3D

	if capsule == null:
		return true

	var missing_height := STAND_HEIGHT - capsule.height

	if missing_height <= 0.01:
		return true

	return not test_move(
		global_transform,
		Vector3.UP * missing_height
	)


func equip_pistol() -> void:
	weapon.equip_pistol()


func equip_flashlight() -> void:
	weapon.equip_flashlight()


func add_ammo(amount: int) -> void:
	weapon.add_ammo(amount)


func add_flashlight_battery(amount: int = 1) -> bool:
	return weapon.add_flashlight_battery(amount)


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	health = max(health, 0)

	get_tree().call_group(
		"hud",
		"update_health",
		health,
		max_health
	)

	get_tree().call_group(
		"hud",
		"show_damage_flash"
	)

	if health <= 0:
		die()
		return

	if damage_voice_timer.is_stopped():
		_play_random_voice(damage_voice_sounds)
		damage_voice_timer.start(damage_voice_cooldown)


func die() -> void:
	if is_dead:
		return

	is_dead = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	footstep_timer.stop()
	sprint_breath_timer.stop()

	if sprint_breath_audio.playing:
		sprint_breath_audio.stop()

	_play_random_voice(death_voice_sounds)

	_hide_game_hud()
	_play_death_camera_fall()
	_show_death_overlay()


func _hide_game_hud() -> void:
	for hud: Node in get_tree().get_nodes_in_group("hud"):
		var interface := hud.get_node_or_null("Interface")

		if interface is CanvasItem:
			interface.visible = false


func _play_death_camera_fall() -> void:
	var target_position := head.position
	target_position.y = -0.55

	var target_rotation := head.rotation
	target_rotation.x += deg_to_rad(12.0)
	target_rotation.z += deg_to_rad(78.0)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		head,
		"position",
		target_position,
		0.90
	)

	tween.tween_property(
		head,
		"rotation",
		target_rotation,
		0.95
	)


func _show_death_overlay() -> void:
	var death_layer := CanvasLayer.new()
	death_layer.name = "DeathScreen"
	death_layer.layer = 100
	add_child(death_layer)

	var root := Control.new()
	root.name = "Root"
	death_layer.add_child(root)
	root.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var black_fade := ColorRect.new()
	black_fade.name = "BlackFade"
	black_fade.color = Color.BLACK
	black_fade.modulate = Color(1.0, 1.0, 1.0, 0.0)
	black_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(black_fade)
	black_fade.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	var death_title := TextureRect.new()
	death_title.name = "DeathTitle"
	death_title.texture = DEATH_TITLE_TEXTURE
	death_title.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	death_title.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)
	death_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	death_title.modulate = Color(1.0, 1.0, 1.0, 0.0)
	root.add_child(death_title)

	death_title.anchor_left = 0.5
	death_title.anchor_top = 0.5
	death_title.anchor_right = 0.5
	death_title.anchor_bottom = 0.5
	death_title.offset_left = -600.0
	death_title.offset_top = -290.0
	death_title.offset_right = 600.0
	death_title.offset_bottom = 110.0

	var continue_prompt := TextureRect.new()
	continue_prompt.name = "ContinuePrompt"
	continue_prompt.texture = DEATH_CONTINUE_TEXTURE
	continue_prompt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	continue_prompt.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)
	continue_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_prompt.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)
	root.add_child(continue_prompt)

	continue_prompt.anchor_left = 0.5
	continue_prompt.anchor_top = 0.5
	continue_prompt.anchor_right = 0.5
	continue_prompt.anchor_bottom = 0.5
	continue_prompt.offset_left = -420.0
	continue_prompt.offset_top = 70.0
	continue_prompt.offset_right = 420.0
	continue_prompt.offset_bottom = 350.0

	var fade_tween := create_tween()
	fade_tween.set_parallel(true)
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN_OUT)

	fade_tween.tween_property(
		black_fade,
		"modulate:a",
		0.94,
		1.45
	)

	fade_tween.tween_property(
		death_title,
		"modulate:a",
		1.0,
		0.85
	).set_delay(0.45)

	fade_tween.tween_property(
		continue_prompt,
		"modulate:a",
		1.0,
		0.70
	).set_delay(1.15)
