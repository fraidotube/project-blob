extends Node3D

var puzzle: Node
var overlay: CanvasLayer
var panel: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay = CanvasLayer.new()
	overlay.layer = 91
	add_child(overlay)
	panel = PanelContainer.new()
	panel.position = Vector2(24, 24)
	var column := VBoxContainer.new()
	panel.add_child(column)
	var connections := Button.new()
	connections.text = "COLLEGAMENTI"
	connections.custom_minimum_size = Vector2(220, 44)
	connections.pressed.connect(func():
		await GameplayUI.close_modal()
		puzzle._router_choice()
	)
	column.add_child(connections)
	var close := Button.new()
	close.text = "TORNA AL GIOCO [ESC]"
	close.custom_minimum_size = Vector2(220, 44)
	close.pressed.connect(GameplayUI.close_modal)
	column.add_child(close)
	overlay.add_child(panel)
	panel.hide()

func camera_target() -> Transform3D:
	var router: MeshInstance3D = puzzle.fritz
	var center: Vector3 = router.global_transform * router.get_aabb().get_center()
	return Transform3D(Basis.IDENTITY, center + Vector3.UP * 0.62).looking_at(center, router.global_basis.x.normalized())

func requires_save_eligibility() -> bool:
	return false

func set_terminal_active(enabled: bool, input_ready: bool) -> void:
	panel.visible = enabled and input_ready

func handle_pointer(event: InputEvent, _camera: Camera3D) -> void:
	# GameplayUI consumes terminal events before the main viewport GUI phase.
	if not panel.visible or not event is InputEventMouseButton:
		return
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for button: Button in panel.find_children("*", "Button", true, false):
			if button.get_global_rect().has_point(event.position):
				button.pressed.emit()
				return
