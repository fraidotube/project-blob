extends Area3D


var player_in_range: CharacterBody3D = null
var collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if collected:
		return

	if player_in_range == null:
		return

	if Input.is_action_just_pressed("interact"):
		collect()


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("equip_pistol"):
		player_in_range = body as CharacterBody3D


func _on_body_exited(body: Node3D) -> void:
	if body == player_in_range:
		player_in_range = null


func collect() -> void:
	if player_in_range == null:
		return

	if collected:
		return

	collected = true

	player_in_range.equip_pistol()

	queue_free()
