extends Area3D

@export_group("Fire Damage")
@export_range(1, 100, 1) var damage_per_tick: int = 5
@export_range(0.1, 10.0, 0.1) var damage_interval: float = 0.5

var _player: Node = null
var _damage_timer: Timer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_damage_timer = Timer.new()
	_damage_timer.name = "DamageTimer"
	_damage_timer.one_shot = false
	_damage_timer.wait_time = damage_interval
	_damage_timer.timeout.connect(_on_damage_timer_timeout)
	add_child(_damage_timer)

	call_deferred("_sync_initial_overlaps")


func _sync_initial_overlaps() -> void:
	for body: Node3D in get_overlapping_bodies():
		if body.is_in_group("player"):
			_enter_fire(body)
			return


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_enter_fire(body)


func _on_body_exited(body: Node3D) -> void:
	if body != _player:
		return

	_player = null
	_damage_timer.stop()


func _enter_fire(body: Node3D) -> void:
	if _player != null:
		return

	_player = body
	_apply_damage()

	_damage_timer.wait_time = damage_interval
	_damage_timer.start()


func _on_damage_timer_timeout() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = null
		_damage_timer.stop()
		return

	_apply_damage()


func _apply_damage() -> void:
	if _player != null and _player.has_method("take_damage"):
		_player.take_damage(damage_per_tick)
