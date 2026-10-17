
extends Area3D

@export_group("Contenuto pickup")
## Colpi aggiunti alla riserva pistola quando si raccoglie l'oggetto.
@export_range(1, 1000, 1, "or_greater") var ammo_amount := 12

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export_group("Interazione")
## Nome mostrato nel prompt del tasto E.
@export var interaction_name := "MUNIZIONI"
## Colore del nome e del bordo di selezione.
@export var interaction_color := Color("f2ad47")
## Spessore dell'evidenziamento.
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015

var outline_material: ShaderMaterial
var outlined_meshes: Array[GeometryInstance3D] = []


func _setup_interaction_outline() -> void:
	outline_material = ShaderMaterial.new()
	outline_material.shader = OUTLINE_SHADER
	outline_material.set_shader_parameter(
		"outline_color",
		interaction_color
	)
	outline_material.set_shader_parameter(
		"outline_width",
		outline_width
	)

	outlined_meshes.clear()
	_collect_interaction_geometry($AmmoVisual)
	set_interaction_focus(false)


func _collect_interaction_geometry(node: Node) -> void:
	if node is GeometryInstance3D:
		outlined_meshes.append(node as GeometryInstance3D)

	for child: Node in node.get_children():
		_collect_interaction_geometry(child)


func set_interaction_focus(enabled: bool) -> void:
	for mesh: GeometryInstance3D in outlined_meshes:
		if not is_instance_valid(mesh):
			continue

		mesh.material_overlay = outline_material if enabled else null


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "RACCOGLI"


func get_interaction_color() -> Color:
	return interaction_color


var collected := false


func _ready() -> void:
	_setup_interaction_outline()


func interact(player: Node) -> void:
	if collected:
		return

	if not player.has_method("add_ammo"):
		return

	collected = true
	set_interaction_focus(false)
	player.add_ammo(ammo_amount)

	get_tree().call_group(
		"player_face",
		"react",
		"pickup_small"
	)

	queue_free()
