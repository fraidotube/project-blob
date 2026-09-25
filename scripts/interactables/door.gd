extends Node3D

@export var open_angle := 90.0
@export var open_speed := 4.0

@export var auto_close := false
@export var auto_close_delay := 3.0

@onready var door_body: AnimatableBody3D = $DoorBody
@onready var area: Area3D = $Area3D

var is_open := false
var player_inside := false
var target_rotation_y := 0.0

var auto_close_timer: Timer
var auto_close_pending := false

# Trasformazione originale del DoorBody rispetto al root/cardine.
var door_body_rest_transform: Transform3D


func _ready() -> void:
	door_body_rest_transform = door_body.transform

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	auto_close_timer = Timer.new()
	auto_close_timer.one_shot = true
	auto_close_timer.timeout.connect(_on_auto_close_timeout)
	add_child(auto_close_timer)


func _physics_process(delta: float) -> void:
	# Ruota il root/cardine e quindi tutta la geometria importata.
	rotation.y = lerp_angle(
		rotation.y,
		target_rotation_y,
		open_speed * delta
	)

	# Aggiorna esplicitamente la trasformazione globale del DoorBody
	# affinché anche il Physics Server aggiorni la collisione.
	var desired_body_transform := (
		global_transform * door_body_rest_transform
	)

	door_body.global_transform = desired_body_transform

	if (
		player_inside
		and Input.is_action_just_pressed("interact")
	):
		toggle_door()


func toggle_door() -> void:
	is_open = not is_open
	auto_close_pending = false

	if is_open:
		target_rotation_y = deg_to_rad(open_angle)

		if auto_close:
			auto_close_timer.start(auto_close_delay)
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
		# Il tempo è scaduto, ma il giocatore è ancora
		# nella zona della porta: aspettiamo che esca.
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
