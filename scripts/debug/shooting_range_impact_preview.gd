extends Node3D

# Project Blob: impact texture preview ONLY in the separate shooting range.
# No game weapon code, damage rules, or map surfaces are changed.
# Watch real ammunition consumption for pistol and SMG so dry firing does not
# produce fake impacts. Override the generic decal ONLY for this range instance.

const TEXTURE_DIR := "res://assets/textures/effects/ActionVFX Bullet Hole Textures/"
const GENERIC_TEXTURE := "res://assets/textures/effects/bullet_hole_pistol_01.png"

# Files are discovered at runtime: concrete1.mp3, concrete2.mp3, etc.
# New files with the same naming pattern (.mp3, .wav, .ogg) are picked up
# automatically the next time the poligono is launched.
const IMPACT_AUDIO_DIR := "res://assets/audio/weapons/impacts/"
const AUDIO_CATEGORIES := [
	"concrete",
	"wood",
	"metal",
	"glass",
	"asphalt",
	"drywall",
	"generic"
]

@export_group("Impact Audio 3D")
@export var impact_audio_enabled: bool = true

@export_range(
	-35.0,
	6.0,
	0.5
) var impact_audio_volume_db: float = -2.0

@export_range(
	1.0,
	80.0,
	1.0
) var impact_audio_max_distance: float = 45.0

@export_range(
	0.5,
	30.0,
	0.5
) var impact_audio_unit_size: float = 12.0

@export_range(
	1,
	24,
	1
) var max_simultaneous_impacts: int = 12

const DECAL_LIFETIME := 45.0
const MAX_ACTIVE_IMPACTS := 90

const TEXTURE_VARIANTS := {
	"concrete": [
		"Pistol Concrete Entry 1.png",
		"Pistol Concrete Entry 2.png",
		"Pistol Concrete Entry 3.png",
		"Pistol Concrete Entry 4.png",
		"Pistol Concrete Entry 5.png"
	],
	"wood": [
		"Pistol Wood Entry 1.png",
		"Pistol Wood Entry 2.png",
		"Pistol Wood Entry 3.png",
		"Pistol Wood Entry 4.png",
		"Pistol Wood Entry 5.png"
	],
	"metal": [
		"Pistol Steel Entry 1.png",
		"Pistol Steel Entry 2.png",
		"Pistol Steel Entry 3.png",
		"Pistol Steel Entry 4.png",
		"Pistol Steel Entry 5.png"
	],
	"glass": [
		"Glass Entry 1.png",
		"Glass Entry 2.png",
		"Glass Entry 3.png",
		"Glass Entry 4.png"
	],
	"asphalt": [
		"Pistol Asphalt Entry 1.png",
		"Pistol Asphalt Entry 2.png",
		"Pistol Asphalt Entry 3.png",
		"Pistol Asphalt Entry 4.png"
	],
	"drywall": [
		"Pistol Drywall Entry 1.png",
		"Pistol Drywall Entry 2.png",
		"Pistol Drywall Entry 3.png",
		"Pistol Drywall Entry 4.png"
	]
}

@onready var _weapon: Node3D = (
	$"../Player/Head/Camera3D/WeaponHolder"
)

@onready var _ray: RayCast3D = (
	$"../Player/Head/Camera3D/WeaponRay"
)

@onready var _diagnostics: Node3D = (
	get_parent()
)

var _last_pistol_ammo: int = -1
var _last_smg_ammo: int = -1

var _impact_queue: Array[Node3D] = []
var _cache: Dictionary = {}
var _audio_by_surface: Dictionary = {}

var _active_audio: Array[AudioStreamPlayer3D] = []

var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()

	_discover_impact_audio()

	_last_pistol_ammo = int(
		_weapon.get(
			"magazine_ammo"
		)
	)

	_last_smg_ammo = int(
		_weapon.get(
			"smg_magazine_ammo"
		)
	)

	# Nel poligono gli impatti vengono gestiti da questo
	# preview diagnostico per non duplicare decal e suoni.
	_weapon.set(
		"bullet_impact_scene",
		null
	)

	# Run after Player/Weapon process to observe completed shots.
	process_priority = 100

	print(
		"[IMPACT PREVIEW] Ready. "
		+ "Pistol + SMG impact tracking enabled."
	)


func _process(
	_delta: float
) -> void:
	var pistol_ammo := int(
		_weapon.get(
			"magazine_ammo"
		)
	)

	var smg_ammo := int(
		_weapon.get(
			"smg_magazine_ammo"
		)
	)

	if (
		pistol_ammo
		< _last_pistol_ammo
		and bool(
			_weapon.call(
				"is_pistol_equipped"
			)
		)
	):
		_register_real_shot()

	if (
		smg_ammo
		< _last_smg_ammo
		and bool(
			_weapon.call(
				"is_smg_equipped"
			)
		)
	):
		_register_real_shot()

	_last_pistol_ammo = pistol_ammo
	_last_smg_ammo = smg_ammo


func _register_real_shot() -> void:
	_ray.force_raycast_update()

	if not _ray.is_colliding():
		_diagnostics.call(
			"report_impact_texture",
			"MISS: nessun impatto"
		)

		return

	var collider: Object = (
		_ray.get_collider()
	)

	var surface := "generic"

	if collider is Node:
		var hit_node := (
			collider as Node
		)

		if hit_node.has_meta(
			"surface_type"
		):
			surface = str(
				hit_node.get_meta(
					"surface_type"
				)
			).to_lower()

	var texture_name := (
		_choose_texture(
			surface
		)
	)

	var texture_path := (
		GENERIC_TEXTURE
	)

	if not texture_name.is_empty():
		texture_path = (
			TEXTURE_DIR
			+ texture_name
		)

	var texture: Texture2D = (
		_load_texture(
			texture_path
		)
	)

	if texture == null:
		texture_path = GENERIC_TEXTURE

		texture = _load_texture(
			texture_path
		)

	if texture == null:
		push_warning(
			"[IMPACT PREVIEW] Missing fallback texture too: "
			+ GENERIC_TEXTURE
		)

		return

	var point: Vector3 = (
		_ray.get_collision_point()
	)

	_play_impact_audio(
		surface,
		point
	)

	var normal: Vector3 = (
		_ray.get_collision_normal()
		.normalized()
	)

	var impact: Node3D

	if surface == "glass":
		impact = _spawn_glass_impact(
			texture,
			point,
			normal
		)

	else:
		impact = _spawn_solid_impact(
			texture,
			point,
			normal,
			surface
		)

	if impact != null:
		_impact_queue.append(
			impact
		)

		_prune_impacts()

		_schedule_cleanup(
			impact
		)

	_diagnostics.call(
		"report_impact_texture",
		"%s → %s"
		% [
			surface,
			texture_path.get_file()
		]
	)

	print(
		"[IMPACT PREVIEW] ",
		surface,
		": ",
		texture_path.get_file()
	)


func _choose_texture(
	surface: String
) -> String:
	if not TEXTURE_VARIANTS.has(
		surface
	):
		return ""

	var available: Array[String] = []

	for filename: String in (
		TEXTURE_VARIANTS[
			surface
		]
	):
		if ResourceLoader.exists(
			TEXTURE_DIR
			+ filename
		):
			available.append(
				filename
			)

	if available.is_empty():
		return ""

	return available[
		_random.randi_range(
			0,
			available.size() - 1
		)
	]


func _load_texture(
	path: String
) -> Texture2D:
	if _cache.has(path):
		return (
			_cache[path]
			as Texture2D
		)

	if not ResourceLoader.exists(
		path
	):
		return null

	var loaded := (
		load(path)
		as Texture2D
	)

	if loaded != null:
		_cache[path] = loaded

	return loaded


func _spawn_solid_impact(
	texture: Texture2D,
	point: Vector3,
	normal: Vector3,
	surface: String
) -> Decal:
	var decal := Decal.new()

	decal.name = (
		"Impact_"
		+ surface
	)

	add_child(
		decal
	)

	decal.quaternion = Quaternion(
		Vector3.UP,
		normal
	)

	decal.global_position = (
		point
		+ normal * 0.012
	)

	var diameter := 0.064

	if (
		surface == "wood"
		or surface == "drywall"
	):
		diameter = 0.072

	elif surface == "metal":
		diameter = 0.052

	elif surface == "asphalt":
		diameter = 0.072

	elif surface == "generic":
		diameter = 0.079

	diameter *= _random.randf_range(
		0.90,
		1.10
	)

	var ratio := (
		float(
			texture.get_width()
		)
		/ maxf(
			float(
				texture.get_height()
			),
			1.0
		)
	)

	decal.size = Vector3(
		diameter * ratio,
		0.075,
		diameter
	)

	decal.texture_albedo = texture
	decal.upper_fade = 0.08
	decal.lower_fade = 0.08

	decal.rotate_object_local(
		Vector3.UP,
		_random.randf_range(
			-PI,
			PI
		)
	)

	return decal


func _spawn_glass_impact(
	texture: Texture2D,
	point: Vector3,
	normal: Vector3
) -> MeshInstance3D:
	var glass := MeshInstance3D.new()

	glass.name = (
		"Impact_glass"
	)

	var quad := QuadMesh.new()

	var diameter := (
		0.165
		* _random.randf_range(
			0.90,
			1.10
		)
	)

	quad.size = Vector2(
		diameter
		* float(
			texture.get_width()
		)
		/ maxf(
			float(
				texture.get_height()
			),
			1.0
		),
		diameter
	)

	var mat := (
		StandardMaterial3D.new()
	)

	mat.albedo_texture = texture

	mat.transparency = (
		BaseMaterial3D.TRANSPARENCY_ALPHA
	)

	mat.shading_mode = (
		BaseMaterial3D.SHADING_MODE_UNSHADED
	)

	mat.cull_mode = (
		BaseMaterial3D.CULL_DISABLED
	)

	mat.render_priority = 1

	quad.material = mat

	glass.mesh = quad

	add_child(
		glass
	)

	glass.global_position = (
		point
		+ normal * 0.025
	)

	var up := (
		Vector3.UP
		if absf(
			normal.dot(
				Vector3.UP
			)
		) < 0.98
		else Vector3.FORWARD
	)

	glass.global_basis = (
		Basis.looking_at(
			-normal,
			up
		)
	)

	glass.rotate_object_local(
		Vector3.FORWARD,
		_random.randf_range(
			-PI,
			PI
		)
	)

	return glass


func _prune_impacts() -> void:
	while (
		_impact_queue.size()
		> MAX_ACTIVE_IMPACTS
	):
		var oldest: Node3D = (
			_impact_queue.pop_front()
		)

		if is_instance_valid(
			oldest
		):
			oldest.queue_free()


func _schedule_cleanup(
	impact: Node3D
) -> void:
	var timer := (
		get_tree().create_timer(
			DECAL_LIFETIME
		)
	)

	timer.timeout.connect(
		func() -> void:
			_impact_queue.erase(
				impact
			)

			if is_instance_valid(
				impact
			):
				impact.queue_free()
	)


# ============================================================
# 3D IMPACT AUDIO (SHOOTING RANGE PREVIEW ONLY)
# ============================================================

func _discover_impact_audio() -> void:
	_audio_by_surface.clear()

	for category: String in (
		AUDIO_CATEGORIES
	):
		_audio_by_surface[
			category
		] = []

	var folder := DirAccess.open(
		IMPACT_AUDIO_DIR
	)

	if folder == null:
		push_warning(
			"[IMPACT AUDIO] Cartella non trovata: "
			+ IMPACT_AUDIO_DIR
		)

		return

	for filename: String in (
		folder.get_files()
	):
		var lower := (
			filename.to_lower()
		)

		var ext := (
			lower.get_extension()
		)

		if ext not in [
			"mp3",
			"wav",
			"ogg"
		]:
			continue

		for category: String in (
			AUDIO_CATEGORIES
		):
			var prefix := category

			if (
				category == "concrete"
				and lower.begins_with(
					"concrete"
				)
			):
				prefix = "concrete"

			if lower.begins_with(
				prefix
			):
				var trailing := (
					lower
					.trim_prefix(
						prefix
					)
					.get_basename()
				)

				if (
					trailing.is_valid_int()
					or trailing.begins_with(
						"_"
					)
				):
					var resource_path := (
						IMPACT_AUDIO_DIR
						+ filename
					)

					var stream := (
						load(
							resource_path
						)
						as AudioStream
					)

					if stream != null:
						var entries: Array = (
							_audio_by_surface[
								category
							]
						)

						entries.append({
							"name": filename,
							"stream": stream
						})

						_audio_by_surface[
							category
						] = entries

				break

	for category: String in (
		AUDIO_CATEGORIES
	):
		var entries: Array = (
			_audio_by_surface[
				category
			]
		)

		print(
			"[IMPACT AUDIO] ",
			category,
			": ",
			entries.size(),
			" suoni disponibili"
		)


func _play_impact_audio(
	surface: String,
	point: Vector3
) -> void:
	if not impact_audio_enabled:
		return

	var category := surface

	if category == "asphalt":
		category = (
			"concrete"
			if _audio_by_surface[
				"asphalt"
			].is_empty()
			else "asphalt"
		)

	elif category == "drywall":
		category = (
			"wood"
			if _audio_by_surface[
				"drywall"
			].is_empty()
			else "drywall"
		)

	elif not _audio_by_surface.has(
		category
	):
		category = "generic"

	var choices: Array = (
		_audio_by_surface.get(
			category,
			[]
		)
	)

	if (
		choices.is_empty()
		and category == "generic"
	):
		category = "concrete"

		choices = (
			_audio_by_surface[
				"concrete"
			]
		)

	if choices.is_empty():
		_diagnostics.call(
			"report_impact_audio",
			"%s: nessun suono configurato"
			% category
		)

		return

	var chosen: Dictionary = (
		choices[
			_random.randi_range(
				0,
				choices.size() - 1
			)
		]
	)

	var stream: AudioStream = (
		chosen["stream"]
	)

	if stream == null:
		return

	var player := (
		AudioStreamPlayer3D.new()
	)

	player.name = (
		"ImpactAudio_"
		+ category
	)

	player.stream = stream
	player.volume_db = (
		impact_audio_volume_db
	)

	player.max_distance = (
		impact_audio_max_distance
	)

	player.unit_size = (
		impact_audio_unit_size
	)

	player.attenuation_filter_cutoff_hz = (
		10000.0
	)

	player.attenuation_model = (
		AudioStreamPlayer3D
		.ATTENUATION_INVERSE_DISTANCE
	)

	player.pitch_scale = (
		_random.randf_range(
			0.96,
			1.04
		)
	)

	player.bus = &"SFX"

	get_tree().current_scene.add_child(
		player
	)

	player.global_position = point

	player.finished.connect(
		func() -> void:
			_active_audio.erase(
				player
			)

			if is_instance_valid(
				player
			):
				player.queue_free()
	)

	_active_audio.append(
		player
	)

	while (
		_active_audio.size()
		> max_simultaneous_impacts
	):
		var oldest: AudioStreamPlayer3D = (
			_active_audio.pop_front()
		)

		if is_instance_valid(
			oldest
		):
			oldest.stop()
			oldest.queue_free()

	player.play()

	_diagnostics.call(
		"report_impact_audio",
		"%s → %s"
		% [
			category,
			chosen["name"]
		]
	)
