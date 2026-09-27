extends Node3D

@export var open_angle := 90.0
@export var open_speed := 4.0

@export var auto_close := false
@export var auto_close_delay := 3.0

@export var interaction_name := "PORTA"

const InteractableOutlineProxy := preload(
	"res://scripts/systems/interactable_outline_proxy.gd"
)

@export var interaction_color := Color("ffffff")
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015

# Normalmente lasciare vuoto: V5 trova automaticamente tutte le mesh
# comprese nel volume del collider di interazione (collision layer 2).
# Per casi speciali si possono indicare uno o più visual root manualmente.
@export var interaction_visual_roots: Array[NodePath] = []

@export_range(0.0, 0.25, 0.005) var interaction_outline_margin := 0.035
@export_range(1.0, 10.0, 0.25) var interaction_outline_max_size_multiplier := 3.0

var interaction_outline := InteractableOutlineProxy.new()


func _setup_interaction_outline() -> void:
	interaction_outline.setup(
		self,
		interaction_color,
		outline_width,
		interaction_visual_roots,
		interaction_outline_margin,
		interaction_outline_max_size_multiplier
	)


func set_interaction_focus(enabled: bool) -> void:
	interaction_outline.set_enabled(enabled)


func get_interaction_color() -> Color:
	return interaction_color


@onready var door_body: Node3D = $DoorBody
@onready var area: Area3D = $Area3D

var is_open := false
var player_inside := false
var target_rotation_y := 0.0

var auto_close_timer: Timer
var auto_close_pending := false

var door_body_rest_transform: Transform3D


func _ready() -> void:
	door_body_rest_transform = door_body.transform

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	auto_close_timer = Timer.new()
	auto_close_timer.one_shot = true
	auto_close_timer.timeout.connect(
		_on_auto_close_timeout
	)
	add_child(auto_close_timer)

	_setup_interaction_outline()


func _physics_process(delta: float) -> void:
	rotation.y = lerp_angle(
		rotation.y,
		target_rotation_y,
		open_speed * delta
	)

	var desired_body_transform := (
		global_transform
		* door_body_rest_transform
	)

	door_body.global_transform = (
		desired_body_transform
	)


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "CHIUDI" if is_open else "APRI"


func interact(_player: Node) -> void:
	toggle_door()


func toggle_door() -> void:
	is_open = not is_open
	auto_close_pending = false

	if is_open:
		target_rotation_y = deg_to_rad(
			open_angle
		)

		if auto_close:
			auto_close_timer.start(
				auto_close_delay
			)
	else:
		close_door()


func close_door() -> void:
	is_open = false
	target_rotation_y = 0.0
	auto_close_pending = false
	auto_close_timer.stop()


func _on_auto_close_timeout() -> void:
	if not is_open:
		return

	if player_inside:
		auto_close_pending = true
	else:
		close_door()


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_inside = true


func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_inside = false

		if auto_close_pending and is_open:
			close_door()
