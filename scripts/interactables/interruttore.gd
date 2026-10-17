extends Node3D
## Interruttore: il comando E funziona solo con alimentazione aziendale attiva.
## Per circuiti persistenti e materiali emissivi usare la variante zone_light_switch.gd.

@export_group("Collegamenti")
## Nodo che fornisce is_power_on e il segnale power_changed (nella mappa: ConnesiPower).
@export var power_system: Node
## Gruppo delle Light3D da comandare. La variante Zone Light Switch accetta anche una singola luce e gruppi annidati.
@export var lights_root: Node
@export_group("Interazione")
## Nome mostrato accanto al prompt E; non e' l'identificatore di salvataggio.
@export var interaction_name := "INTERRUTTORE"

const OUTLINE_SHADER := preload(
	"res://assets/shaders/interactable_outline_screen.gdshader"
)

@export_group("Evidenziamento")
## Colore del nome e del bordo quando il giocatore punta l'interruttore.
@export var interaction_color := Color("ffffff")
## Spessore del contorno a schermo. Non modifica geometria o collider.
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015
## Mesh da evidenziare, relative a questo nodo. Vuoto = tutte le mesh discendenti.
@export var interaction_visual_roots: Array[NodePath] = []

@export_group("Audio interruttore")
## Suono 3D all'accensione. Vuoto = nessun suono.
@export var switch_on_sound: AudioStream
## Suono 3D allo spegnimento; puo' essere lo stesso dell'accensione.
@export var switch_off_sound: AudioStream
## Volume del solo click in dB, sul bus SFX.
@export_range(-40.0, 12.0, 0.5) var switch_volume_db := 0.0
## Distanza massima in metri del click 3D.
@export_range(1.0, 50.0, 0.5) var audio_max_distance := 8.0

var outline_material: ShaderMaterial
var outlined_meshes: Array[GeometryInstance3D] = []

var switch_audio: AudioStreamPlayer3D
var lights_on := false


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

	if interaction_visual_roots.is_empty():
		_collect_interaction_geometry(self)
	else:
		for path: NodePath in interaction_visual_roots:
			var visual_root := get_node_or_null(path)
			if visual_root != null:
				_collect_interaction_geometry(visual_root)

	set_interaction_focus(false)


func _collect_interaction_geometry(node: Node) -> void:
	if node.name == "InteractionOutline":
		return
	if node.name == "OutlineBuilder":
		return
	if node.name == "InteractionOutlineProxy":
		return

	if node is GeometryInstance3D:
		outlined_meshes.append(node as GeometryInstance3D)

	for child: Node in node.get_children():
		_collect_interaction_geometry(child)


func set_interaction_focus(enabled: bool) -> void:
	for mesh: GeometryInstance3D in outlined_meshes:
		if not is_instance_valid(mesh):
			continue

		mesh.material_overlay = outline_material if enabled else null


func get_interaction_color() -> Color:
	return interaction_color


func _ready() -> void:
	_setup_audio()

	if power_system:
		power_system.power_changed.connect(_on_power_changed)

	_set_lights(false)
	_setup_interaction_outline()


func _setup_audio() -> void:
	switch_audio = AudioStreamPlayer3D.new()
	switch_audio.name = "SwitchAudio"
	switch_audio.bus = &"SFX"
	switch_audio.volume_db = switch_volume_db
	switch_audio.max_distance = audio_max_distance
	add_child(switch_audio)


func get_interaction_name() -> String:
	return interaction_name


func get_interaction_action() -> String:
	return "SPEGNI" if lights_on else "ACCENDI"


func interact(_player: Node) -> void:
	try_toggle_lights()


func try_toggle_lights() -> void:
	if power_system == null:
		return

	if not power_system.is_power_on():
		return

	lights_on = not lights_on
	_set_lights(lights_on)

	if lights_on:
		_play_switch_sound(switch_on_sound)
	else:
		_play_switch_sound(switch_off_sound)


func _play_switch_sound(stream: AudioStream) -> void:
	if switch_audio == null or stream == null:
		return

	switch_audio.stop()
	switch_audio.stream = stream
	switch_audio.volume_db = switch_volume_db
	switch_audio.max_distance = audio_max_distance
	switch_audio.play()


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
