extends Node3D

# Project Blob - Shared world impact visuals and 3D audio.
# Material classification belongs to the HIT COLLIDER metadata: surface_type.
# Commercial ActionVFX PNGs / user MP3s are loaded from the existing local folders.

const TEXTURE_DIR := "res://assets/textures/effects/ActionVFX Bullet Hole Textures/"
const GENERIC_TEXTURE := "res://assets/textures/effects/bullet_hole_pistol_01.png"
const IMPACT_AUDIO_DIR := "res://assets/audio/weapons/impacts/"
const AUDIO_CATEGORIES := ["concrete", "wood", "metal", "glass", "asphalt", "drywall", "generic"]
const TEXTURE_VARIANTS := {
    "concrete": ["Pistol Concrete Entry 1.png", "Pistol Concrete Entry 2.png", "Pistol Concrete Entry 3.png", "Pistol Concrete Entry 4.png", "Pistol Concrete Entry 5.png"],
    "wood": ["Pistol Wood Entry 1.png", "Pistol Wood Entry 2.png", "Pistol Wood Entry 3.png", "Pistol Wood Entry 4.png", "Pistol Wood Entry 5.png"],
    "metal": ["Pistol Steel Entry 1.png", "Pistol Steel Entry 2.png", "Pistol Steel Entry 3.png", "Pistol Steel Entry 4.png", "Pistol Steel Entry 5.png"],
    "glass": ["Glass Entry 1.png", "Glass Entry 2.png", "Glass Entry 3.png", "Glass Entry 4.png"],
    "asphalt": ["Pistol Asphalt Entry 1.png", "Pistol Asphalt Entry 2.png", "Pistol Asphalt Entry 3.png", "Pistol Asphalt Entry 4.png"],
    "drywall": ["Pistol Drywall Entry 1.png", "Pistol Drywall Entry 2.png", "Pistol Drywall Entry 3.png", "Pistol Drywall Entry 4.png"]
}

@export_group("Visual")
@export var visuals_enabled := true
@export_range(1.0, 120.0, 1.0) var decal_lifetime := 45.0
@export_range(10, 200, 1) var max_active_visuals := 90
@export_group("Audio")
@export var impact_audio_enabled := true
@export_range(-35.0, 6.0, 0.5) var impact_audio_volume_db := -2.0
@export_range(1.0, 80.0, 1.0) var impact_audio_max_distance := 45.0
@export_range(0.5, 30.0, 0.5) var impact_audio_unit_size := 12.0
@export_range(1, 24, 1) var max_simultaneous_audio := 12

var _rng := RandomNumberGenerator.new()
var _visuals: Array[Node3D] = []
var _sounds: Array[AudioStreamPlayer3D] = []
var _textures: Dictionary = {}
var _audio_by_surface: Dictionary = {}

func _ready() -> void:
    _rng.randomize()
    _discover_audio()

func spawn_impact(collider: Object, point: Vector3, normal: Vector3) -> void:
    var surface := _surface_from_collider(collider)
    var safe_normal := normal.normalized()
    if safe_normal.length_squared() < 0.01:
        safe_normal = Vector3.UP
    _play_audio(surface, point)
    if not visuals_enabled:
        return
    var texture := _choose_texture(surface)
    if texture == null:
        texture = _get_texture(GENERIC_TEXTURE)
        surface = "generic"
    if texture == null:
        push_warning("ImpactManager: manca la texture generica: " + GENERIC_TEXTURE)
        return
    var visual: Node3D = null
    if surface == "glass":
        visual = _spawn_glass(texture, point, safe_normal)
    else:
        visual = _spawn_decal(texture, point, safe_normal, surface)
    if visual == null:
        return
    _visuals.append(visual)
    while _visuals.size() > max_active_visuals:
        var old: Node3D = _visuals.pop_front()
        if is_instance_valid(old):
            old.queue_free()
    var timer := get_tree().create_timer(decal_lifetime)
    timer.timeout.connect(func() -> void:
        _visuals.erase(visual)
        if is_instance_valid(visual):
            visual.queue_free()
    )

func _surface_from_collider(collider: Object) -> String:
    if collider is Node:
        var node := collider as Node
        # A collider may inherit classification from a parent in an imported scene.
        # The nearest explicitly assigned value takes precedence.
        for i in range(5):
            if node == null:
                break
            if node.has_meta("surface_type"):
                var tag := str(node.get_meta("surface_type")).strip_edges().to_lower()
                if tag in AUDIO_CATEGORIES:
                    return tag
                return "generic"
            node = node.get_parent()
    return "generic"

func _choose_texture(surface: String) -> Texture2D:
    if not TEXTURE_VARIANTS.has(surface):
        return _get_texture(GENERIC_TEXTURE)
    var names: Array = TEXTURE_VARIANTS[surface]
    var candidates: Array[Texture2D] = []
    for filename: String in names:
        var path := TEXTURE_DIR + filename
        var tex := _get_texture(path)
        if tex != null:
            candidates.append(tex)
    if candidates.is_empty():
        return _get_texture(GENERIC_TEXTURE)
    return candidates[_rng.randi_range(0, candidates.size() - 1)]

func _get_texture(path: String) -> Texture2D:
    if _textures.has(path):
        return _textures[path] as Texture2D
    if not ResourceLoader.exists(path):
        return null
    var texture := load(path) as Texture2D
    if texture != null:
        _textures[path] = texture
    return texture

func _spawn_decal(texture: Texture2D, point: Vector3, normal: Vector3, surface: String) -> Decal:
    var decal := Decal.new()
    decal.name = "BulletImpact_" + surface
    add_child(decal)
    decal.quaternion = Quaternion(Vector3.UP, normal)
    decal.global_position = point + normal * 0.012
    var diameter := 0.079
    match surface:
        "concrete": diameter = 0.064
        "wood", "drywall", "asphalt": diameter = 0.072
        "metal": diameter = 0.052
    diameter *= _rng.randf_range(0.90, 1.10)
    var ratio := float(texture.get_width()) / maxf(float(texture.get_height()), 1.0)
    decal.size = Vector3(diameter * ratio, 0.075, diameter)
    decal.texture_albedo = texture
    decal.upper_fade = 0.08
    decal.lower_fade = 0.08
    decal.rotate_object_local(Vector3.UP, _rng.randf_range(-PI, PI))
    return decal

func _spawn_glass(texture: Texture2D, point: Vector3, normal: Vector3) -> MeshInstance3D:
    var glass := MeshInstance3D.new()
    glass.name = "BulletImpact_glass"
    var quad := QuadMesh.new()
    var diameter := 0.165 * _rng.randf_range(0.90, 1.10)
    quad.size = Vector2(diameter * float(texture.get_width()) / maxf(float(texture.get_height()), 1.0), diameter)
    var mat := StandardMaterial3D.new()
    mat.albedo_texture = texture
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    mat.render_priority = 1
    quad.material = mat
    glass.mesh = quad
    add_child(glass)
    glass.global_position = point + normal * 0.025
    var up := Vector3.UP if absf(normal.dot(Vector3.UP)) < 0.98 else Vector3.FORWARD
    glass.global_basis = Basis.looking_at(-normal, up)
    glass.rotate_object_local(Vector3.FORWARD, _rng.randf_range(-PI, PI))
    return glass

func _discover_audio() -> void:
    for category: String in AUDIO_CATEGORIES:
        _audio_by_surface[category] = []
    var dir := DirAccess.open(IMPACT_AUDIO_DIR)
    if dir == null:
        push_warning("ImpactManager: cartella suoni non trovata: " + IMPACT_AUDIO_DIR)
        return
    for filename: String in dir.get_files():
        var lower := filename.to_lower()
        var ext := lower.get_extension()
        if ext not in ["mp3", "wav", "ogg"]:
            continue
        for category: String in AUDIO_CATEGORIES:
            if not lower.begins_with(category):
                continue
            var suffix := lower.trim_prefix(category).get_basename()
            if not suffix.is_valid_int() and not suffix.begins_with("_"):
                continue
            var stream := load(IMPACT_AUDIO_DIR + filename) as AudioStream
            if stream != null:
                var entries: Array = _audio_by_surface[category]
                entries.append(stream)
                _audio_by_surface[category] = entries
            break

func _play_audio(surface: String, point: Vector3) -> void:
    if not impact_audio_enabled:
        return
    var category := surface
    if surface == "asphalt" and _audio_by_surface["asphalt"].is_empty():
        category = "concrete"
    elif surface == "drywall" and _audio_by_surface["drywall"].is_empty():
        category = "wood"
    elif not _audio_by_surface.has(category):
        category = "generic"
    var entries: Array = _audio_by_surface.get(category, [])
    if entries.is_empty():
        entries = _audio_by_surface.get("concrete", [])
    if entries.is_empty():
        return
    var stream: AudioStream = entries[_rng.randi_range(0, entries.size() - 1)]
    var player := AudioStreamPlayer3D.new()
    player.name = "ImpactAudio_" + surface
    player.stream = stream
    player.bus = &"SFX"
    player.volume_db = impact_audio_volume_db
    player.max_distance = impact_audio_max_distance
    player.unit_size = impact_audio_unit_size
    player.attenuation_filter_cutoff_hz = 10000.0
    player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
    player.pitch_scale = _rng.randf_range(0.96, 1.04)
    add_child(player)
    player.global_position = point
    player.finished.connect(func() -> void:
        _sounds.erase(player)
        if is_instance_valid(player):
            player.queue_free()
    )
    _sounds.append(player)
    while _sounds.size() > max_simultaneous_audio:
        var old: AudioStreamPlayer3D = _sounds.pop_front()
        if is_instance_valid(old):
            old.stop()
            old.queue_free()
    player.play()
