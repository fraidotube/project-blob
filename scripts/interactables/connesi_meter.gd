extends Node3D

@export var power_system: Node
@export var led_red: Light3D
@export var led_green: Light3D

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var interaction_name := "CONTATORE"
@export var interaction_color := Color("b86cff")
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
	_collect_interaction_geometry(self)
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
	return "DISATTIVA" if power_system != null and power_system.is_power_on() else "ATTIVA"


func get_interaction_color() -> Color:
	return interaction_color



func _ready() -> void:
	if power_system:
		power_system.power_changed.connect(_on_power_changed)
		_update_leds(power_system.is_power_on())
	else:
		_update_leds(false)

	_setup_interaction_outline()


func interact(_player: Node) -> void:
	toggle_meter()


func toggle_meter() -> void:
	if power_system == null:
		return

	power_system.toggle_power()


func _on_power_changed(is_on: bool) -> void:
	_update_leds(is_on)


func _update_leds(is_on: bool) -> void:
	if led_red:
		led_red.visible = not is_on

	if led_green:
		led_green.visible = is_on
