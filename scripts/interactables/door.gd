extends Node3D

@export var open_angle := 90.0
@export var open_speed := 4.0

var is_open := false
var player_inside := false
var target_rotation_y := 0.0

func _ready() -> void:
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	rotation.y = lerp_angle(
		rotation.y,
		target_rotation_y,
		open_speed * delta
	)

	if player_inside and Input.is_action_just_pressed("interact"):
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
