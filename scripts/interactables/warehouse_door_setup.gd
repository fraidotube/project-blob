@tool
extends Node
## Configurazione di un battente in WarehouseDoors.
## Si modifica qui nell'Inspector; il controller fisico viene creato solo in gioco.
## La geometria importata non viene modificata o spostata nell'editor.

@export_group("Mesh e pannello")
## Anta mobile con tutte le sue maniglie/griglie/vetri. Non selezionare il telaio fisso.
## Per il CED selezionare il gruppo Porta DC, che contiene anche le maniglie.
@export var source_visual: Node3D:
	set(value):
		source_visual = value
		_refresh_warnings()
## Facoltativo se Source Visual e' gia' una MeshInstance3D.
## Nei gruppi indica la mesh dell'anta da cui ricavare ingombro e cardine (CED: Porta_092).
@export var panel_source: MeshInstance3D:
	set(value):
		panel_source = value
		_refresh_warnings()

@export_group("Identita e salvataggio")
## Nome del controller creato nella radice della mappa durante il gioco. Deve essere unico.
@export var runtime_name: StringName:
	set(value):
		runtime_name = value
		_refresh_warnings()
## ID unico e stabile del salvataggio. Non cambiarlo per rinominare la porta.
## Quando duplichi una configurazione, assegna alla nuova porta un ID diverso.
@export var persistent_id: StringName:
	set(value):
		persistent_id = value
		_refresh_warnings()
## Nome mostrato nel prompt quando il giocatore guarda la porta.
@export var interaction_name := "PORTA"

@export_group("Movimento")
## Asse MONDIALE lungo la larghezza dell'anta chiusa, non l'asse locale del modello.
## X: anta parallela a X; Z: anta parallela a Z. L'asse verticale e' sempre Y.
@export_enum("X:0", "Z:2") var width_axis: int = 2:
	set(value):
		width_axis = value
		_refresh_warnings()
## Attivo: cardine all'estremo massimo dell'asse scelto. Spento: all'estremo minimo.
## Il cardine viene ricavato dai limiti reali del pannello: non sposta la mesh chiusa.
@export var hinge_at_max := true
## Angolo in gradi attorno a Y. Cambia il segno per invertire il verso di apertura.
## Il verso usato dalla protezione del giocatore viene calcolato automaticamente.
@export_range(-170.0, 170.0, 1.0) var open_angle := 90.0:
	set(value):
		open_angle = value
		_refresh_warnings()
## Rapidita dell'interpolazione. Valore attuale 4; piu' alto significa piu' veloce.
@export_range(0.1, 20.0, 0.1) var open_speed := 4.0
## Richiede la chiusura automatica dopo l'apertura; le protezioni del passaggio restano attive.
@export var auto_close := false
## Consente ai Broccolo di aprire questa porta con un salto, senza aggirare serrature.
@export var enemy_jump_open_enabled := false
## Secondi prima della richiesta di chiusura automatica. Usato solo se Auto Close e' attivo.
@export_range(0.1, 120.0, 0.1) var auto_close_delay := 3.0

@export_group("Serratura")
## ID dell'oggetto inventario richiesto (es. switch_key). Vuoto = nessuna chiave.
## La chiave non viene consumata e lo sblocco viene salvato. Non crea un pickup.
@export var required_key: StringName:
	set(value):
		required_key = value
		_refresh_warnings()
## Porta comandata dal lettore di WarehouseDoors. Non combinare con Required Key.
## Il lettore concede una finestra di apertura; non completa l'enigma di acquisizione impronta.
@export var fingerprint_locked := false:
	set(value):
		fingerprint_locked = value
		_refresh_warnings()

@export_group("Audio")
## Suono all'inizio dell'apertura. Vuoto = apertura silenziosa.
@export var open_sound: AudioStream = preload("res://assets/audio/interactions/door/lab_metal-door-open.wav")
## Suono di chiusura, normalmente riprodotto quando l'anta arriva a battuta.
@export var close_sound: AudioStream = preload("res://assets/audio/interactions/door/lab_metal-door-closing.wav")
## Anticipa il suono di chiusura all'inizio del movimento (utile per gli sportelli).
@export var close_sound_at_start := false
## Volume del solo suono della porta, sul bus SFX. Non modifica il mix generale.
@export_range(-40.0, 12.0, 0.5) var door_audio_volume_db := 0.0
## Distanza massima in metri dell'audio 3D.
@export_range(1.0, 50.0, 0.5) var door_audio_max_distance := 12.0

@export_group("Evidenziamento")
## Colore del nome e del bordo quando il giocatore punta il battente.
@export var interaction_color := Color.WHITE
## Spessore del bordo a schermo. Non cambia la mesh o la collisione.
@export_range(0.0001, 0.02, 0.0001) var outline_width := 0.0015

func _ready() -> void:
	if Engine.is_editor_hint(): _refresh_warnings.call_deferred()

func _refresh_warnings() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree(): return
	update_configuration_warnings()
	var parent := get_parent()
	if parent == null: return
	for sibling in parent.get_children():
		if sibling != self and sibling.get_script() == get_script(): sibling.update_configuration_warnings()
	parent.update_configuration_warnings()

func get_panel() -> MeshInstance3D:
	return panel_source if panel_source != null else source_visual as MeshInstance3D

func validation_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if source_visual == null: errors.append("Seleziona Source Visual: la sola parte mobile della porta.")
	var panel := get_panel()
	if panel == null or panel.mesh == null:
		errors.append("Seleziona una mesh pannello valida; nei gruppi compila Panel Source.")
	elif source_visual != null and panel != source_visual and not source_visual.is_ancestor_of(panel):
		errors.append("Panel Source deve appartenere a Source Visual.")
	if runtime_name.is_empty(): errors.append("Runtime Name deve essere compilato e unico.")
	elif String(runtime_name).validate_node_name() != String(runtime_name): errors.append("Runtime Name contiene caratteri non validi per un nodo.")
	if persistent_id.is_empty(): errors.append("Persistent Id deve essere compilato e unico.")
	if width_axis not in [0,2]: errors.append("Width Axis deve essere X o Z.")
	if absf(open_angle) < 1.0 or absf(open_angle) > 170.0: errors.append("Usa un angolo tra 1 e 170 gradi, positivo o negativo.")
	if open_speed <= 0.0 or auto_close_delay <= 0.0: errors.append("Velocita e ritardo devono essere positivi.")
	if fingerprint_locked and not required_key.is_empty(): errors.append("Scegli chiave oppure fingerprint, non entrambi.")
	return errors

func _get_configuration_warnings() -> PackedStringArray:
	var errors := validation_errors()
	if get_parent() != null:
		for sibling in get_parent().get_children():
			if sibling == self or sibling.get_script() != get_script(): continue
			if not persistent_id.is_empty() and sibling.persistent_id == persistent_id: errors.append("Persistent Id duplicato: assegnane uno nuovo alla porta duplicata.")
			if not runtime_name.is_empty() and sibling.runtime_name == runtime_name: errors.append("Runtime Name duplicato: i controller devono avere nomi diversi.")
			if source_visual != null and sibling.source_visual == source_visual: errors.append("La stessa anta e' assegnata a due configurazioni.")
	return errors
