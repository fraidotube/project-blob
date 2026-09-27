extends Node3D

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export var power_system: Node
@export var led_red: Light3D
@export var led_green: Light3D

@export var interaction_name := "CONTATORE"
@export var interaction_color := Color("b86cff")
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015

@onready var interaction_outline: MeshInstance3D = (
	get_node_or_null("InteractionOutline")
)

var outline_material: ShaderMaterial


func _ready() -> void:
	if power_system:
		power_system.power_changed.connect(
			_on_power_changed
		)
		_update_leds(
			power_system.is_power_on()
		)
	else:
		_update_leds(false)

	_setup_interaction_outline()


func _setup_interaction_outline() -> void:
	if interaction_outline == null:
		push_warning(
			"CONTATORE: nodo InteractionOutline non trovato."
		)
		return

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

	interaction_outline.material_override = (
		outline_material
	)

	interaction_outline.cast_shadow = (
		GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	)

	interaction_outline.visible = false


func set_interaction_focus(enabled: bool) -> void:
	if interaction_outline == null:
		return

	if not is_instance_valid(interaction_outline):
		return

	interaction_outline.visible = enabled


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	if power_system == null:
		return "USA"

	return (
		"DISATTIVA"
		if power_system.is_power_on()
		else "ATTIVA"
	)


func get_interaction_color() -> Color:
	return interaction_color


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
