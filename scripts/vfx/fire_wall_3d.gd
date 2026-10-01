@tool
extends Node3D

# V4.5.2: default a fiamme indipendenti, con spazi vuoti.
# La base continua esiste solo come opzione disabilitata.
const FIRE_WALL_FRAMES := preload(
	"res://IGNIS/engine/godot/sprite_frames/area_fire_wall_loop.tres"
)
const BONFIRE_FRAMES := preload(
	"res://IGNIS/engine/godot/sprite_frames/area_bonfire_loop.tres"
)

@export_group("Fire Wall")
@export_range(1, 64, 1) var wall_cells: int = 5:
	set(value):
		wall_cells = value
		_request_refresh()

@export_range(0.0025, 0.05, 0.0005) var pixel_size: float = 0.012:
	set(value):
		pixel_size = value
		_request_refresh()

@export_range(0.1, 8.0, 0.05) var height_scale: float = 2.25:
	set(value):
		height_scale = value
		_request_refresh()

@export_range(0.1, 8.0, 0.05) var width_scale: float = 1.0:
	set(value):
		width_scale = value
		_request_refresh()

@export_range(-5.0, 5.0, 0.05) var visual_y_offset: float = 0.0:
	set(value):
		visual_y_offset = value
		_request_refresh()

@export_group("Organic Overlay")
@export var organic_overlay_enabled: bool = true:
	set(value):
		organic_overlay_enabled = value
		_request_refresh()

# La prima fiamma irregolare e presente in OGNI modulo.
# Questo valore controlla SOLO la probabilita della seconda fiamma.
@export_range(0.0, 1.0, 0.05) var overlay_coverage: float = 1.0:
	set(value):
		overlay_coverage = value
		_request_refresh()

@export_range(0.4, 2.0, 0.05) var overlay_height_min: float = 0.65:
	set(value):
		overlay_height_min = value
		_request_refresh()

@export_range(0.4, 2.0, 0.05) var overlay_height_max: float = 1.65:
	set(value):
		overlay_height_max = value
		_request_refresh()

@export_range(0.4, 2.0, 0.05) var overlay_width_min: float = 0.70:
	set(value):
		overlay_width_min = value
		_request_refresh()

@export_range(0.4, 2.0, 0.05) var overlay_width_max: float = 1.20:
	set(value):
		overlay_width_max = value
		_request_refresh()

# Jitter X come frazione della larghezza di una cella.
@export_range(0.0, 0.5, 0.025) var horizontal_jitter: float = 0.20:
	set(value):
		horizontal_jitter = value
		_request_refresh()

@export_range(0.0, 2.0, 0.05) var vertical_jitter: float = 0.15:
	set(value):
		vertical_jitter = value
		_request_refresh()

@export_range(0.0, 1.0, 0.05) var depth_jitter: float = 0.18:
	set(value):
		depth_jitter = value
		_request_refresh()

@export_range(0.0, 12.0, 0.5) var rotation_jitter_degrees: float = 4.0:
	set(value):
		rotation_jitter_degrees = value
		_request_refresh()

@export_range(0.1, 1.0, 0.05) var overlay_opacity: float = 0.67:
	set(value):
		overlay_opacity = value
		_request_refresh()

@export_range(0.5, 2.0, 0.05) var overlay_speed_min: float = 0.85:
	set(value):
		overlay_speed_min = value
		_request_refresh()

@export_range(0.5, 2.0, 0.05) var overlay_speed_max: float = 1.15:
	set(value):
		overlay_speed_max = value
		_request_refresh()

# 0 = seme calcolato dalla posizione dell'istanza nella mappa.
# Un valore esplicito permette di fissare/riprodurre il risultato.
@export var variation_seed: int = 0:
	set(value):
		variation_seed = value
		_request_refresh()

@export_group("Organic Shape")
# La base sincronizzata rimane continua ma piu bassa: non domina la sagoma.
@export_range(0.2, 1.0, 0.05) var base_height_ratio: float = 0.53:
	set(value):
		base_height_ratio = value
		_request_refresh()

@export_range(0.1, 1.0, 0.05) var base_opacity: float = 0.65:
	set(value):
		base_opacity = value
		_request_refresh()

@export_range(0.1, 1.0, 0.05) var secondary_opacity_ratio: float = 0.65:
	set(value):
		secondary_opacity_ratio = value
		_request_refresh()

@export_group("Sparse Fires")
# ON di default, anche per tutte le istanze esistenti.
@export var sparse_fires_enabled: bool = true:
	set(value):
		sparse_fires_enabled = value
		_request_refresh()

# Compatibilità con V451: proprietà conservata nelle istanze esistenti.
# La nuova densità si regola con Ignition Probability.
@export_range(0.0, 1.0, 0.05) var flame_density: float = 0.55:
	set(value):
		flame_density = value
		_request_refresh()

@export_range(0.0, 1.0, 0.05) var companion_chance: float = 0.22:
	set(value):
		companion_chance = value
		_request_refresh()

# Solo per chi desidera riattivare il vecchio aspetto continuo.
@export var continuous_base_enabled: bool = false:
	set(value):
		continuous_base_enabled = value
		_request_refresh()

@export_range(0.25, 1.5, 0.05) var flame_size_min: float = 0.48:
	set(value):
		flame_size_min = value
		_request_refresh()

@export_range(0.25, 2.0, 0.05) var flame_size_max: float = 1.05:
	set(value):
		flame_size_max = value
		_request_refresh()

@export_range(0.0, 0.48, 0.02) var flame_x_jitter: float = 0.25:
	set(value):
		flame_x_jitter = value
		_request_refresh()

@export_group("Natural Fire Distribution")
# Nuovi parametri: i default si applicano anche alle istanze V451 già in mappa.
@export_range(1, 8, 1) var ignition_slots_per_cell: int = 4:
	set(value):
		ignition_slots_per_cell = value
		_request_refresh()

@export_range(0.0, 1.0, 0.05) var ignition_probability: float = 0.72:
	set(value):
		ignition_probability = value
		_request_refresh()

# La bonfire mostra una fiamma concentrata al centro del frame.
# Il boost serve a recuperare altezza e massa visiva senza allargare la collisione.
@export_range(0.5, 4.0, 0.1) var bonfire_visual_boost: float = 1.85:
	set(value):
		bonfire_visual_boost = value
		_request_refresh()

@export_range(0.0, 1.0, 0.05) var tall_fire_chance: float = 0.20:
	set(value):
		tall_fire_chance = value
		_request_refresh()

@export_range(1.0, 2.0, 0.05) var tall_fire_multiplier: float = 1.55:
	set(value):
		tall_fire_multiplier = value
		_request_refresh()

@export var guaranteed_fire_per_wall: bool = true:
	set(value):
		guaranteed_fire_per_wall = value
		_request_refresh()

@export_group("Fire Audio")
# WAV gia presente nel progetto: impostazione predefinita per ogni FireWall.
@export var fire_sound: AudioStream = preload(
	"res://assets/audio/ambience/exterior/large-fire-burning.wav"
):
	set(value):
		fire_sound = value
		_request_audio_refresh()

@export var fire_audio_enabled: bool = true:
	set(value):
		fire_audio_enabled = value
		_request_audio_refresh()

@export_range(-40.0, 12.0, 0.5) var fire_volume_db: float = -24.0:
	set(value):
		fire_volume_db = value
		_request_audio_refresh()

@export_range(1.0, 50.0, 0.5) var fire_max_distance: float = 14.0:
	set(value):
		fire_max_distance = value
		_request_audio_refresh()

@export_range(1.0, 25.0, 0.5) var audio_source_spacing: float = 9.0:
	set(value):
		audio_source_spacing = value
		_request_audio_refresh()

@export_range(0.1, 20.0, 0.1) var audio_unit_size: float = 4.0:
	set(value):
		audio_unit_size = value
		_request_audio_refresh()

@export_group("Editor Preview")
@export var preview_in_editor: bool = true:
	set(value):
		preview_in_editor = value
		_request_refresh()

@export_group("Collision")
@export_range(0.1, 10.0, 0.1) var collision_height: float = 3.5:
	set(value):
		collision_height = value
		_request_refresh()

@export_range(0.1, 5.0, 0.1) var collision_depth: float = 0.6:
	set(value):
		collision_depth = value
		_request_refresh()

@export_group("Damage Zone")
@export_range(0.1, 10.0, 0.1) var damage_height: float = 3.5:
	set(value):
		damage_height = value
		_request_refresh()

@export_range(0.1, 5.0, 0.1) var damage_depth: float = 1.2:
	set(value):
		damage_depth = value
		_request_refresh()

var _audio_refresh_queued := false
var _fire_audio_root: Node3D
var _looping_fire_stream: AudioStream

var _refresh_queued := false


func _ready() -> void:
	_refresh_wall()
	if not Engine.is_editor_hint():
		_rebuild_fire_audio()


func _request_audio_refresh() -> void:
	# In editor non si creano player audio e non parte alcun suono.
	if Engine.is_editor_hint() or not is_inside_tree():
		return
	if _audio_refresh_queued:
		return
	_audio_refresh_queued = true
	call_deferred("_rebuild_fire_audio")


func _rebuild_fire_audio() -> void:
	_audio_refresh_queued = false
	if Engine.is_editor_hint() or not is_inside_tree():
		return

	if is_instance_valid(_fire_audio_root):
		remove_child(_fire_audio_root)
		_fire_audio_root.queue_free()
		_fire_audio_root = null

	if not fire_audio_enabled or fire_sound == null:
		return

	# Per i WAV forziamo il loop sulla copia locale, senza alterare
	# le altre fiamme che utilizzano lo stesso file audio.
	_looping_fire_stream = fire_sound
	if fire_sound is AudioStreamWAV:
		var wav := (fire_sound as AudioStreamWAV).duplicate() as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_looping_fire_stream = wav
	elif fire_sound is AudioStreamOggVorbis:
		var ogg := (fire_sound as AudioStreamOggVorbis).duplicate() as AudioStreamOggVorbis
		ogg.loop = true
		_looping_fire_stream = ogg
	elif fire_sound is AudioStreamMP3:
		var mp3 := (fire_sound as AudioStreamMP3).duplicate() as AudioStreamMP3
		mp3.loop = true
		_looping_fire_stream = mp3

	_fire_audio_root = Node3D.new()
	_fire_audio_root.name = "FireAudioSources"
	add_child(_fire_audio_root)

	var wall_width := float(wall_cells) * 256.0 * pixel_size * width_scale
	var spacing := maxf(audio_source_spacing, 1.0)
	var source_count := maxi(1, ceili(wall_width / spacing))
	var segment := wall_width / float(source_count)

	for i: int in range(source_count):
		var source := AudioStreamPlayer3D.new()
		source.name = "FireAudio_%02d" % (i + 1)
		source.stream = _looping_fire_stream
		source.bus = &"SFX"
		source.volume_db = fire_volume_db
		source.unit_size = audio_unit_size
		source.max_distance = fire_max_distance
		source.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		source.position = Vector3(
			-wall_width * 0.5 + (float(i) + 0.5) * segment,
			maxf(0.0, collision_height * 0.4),
			0.0
		)
		_fire_audio_root.add_child(source)
		# Evita che piu file lunghi partano all'unisono.
		if source_count > 1 and _looping_fire_stream.get_length() > 1.0:
			source.play(fmod(float(i) * 3.71, _looping_fire_stream.get_length() - 0.5))
		else:
			source.play()



func _request_refresh() -> void:
	if not is_inside_tree() or _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_refresh_wall")


func _refresh_wall() -> void:
	_refresh_queued = false

	var flames_root := get_node_or_null("Flames") as Node3D
	var blocker_shape := get_node_or_null(
		"StaticBody3D/CollisionShape3D"
	) as CollisionShape3D
	var damage_shape := get_node_or_null(
		"FireDamageZone/CollisionShape3D"
	) as CollisionShape3D

	if flames_root == null:
		return

	_clear_generated_flames(flames_root)

	if not Engine.is_editor_hint() or preview_in_editor:
		_build_flames(flames_root)

	if blocker_shape != null and damage_shape != null:
		_update_collision_shapes(blocker_shape, damage_shape)
	if not Engine.is_editor_hint() and is_instance_valid(_fire_audio_root):
		_request_audio_refresh()


func _clear_generated_flames(flames_root: Node3D) -> void:
	for child: Node in flames_root.get_children():
		flames_root.remove_child(child)
		child.queue_free()


func _build_flames(flames_root: Node3D) -> void:
	var cell_width := 256.0 * pixel_size * width_scale
	var wall_width := float(wall_cells) * cell_width
	var wall_left := -wall_width * 0.5
	var nominal_height := 256.0 * pixel_size * height_scale
	var bottom_y := visual_y_offset - nominal_height * 0.5
	var rng := RandomNumberGenerator.new()
	if variation_seed != 0:
		rng.seed = variation_seed
	else:
		var origin := global_position
		rng.seed = hash("%s|%s" % [
			str(get_path()),
			str(Vector3i(
				roundi(origin.x * 100.0),
				roundi(origin.y * 100.0),
				roundi(origin.z * 100.0)
			))
		])

	var first_x := wall_left + cell_width * 0.5
	if not sparse_fires_enabled:
		_build_old_fire_wall(flames_root, first_x, cell_width, nominal_height, bottom_y, rng)
		return

	if continuous_base_enabled:
		_build_base(flames_root, first_x, cell_width, nominal_height, bottom_y)

	# I punti d'innesco sono distribuiti IN METRI e non uno per cella.
	# La lunghezza del muro resta quella della V447 (collisioni immutate).
	var slots := maxi(1, wall_cells * ignition_slots_per_cell)
	var step_width := wall_width / float(slots)
	var spawned := 0
	for slot: int in range(slots):
		if rng.randf() > ignition_probability:
			continue  # spazio davvero vuoto
		_spawn_natural_flame(
			flames_root, rng, wall_left, wall_width, step_width,
			nominal_height, bottom_y, slot, false
		)
		spawned += 1
		if rng.randf() < companion_chance:
			_spawn_natural_flame(
				flames_root, rng, wall_left, wall_width, step_width,
				nominal_height, bottom_y, slot, true
			)

	if spawned == 0 and guaranteed_fire_per_wall:
		_spawn_natural_flame(
			flames_root, rng, wall_left, wall_width, step_width,
			nominal_height, bottom_y, rng.randi_range(0, slots - 1), false
		)


func _spawn_natural_flame(
	flames_root: Node3D,
	rng: RandomNumberGenerator,
	wall_left: float,
	wall_width: float,
	step_width: float,
	nominal_height: float,
	bottom_y: float,
	slot: int,
	companion: bool
) -> void:
	# Bonfire ha un profilo isolato, senza il bordo ripetuto della wall.
	# Dimensione di base indipendente dal numero di celle.
	var size_factor := rng.randf_range(0.75, 1.20)
	if rng.randf() < tall_fire_chance:
		size_factor *= tall_fire_multiplier
	if companion:
		size_factor *= rng.randf_range(0.55, 0.78)

	var absolute_height_factor := size_factor * bonfire_visual_boost
	var absolute_width_factor := size_factor * bonfire_visual_boost
	var center_x := wall_left + (float(slot) + 0.5) * step_width
	var jitter_x := rng.randf_range(-0.38, 0.38) * step_width
	var x := clampf(
		center_x + jitter_x,
		wall_left + step_width * 0.25,
		wall_left + wall_width - step_width * 0.25
	)
	var sprite := _create_sprite(
		"Fire_%02d_%s" % [slot + 1, "Small" if companion else "Main"],
		Vector3(
			x,
			bottom_y + nominal_height * absolute_height_factor * 0.5,
			rng.randf_range(-depth_jitter, depth_jitter)
		),
		Vector3(
			width_scale * absolute_width_factor,
			height_scale * absolute_height_factor,
			1.0
		),
		overlay_opacity
	)
	sprite.sprite_frames = BONFIRE_FRAMES
	sprite.rotation.z = deg_to_rad(
		rng.randf_range(-rotation_jitter_degrees, rotation_jitter_degrees)
	)
	flames_root.add_child(sprite)

	var frame_count := BONFIRE_FRAMES.get_frame_count(&"default")
	if frame_count > 0:
		sprite.frame = rng.randi_range(0, frame_count - 1)
	sprite.speed_scale = rng.randf_range(
		minf(overlay_speed_min, overlay_speed_max),
		maxf(overlay_speed_min, overlay_speed_max)
	)
	sprite.play(&"default")


func _build_base(
	flames_root: Node3D,
	first_x: float,
	cell_width: float,
	nominal_height: float,
	bottom_y: float
) -> void:
	var sprites: Array[AnimatedSprite3D] = []
	for i: int in range(wall_cells):
		var sprite := _create_sprite(
			"Base_%02d" % (i + 1),
			Vector3(
				first_x + float(i) * cell_width,
				bottom_y + nominal_height * base_height_ratio * 0.5,
				0.0
			),
			Vector3(width_scale, height_scale * base_height_ratio, 1.0),
			base_opacity
		)
		flames_root.add_child(sprite)
		sprites.append(sprite)
	for sprite: AnimatedSprite3D in sprites:
		sprite.frame = 0
		sprite.speed_scale = 1.0
		sprite.play(&"default")


func _build_old_fire_wall(
	flames_root: Node3D,
	first_x: float,
	cell_width: float,
	nominal_height: float,
	bottom_y: float,
	rng: RandomNumberGenerator
) -> void:
	_build_base(flames_root, first_x, cell_width, nominal_height, bottom_y)
	if not organic_overlay_enabled:
		return

	var h_min := minf(overlay_height_min, overlay_height_max)
	var h_max := maxf(overlay_height_min, overlay_height_max)
	var w_min := minf(overlay_width_min, overlay_width_max)
	var w_max := maxf(overlay_width_min, overlay_width_max)
	var s_min := minf(overlay_speed_min, overlay_speed_max)
	var s_max := maxf(overlay_speed_min, overlay_speed_max)
	var frame_count := FIRE_WALL_FRAMES.get_frame_count(&"default")

	for i: int in range(wall_cells):
		var center_x := first_x + float(i) * cell_width
		var count := 1
		if rng.randf() < overlay_coverage:
			count = 2
		for layer_i: int in range(count):
			var height_factor := rng.randf_range(h_min, h_max)
			var width_factor := rng.randf_range(w_min, w_max)
			var opacity := overlay_opacity
			if layer_i == 1:
				opacity *= secondary_opacity_ratio
				width_factor *= 0.85
			var overlay := _create_sprite(
				"Organic_%02d_%d" % [i + 1, layer_i + 1],
				Vector3(
					center_x + rng.randf_range(-horizontal_jitter, horizontal_jitter) * cell_width,
					bottom_y + nominal_height * height_factor * 0.5
						+ rng.randf_range(-vertical_jitter, vertical_jitter),
					rng.randf_range(-depth_jitter, depth_jitter)
				),
				Vector3(width_scale * width_factor, height_scale * height_factor, 1.0),
				opacity
			)
			overlay.rotation.z = deg_to_rad(
				rng.randf_range(-rotation_jitter_degrees, rotation_jitter_degrees)
			)
			flames_root.add_child(overlay)
			if frame_count > 0:
				overlay.frame = rng.randi_range(0, frame_count - 1)
			overlay.speed_scale = rng.randf_range(s_min, s_max)
			overlay.play(&"default")


func _create_sprite(
	sprite_name: String,
	local_position: Vector3,
	local_scale: Vector3,
	opacity: float
) -> AnimatedSprite3D:
	var sprite := AnimatedSprite3D.new()
	sprite.name = sprite_name
	sprite.sprite_frames = FIRE_WALL_FRAMES
	sprite.animation = &"default"
	sprite.pixel_size = pixel_size
	sprite.scale = local_scale
	sprite.position = local_position
	sprite.shaded = false
	sprite.double_sided = true
	sprite.modulate = Color(1.0, 1.0, 1.0, opacity)
	return sprite


func _update_collision_shapes(
	blocker_shape: CollisionShape3D,
	damage_shape: CollisionShape3D
) -> void:
	var total_width := float(wall_cells) * 256.0 * pixel_size * width_scale

	var blocker_box := BoxShape3D.new()
	blocker_box.size = Vector3(total_width, collision_height, collision_depth)
	blocker_shape.shape = blocker_box
	blocker_shape.position.y = collision_height * 0.5

	var damage_box := BoxShape3D.new()
	damage_box.size = Vector3(total_width, damage_height, damage_depth)
	damage_shape.shape = damage_box
	damage_shape.position.y = damage_height * 0.5
