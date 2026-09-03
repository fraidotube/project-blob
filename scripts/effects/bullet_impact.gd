extends Decal

@export var lifetime := 45.0


func _ready() -> void:
	var timer := get_tree().create_timer(lifetime)
	await timer.timeout

	if is_instance_valid(self):
		queue_free()
