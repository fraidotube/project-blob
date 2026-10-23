extends Node
## Barriera di preparazione della mappa: inizializzazioni e pose pronte prima del reveal.

@export_group("Collegamenti")
## Player reale da sincronizzare, senza riassegnare dotazioni o trasformazioni.
@export var player: CharacterBody3D
## Pool e grafo Broccolo: attende ready_for_test mentre il gioco resta coperto.
@export var broccolo_combat: Node
## Controller incontro Angelastri da preparare dopo il ripristino, senza avviare cinematiche.
@export var angelastri_encounter: Node
## Aree audio da allineare subito alla posizione finale del checkpoint.
@export var indoor_zones: Array[NodePath] = []
## AnimationPlayer delle braccia: applica la posa corrente senza far avanzare azioni.
@export var arms_animation: AnimationPlayer
## Gestore gia presente in scena: evita creazione e scoperta audio al primo sparo.
@export var impact_manager: Node3D
## Prepara anche le varianti grafiche degli impatti prima di mostrare la partita.
@export var warmup_impact_render := true

@export_group("Mix ambientale")
## Guadagno del solo bus Ambience in dB, relativo agli altri suoni. Prima era +2dB.
@export_range(-30.0, 6.0, 0.5) var ambience_bus_volume_db := -8.0

var prepared := false

func _ready() -> void:
	add_to_group("scene_loading_preparation")
	var bus := AudioServer.get_bus_index("Ambience")
	if bus >= 0: AudioServer.set_bus_volume_db(bus, ambience_bus_volume_db)

func wait_for_initialization() -> void:
	while is_inside_tree():
		var ready := broccolo_combat == null or bool(broccolo_combat.ready_for_test)
		if angelastri_encounter != null:
			ready = ready and bool(angelastri_encounter.configured)
			if ready: ready = not angelastri_encounter.preview.busy
		if ready: return
		await get_tree().process_frame

func prepare_for_reveal() -> void:
	prepared = false
	if angelastri_encounter != null:
		# world_restored cleared the previous preview under the loading screen.
		if angelastri_encounter.recreate_actor:
			angelastri_encounter.recreate_actor = false
			await angelastri_encounter._restore_actor()
		else:
			await angelastri_encounter._prewarm_performance()
	if arms_animation != null:
		arms_animation.advance(0.0)
	if warmup_impact_render and impact_manager != null:
		await impact_manager.prepare_rendering()
	for path in indoor_zones:
		var zone := get_node_or_null(path)
		if zone != null: zone.synchronize_player(player)
	prepared = true
