extends Node3D

# Project Blob - Scala verticale SAFE V1
# Da applicare al Node3D radice della scala già posizionata nella mappa.
# Nodi figli richiesti: InteractionBody/CollisionShape3D,
# BottomAttach, TopAttach, BottomExit, TopExit (Marker3D).

@export var interaction_name: String = "SCALA"
@export var interaction_color: Color = Color.WHITE
@export_range(0.0001, 0.02, 0.0001) var outline_width: float = 0.0015
@export_range(0.3, 5.0, 0.1) var climb_speed: float = 1.6

const OUTLINE_SHADER = preload(
    "res://assets/shaders/interactable_outline_screen.gdshader"
)

@onready var bottom_attach: Marker3D = get_node_or_null("BottomAttach")
@onready var top_attach: Marker3D = get_node_or_null("TopAttach")
@onready var bottom_exit: Marker3D = get_node_or_null("BottomExit")
@onready var top_exit: Marker3D = get_node_or_null("TopExit")
@onready var interaction_body: StaticBody3D = get_node_or_null("InteractionBody")

var _outlined_meshes: Array[GeometryInstance3D] = []
var _outline_material: ShaderMaterial
var _climber: CharacterBody3D
var _interaction_system: Node
var _progress: float = 0.0
var _original_collision_layer: int = 0
var _original_collision_mask: int = 0
var _mounting: bool = false


func _ready() -> void:
	if (
		bottom_attach == null
		or top_attach == null
		or bottom_exit == null
		or top_exit == null
		or interaction_body == null
	):
		push_error(
            "LADDER: mancano BottomAttach, TopAttach, BottomExit, "
			+ "TopExit oppure InteractionBody."
		)
		set_physics_process(false)
		return

	# Solo il collider dedicato deve essere rilevato dall'InteractRay,
	# che nel Player corrente utilizza collision_mask = 2.
	interaction_body.collision_layer = 2
	interaction_body.collision_mask = 0

	_outline_material = ShaderMaterial.new()
	_outline_material.shader = OUTLINE_SHADER
	_outline_material.set_shader_parameter("outline_color", interaction_color)
	_outline_material.set_shader_parameter("outline_width", outline_width)
	_collect_visuals(self)


func _collect_visuals(node: Node) -> void:
	if node is GeometryInstance3D:
		_outlined_meshes.append(node as GeometryInstance3D)
	for child: Node in node.get_children():
		_collect_visuals(child)


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "USA SCALA"


func get_interaction_color() -> Color:
	return interaction_color


func set_interaction_focus(enabled: bool) -> void:
	if _outline_material == null:
		return
	for mesh: GeometryInstance3D in _outlined_meshes:
		if is_instance_valid(mesh):
			mesh.material_overlay = _outline_material if enabled else null


func interact(player: Node) -> void:
	if _climber != null or _mounting or not player is CharacterBody3D:
		return
	if bottom_attach == null or top_attach == null:
		return

	var character := player as CharacterBody3D
	if not character.is_in_group("player") or bool(character.get("is_dead")):
		return
	if bottom_attach.global_position.distance_to(top_attach.global_position) < 0.5:
		push_warning("LADDER: TopAttach e BottomAttach devono essere separati.")
		return

	_climber = character
	_original_collision_layer = character.collision_layer
	_original_collision_mask = character.collision_mask

	# Se il giocatore si trova vicino al piano superiore entra dall'alto.
	var enter_from_top := (
		character.global_position.distance_to(top_exit.global_position)
		< character.global_position.distance_to(bottom_exit.global_position)
	)
	_progress = 1.0 if enter_from_top else 0.0

	_interaction_system = character.get_node_or_null("InteractionSystem")
	if _interaction_system != null:
		if _interaction_system.has_method("_clear_focus"):
			_interaction_system.call("_clear_focus")
		_interaction_system.set_process(false)

	character.velocity = Vector3.ZERO
	character.set_physics_process(false)
	character.set_process_unhandled_input(false)
	character.collision_layer = 0
	character.collision_mask = 0

	# Aggancio senza scatti verticali estremi: spostamento in 0,25 secondi.
	var attach_marker := top_attach if enter_from_top else bottom_attach
	_mounting = true
	var tween := create_tween()
	tween.tween_property(
		character, "global_position", attach_marker.global_position, 0.25
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(
		character, "global_rotation:y", attach_marker.global_rotation.y, 0.25
	)
	tween.finished.connect(func() -> void:
		if is_instance_valid(character):
			_mounting = false
	)


func _physics_process(delta: float) -> void:
	if _climber == null or not is_instance_valid(_climber) or _mounting:
		return

	if bool(_climber.get("is_dead")):
		_release(false)
		return

	# W = su, S = giù. Tutti gli altri movimenti FPS restano sospesi.
	var axis: float = Input.get_axis("move_backward", "move_forward")
	if absf(axis) < 0.01:
		return

	var height := absf(top_attach.global_position.y - bottom_attach.global_position.y)
	if height < 0.5:
		return

	_progress = clampf(
		_progress + axis * climb_speed * delta / height,
		0.0,
		1.0
	)
	_climber.global_position = bottom_attach.global_position.lerp(
		top_attach.global_position, _progress
	)
	_climber.velocity = Vector3.ZERO

	if _progress >= 1.0 and axis > 0.0:
		_exit_at(top_exit)
	elif _progress <= 0.0 and axis < 0.0:
		_exit_at(bottom_exit)


func _unhandled_input(event: InputEvent) -> void:
	if _climber == null or _mounting:
		return
	# Alla base E permette anche di staccarsi senza premere S.
	if event.is_action_pressed("interact") and _progress <= 0.05:
		_exit_at(bottom_exit)
		get_viewport().set_input_as_handled()


func _exit_at(marker: Marker3D) -> void:
	if _climber == null or not is_instance_valid(_climber):
		return
	_climber.global_position = marker.global_position
	_climber.global_rotation.y = marker.global_rotation.y
	_release(true)


func _release(restore_controls: bool) -> void:
	if _climber != null and is_instance_valid(_climber):
		_climber.collision_layer = _original_collision_layer
		_climber.collision_mask = _original_collision_mask
		_climber.velocity = Vector3.ZERO
		if restore_controls:
			_climber.set_process_unhandled_input(true)
			_climber.set_physics_process(true)
	if _interaction_system != null and is_instance_valid(_interaction_system):
		_interaction_system.set_process(true)
	_interaction_system = null
	_climber = null
	_mounting = false
