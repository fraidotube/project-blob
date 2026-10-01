extends Node3D

# Solo diagnostica della scena poligono: NON altera arma, colpi o danno.
# La proprietà surface_type dei collider è un'etichetta di test, NON una
# dipendenza dal materiale grafico. Nella mappa reale verrà gestita dopo.

@onready var _player: CharacterBody3D = $Player
@onready var _weapon_ray: RayCast3D = $Player/Head/Camera3D/WeaponRay
@onready var _debug_label: Label = $DebugLayer/DebugPanel/DebugLabel
var _shots: int = 0
var _last_health: int = 100
var _last_hit: String = "Nessuno sparo"
var _last_texture: String = "Non ancora sparato"
var _last_audio: String = "Non ancora sparato"

func _ready() -> void:
    _last_health = int(_player.get("health"))
    _update_panel()
    print("[SHOOTING RANGE] Scena diagnostica avviata. Pick-up: E; sparo: tasto sinistro.")

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("fire"):
        # Il normale controller gestisce gia' lo sparo, noi osserviamo soltanto.
        call_deferred("_report_hit")
    if int(_player.get("health")) != _last_health:
        var new_health: int = int(_player.get("health"))
        print("[SHOOTING RANGE] HP cambiati: ", _last_health, " -> ", new_health,
            " (delta=", new_health - _last_health, ")")
        _last_health = new_health
        _update_panel()

func _report_hit() -> void:
    _shots += 1
    _weapon_ray.force_raycast_update()
    if not _weapon_ray.is_colliding():
        _last_hit = "MISS: nessun collider nel mirino"
    else:
        var collider: Object = _weapon_ray.get_collider()
        var collider_name: String = str(collider)
        var surface: String = "non classificata"
        var damage_handler: String = "nessuno"
        if collider is Node:
            collider_name = str((collider as Node).get_path())
            if (collider as Node).has_meta("surface_type"):
                surface = str((collider as Node).get_meta("surface_type"))
        if collider.has_method("take_bullet_hit"):
            damage_handler = "take_bullet_hit"
        elif collider.has_method("take_damage"):
            damage_handler = "take_damage"
        var point: Vector3 = _weapon_ray.get_collision_point()
        var normal: Vector3 = _weapon_ray.get_collision_normal()
        _last_hit = "%s | %s | danno: %s\nPunto: %s | Normale: %s" % [
            collider_name, surface, damage_handler, point, normal]
    print("[SHOOTING RANGE] Sparo #", _shots, ": ", _last_hit)
    _update_panel()

func report_impact_texture(description: String) -> void:
    _last_texture = description
    _update_panel()


func report_impact_audio(description: String) -> void:
    _last_audio = description
    _update_panel()


func _update_panel() -> void:
    _debug_label.text = (
        "PROJECT BLOB | POLIGONO DI TIRO | diagnostica\n"
        + "Pistola: avvicinati al pickup e premi E. Bersagli: cemento / legno / metallo / vetro / senza tipo\n"
        + "Spari osservati: %d | Salute: %d\nUltimo impatto: %s\nTexture: %s\nAudio: %s" % [
            _shots, int(_player.get("health")), _last_hit, _last_texture, _last_audio
        ]
    )
