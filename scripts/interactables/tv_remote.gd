extends Area3D

@export var tv_controller: Node
@export var interaction_name := "TELECOMANDO"

const InteractableOutlineProxy := preload(
	"res://scripts/systems/interactable_outline_proxy.gd"
)

@export var interaction_color := Color("b86cff")
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



func _ready() -> void:
	_setup_interaction_outline()


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "USA"


func interact(_player: Node) -> void:
	if tv_controller == null:
		return

	if tv_controller.has_method("toggle_tv"):
		tv_controller.toggle_tv()
