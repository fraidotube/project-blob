extends CharacterBody3D

@export var move_speed := 2.5
@export var detection_distance := 12.0
@export var stop_distance := 1.2
@export var max_health := 3

var health: int
var player: CharacterBody3D


func _ready() -> void:
	health = max_health
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player == null:
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	if distance_to_player <= detection_distance and distance_to_player > stop_distance:
		var direction := player.global_position - global_position
		direction.y = 0.0
		direction = direction.normalized()

		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

		look_at(
			Vector3(
				player.global_position.x,
				global_position.y,
				player.global_position.z
			),
			Vector3.UP
		)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()


func take_damage(amount: int) -> void:
	health -= amount

	print("Enemy hit! HP remaining: ", health)

	if health <= 0:
		die()


func die() -> void:
	print("Enemy dead")
	queue_free()
