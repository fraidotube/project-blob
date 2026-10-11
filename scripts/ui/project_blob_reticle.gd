extends Control

var radius := 10.0
var target_kind := "none"
var tint := Color(0.9, 0.86, 0.95, 0.8)
var player: Node
var sample_left := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta: float) -> void:
	if not is_instance_valid(player): player = get_tree().get_first_node_in_group("player")
	visible = is_instance_valid(player) and not bool(player.get("is_dead")) and player.is_physics_processing() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if not visible: return
	sample_left -= delta
	if sample_left <= 0.0:
		sample_left = 0.05
		target_kind = "none"
		var interaction := player.get_node_or_null("InteractionSystem")
		if interaction != null and is_instance_valid(interaction.focused_interactable): target_kind = "interaction"
		else:
			var ray := player.get_node_or_null("Head/Camera3D/WeaponRay") as RayCast3D
			if ray != null:
				ray.force_raycast_update()
				if ray.is_colliding(): target_kind = classify(ray.get_collider())
	var target_radius := 20.0 if target_kind == "enemy" else (24.0 if target_kind == "interaction" else 10.0)
	radius = lerpf(radius, target_radius, 1.0 - exp(-delta * 12.0))
	var target_tint := Color(1.0, 0.62, 0.5, 0.95) if target_kind == "enemy" else (Color(0.62, 1.0, 0.84, 0.95) if target_kind == "interaction" else Color(0.9, 0.86, 0.95, 0.8))
	tint = tint.lerp(target_tint, 1.0 - exp(-delta * 12.0))
	queue_redraw()

func classify(collider: Object) -> String:
	var node := collider as Node
	while is_instance_valid(node):
		if node.has_method("take_damage") and not node.is_in_group("player"): return "enemy"
		node = node.get_parent()
	return "none"

func _draw() -> void:
	var center := size * 0.5
	for i in range(4):
		var angle := i * PI * 0.5 + PI * 0.125
		draw_arc(center, radius, angle, angle + PI * 0.25, 12, Color(0, 0, 0, 0.7), 4.0, true)
		draw_arc(center, radius, angle, angle + PI * 0.25, 12, tint, 2.0, true)
	draw_circle(center, 2.8, Color(0, 0, 0, 0.7))
	draw_circle(center, 1.4, tint)
