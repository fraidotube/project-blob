extends Node3D

@export var open_angle := 90.0
@export var open_speed := 4.0

@onready var door_body: AnimatableBody3D = $DoorBody
@onready var area: Area3D = $Area3D

var is_open := false
var player_inside := false
var target_rotation_y := 0.0

# Trasformazione originale del DoorBody rispetto al root/cardine.
var door_body_rest_transform: Transform3D


func _ready() -> void:
	door_body_rest_transform = door_body.transform

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	# Ruota il root/cardine e quindi tutta la geometria importata.
	rotation.y = lerp_angle(
		rotation.y,
		target_rotation_y,
		open_speed * delta
	)

	# IMPORTANTE:
	# il DoorBody è figlio del root, ma forziamo esplicitamente
	# l'aggiornamento della sua trasformazione globale affinché
	# anche il Physics Server aggiorni la collisione.
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

	if is_open:
		target_rotation_y = deg_to_rad(open_angle)
	else:
		target_rotation_y = 0.0


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		player_inside = true


func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_inside = false
