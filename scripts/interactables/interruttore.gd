extends Node3D

@export var power_system: Node
@export var lights_root: Node
@export var interaction_name := "INTERRUTTORE"

const InteractableOutlineProxy := preload(
	"res://scripts/systems/interactable_outline_proxy.gd"
)

@export var interaction_color := Color("ffffff")
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015

# Normalmente lasciare vuoto: V5 trova automaticamente tutte le mesh
# comprese nel volume del collider di interazione (collision layer 2).
# Per casi speciali si possono indicare uno o più visual root manualmente.
@export var interaction_visual_roots: Array[NodePath] = []

@export_range(0.0, 0.25, 0.005) var interaction_outline_margin := 0.035
@export_range(1.0, 10.0, 0.25) var interaction_outline_max_size_multiplier := 3.0

var interaction_outline := InteractableOutlineProxy.new()


func _setup_interaction_outline() -> void:
	interaction_outline.setup(
		self,
		interaction_color,
		outline_width,
		interaction_visual_roots,
		interaction_outline_margin,
		interaction_outline_max_size_multiplier
	)


func set_interaction_focus(enabled: bool) -> void:
	interaction_outline.set_enabled(enabled)


func get_interaction_color() -> Color:
	return interaction_color


var lights_on := false


func _ready() -> void:
	if power_system:
		power_system.power_changed.connect(
			_on_power_changed
		)

	_set_lights(false)
	_setup_interaction_outline()


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return (
		"SPEGNI"
		if lights_on
		else "ACCENDI"
	)


func interact(_player: Node) -> void:
	try_toggle_lights()


func try_toggle_lights() -> void:
	if power_system == null:
		return

	if not power_system.is_power_on():
		return

	lights_on = not lights_on
	_set_lights(lights_on)


func _set_lights(enabled: bool) -> void:
	if lights_root == null:
		return

	for child: Node in lights_root.get_children():
		if child is Light3D:
			child.visible = enabled


func _on_power_changed(is_on: bool) -> void:
	if not is_on:
		lights_on = false
		_set_lights(false)
