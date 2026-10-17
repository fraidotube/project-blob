extends Node

@export_group("Collegamenti interazione")
## RayCast3D per focus e tasto E, relativo a questo nodo. La sua Target Position
## determina la distanza (2 m nel player); mantenere collision mask 2 e aree abilitate.
@export_node_path("RayCast3D") var ray_path: NodePath = NodePath("../Head/Camera3D/InteractRay")

@onready var interact_ray: RayCast3D = get_node(ray_path)
@onready var prompt: Control = $InteractionHUD/Prompt
@onready var name_label: Label = $InteractionHUD/Prompt/Name
@onready var action_label: Label = $InteractionHUD/Prompt/Action

var focused_interactable: Node = null


func _ready() -> void:
	prompt.visible = false


func _process(_delta: float) -> void:
	# Se la HUD principale è nascosta, per esempio durante
	# una cinematic o alla morte del player, anche il sistema
	# di interazione deve rimanere completamente nascosto.
	if not _is_game_hud_visible():
		_clear_focus()
		return

	_update_focus()

	if not Input.is_action_just_pressed("interact"):
		return

	if focused_interactable == null:
		return

	if not is_instance_valid(focused_interactable):
		_clear_focus()
		return

	if not focused_interactable.has_method("interact"):
		_clear_focus()
		return

	# Salviamo il target e liberiamo SUBITO focus/HUD.
	# I pickup fanno queue_free() durante interact(): non dobbiamo
	# mantenere un riferimento all'oggetto che sta per essere distrutto.
	var target: Node = focused_interactable

	_clear_focus()

	if is_instance_valid(target):
		target.interact(get_parent())


func _is_game_hud_visible() -> bool:
	var hud_nodes := get_tree().get_nodes_in_group(
		"hud"
	)

	# Se non esiste una HUD registrata non blocchiamo
	# il sistema di interazione.
	if hud_nodes.is_empty():
		return true

	for hud: Node in hud_nodes:
		if not is_instance_valid(hud):
			continue

		var interface := hud.get_node_or_null(
			"Interface"
		)

		if interface is CanvasItem:
			return interface.visible

	return true


func _update_focus() -> void:
	if focused_interactable != null and not is_instance_valid(focused_interactable):
		focused_interactable = null
		prompt.visible = false

	interact_ray.force_raycast_update()

	var candidate: Node = null

	if interact_ray.is_colliding():
		var collider := interact_ray.get_collider()

		if collider != null and is_instance_valid(collider):
			candidate = _find_interactable(collider)

	if candidate == focused_interactable:
		return

	_clear_focus()
	focused_interactable = candidate

	if focused_interactable == null:
		return

	if not is_instance_valid(focused_interactable):
		focused_interactable = null
		return

	if focused_interactable.has_method("set_interaction_focus"):
		focused_interactable.set_interaction_focus(true)

	if focused_interactable.has_method("get_interaction_name"):
		name_label.text = focused_interactable.get_interaction_name()
	else:
		name_label.text = ""

	if focused_interactable.has_method("get_interaction_action"):
		action_label.text = (
			"[ E ]  "
			+ focused_interactable.get_interaction_action()
		)
	else:
		action_label.text = "[ E ]"

	if focused_interactable.has_method("get_interaction_color"):
		name_label.add_theme_color_override(
			"font_color",
			focused_interactable.get_interaction_color()
		)

	prompt.visible = true


func _clear_focus() -> void:
	if (
		focused_interactable != null
		and is_instance_valid(
			focused_interactable
		)
	):
		if focused_interactable.has_method(
			"set_interaction_focus"
		):
			focused_interactable.set_interaction_focus(
				false
			)

	focused_interactable = null
	prompt.visible = false


func _find_interactable(
	start_node: Node
) -> Node:
	if (
		start_node == null
		or not is_instance_valid(
			start_node
		)
	):
		return null

	var current: Node = start_node

	while (
		current != null
		and is_instance_valid(
			current
		)
	):
		if (
			current.has_method(
				"get_interaction_name"
			)
			and current.has_method(
				"get_interaction_action"
			)
			and current.has_method(
				"interact"
			)
		):
			return current

		current = current.get_parent()

	return null
