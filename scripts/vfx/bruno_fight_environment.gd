extends Node

const BOSS_MUSIC := preload(
	"res://assets/audio/ProjectBlob - Soundtrack.mp3"
)

@export_category("References")
@export var bruno: Node
@export var lamp_controller_1: Node
@export var lamp_controller_2: Node
@export var lab_exit_door: Node

@export_category("Boss Fight Audio")
@export var normal_ambient_player: Node
@export_range(-40.0, 12.0, 0.5) var boss_music_volume_db: float = -8.0
@export_range(0.0, 5.0, 0.05) var boss_music_fade_in_time: float = 1.0
@export_range(0.0, 5.0, 0.05) var boss_music_fade_out_time: float = 0.65

@export var bruno_death_audio: AudioStream
@export_range(-40.0, 12.0, 0.5) var bruno_death_volume_db: float = 0.0
@export var bruno_death_bus: StringName = &"Master"
@export_range(1.0, 50.0, 0.5) var bruno_death_max_distance: float = 20.0

@export_category("Debug")
@export var debug_logs: bool = true
@export var debug_music_logs: bool = true

var _fight_environment_started: bool = false
var _fight_environment_finished: bool = false

var _ambient_was_playing: bool = false
var _ambient_playback_position: float = 0.0

var _boss_music_player: AudioStreamPlayer = null
var _death_audio_player: AudioStreamPlayer3D = null

var _debug_last_ai_active: Variant = null
var _debug_last_cinematic_locked: Variant = null
var _debug_music_started_check_done: bool = false


func _ready() -> void:
	if debug_music_logs:
		print("")
		print("============================================================")
		print("[BRUNO MUSIC DEBUG] _ready()")
		print("[BRUNO MUSIC DEBUG] Node: ", get_path())
		print("[BRUNO MUSIC DEBUG] Bruno assigned: ", bruno != null)

		if bruno != null:
			print("[BRUNO MUSIC DEBUG] Bruno path: ", bruno.get_path())

		print(
			"[BRUNO MUSIC DEBUG] BOSS_MUSIC resource: ",
			BOSS_MUSIC
		)
		print(
			"[BRUNO MUSIC DEBUG] BOSS_MUSIC type: ",
			BOSS_MUSIC.get_class() if BOSS_MUSIC != null else "<null>"
		)

		_debug_print_audio_bus_state("Music")
		print("============================================================")
		print("")

	_setup_boss_music_player()
	_setup_death_audio_player()


func _process(_delta: float) -> void:
	if bruno == null:
		return

	if debug_music_logs:
		_debug_report_bruno_state_changes()

	if not _fight_environment_started:
		_try_start_fight_environment()
		return

	if not _fight_environment_finished:
		_try_finish_fight_environment()

	if (
		debug_music_logs
		and _fight_environment_started
		and not _debug_music_started_check_done
	):
		_debug_music_started_check_done = true
		call_deferred("_debug_check_music_after_start")


func _debug_report_bruno_state_changes() -> void:
	if not _has_property(bruno, &"ai_active"):
		return

	if not _has_property(bruno, &"cinematic_locked"):
		return

	var ai_value: Variant = bruno.get("ai_active")
	var cinematic_value: Variant = bruno.get("cinematic_locked")

	if (
		ai_value != _debug_last_ai_active
		or cinematic_value != _debug_last_cinematic_locked
	):
		print(
			"[BRUNO MUSIC DEBUG] Bruno state | ai_active=",
			ai_value,
			" | cinematic_locked=",
			cinematic_value
		)

		_debug_last_ai_active = ai_value
		_debug_last_cinematic_locked = cinematic_value


func _try_start_fight_environment() -> void:
	if not _has_property(bruno, &"ai_active"):
		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] ERRORE: Bruno non espone ai_active"
			)
		return

	if not _has_property(bruno, &"cinematic_locked"):
		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] ERRORE: Bruno non espone cinematic_locked"
			)
		return

	var ai_active := bool(bruno.get("ai_active"))
	var cinematic_locked := bool(bruno.get("cinematic_locked"))

	if not ai_active:
		return

	if cinematic_locked:
		return

	if debug_music_logs:
		print("")
		print("============================================================")
		print("[BRUNO MUSIC DEBUG] >>> BOSS FIGHT RILEVATA <<<")
		print(
			"[BRUNO MUSIC DEBUG] ai_active=",
			ai_active,
			" cinematic_locked=",
			cinematic_locked
		)
		print("============================================================")
		print("")

	_start_fight_environment()


func _start_fight_environment() -> void:
	if _fight_environment_started:
		return

	_fight_environment_started = true

	if debug_music_logs:
		print("[BRUNO MUSIC DEBUG] _start_fight_environment()")

	_stop_normal_ambient()
	_start_boss_music()

	_break_lamp(lamp_controller_1, "Lampione 1")
	_break_lamp(lamp_controller_2, "Lampione 2")
	_force_lab_door_open()

	if debug_logs:
		print(
			"[BRUNO ENV] Fight rilevata -> "
			+ "boss music + lampioni rotti + porta Lab bloccata aperta."
		)


func _try_finish_fight_environment() -> void:
	if not _has_property(bruno, &"health"):
		return

	var bruno_health := int(bruno.get("health"))

	if bruno_health > 0:
		return

	_finish_fight_environment()


func _finish_fight_environment() -> void:
	if _fight_environment_finished:
		return

	_fight_environment_finished = true

	if debug_music_logs:
		print("")
		print("[BRUNO MUSIC DEBUG] >>> BRUNO HEALTH <= 0 <<<")
		print("[BRUNO MUSIC DEBUG] avvio chiusura audio boss")

	_play_bruno_death_audio()
	_release_lab_door()
	_stop_boss_music_and_restore_ambient()

	if debug_logs:
		print(
			"[BRUNO ENV] Bruno morto -> "
			+ "audio morte + musica normale + porta Lab normale. "
			+ "I lampioni restano rotti."
		)


# ============================================================
# BOSS MUSIC
# ============================================================

func _setup_boss_music_player() -> void:
	if _boss_music_player != null:
		return

	if debug_music_logs:
		print("[BRUNO MUSIC DEBUG] Creo AudioStreamPlayer boss...")

	_boss_music_player = AudioStreamPlayer.new()
	_boss_music_player.name = "BrunoBossMusic"
	_boss_music_player.stream = BOSS_MUSIC
	_boss_music_player.bus = &"Music"
	_boss_music_player.volume_db = -60.0
	add_child(_boss_music_player)

	var mp3_stream := BOSS_MUSIC as AudioStreamMP3

	if mp3_stream != null:
		mp3_stream.loop = true

	if debug_music_logs:
		print(
			"[BRUNO MUSIC DEBUG] Player creato: ",
			_boss_music_player.get_path()
		)
		print(
			"[BRUNO MUSIC DEBUG] Player stream: ",
			_boss_music_player.stream
		)
		print(
			"[BRUNO MUSIC DEBUG] Player bus: ",
			_boss_music_player.bus
		)
		print(
			"[BRUNO MUSIC DEBUG] Player volume iniziale: ",
			_boss_music_player.volume_db,
			" dB"
		)
		print(
			"[BRUNO MUSIC DEBUG] MP3 cast valido: ",
			mp3_stream != null
		)


func _start_boss_music() -> void:
	if debug_music_logs:
		print("")
		print("[BRUNO MUSIC DEBUG] _start_boss_music()")

	if _boss_music_player == null:
		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] Player null -> provo a ricrearlo"
			)
		_setup_boss_music_player()

	if _boss_music_player == null:
		push_error(
			"[BRUNO MUSIC DEBUG] IMPOSSIBILE creare BrunoBossMusic."
		)
		return

	if BOSS_MUSIC == null:
		push_error(
			"[BRUNO MUSIC DEBUG] BOSS_MUSIC è NULL."
		)
		return

	_debug_print_audio_bus_state("Master")
	_debug_print_audio_bus_state("Music")

	_boss_music_player.stop()
	_boss_music_player.stream = BOSS_MUSIC
	_boss_music_player.bus = &"Music"
	_boss_music_player.volume_db = -60.0

	if debug_music_logs:
		print(
			"[BRUNO MUSIC DEBUG] Prima di play | stream=",
			_boss_music_player.stream,
			" | bus=",
			_boss_music_player.bus,
			" | volume=",
			_boss_music_player.volume_db
		)

	_boss_music_player.play()

	if debug_music_logs:
		print(
			"[BRUNO MUSIC DEBUG] Subito dopo play() | playing=",
			_boss_music_player.playing,
			" | playback_pos=",
			_boss_music_player.get_playback_position()
		)

	if boss_music_fade_in_time <= 0.0:
		_boss_music_player.volume_db = boss_music_volume_db

		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] Fade IN disabilitato. volume=",
				_boss_music_player.volume_db
			)

		return

	var tween := create_tween()

	tween.tween_property(
		_boss_music_player,
		"volume_db",
		boss_music_volume_db,
		boss_music_fade_in_time
	)

	if debug_music_logs:
		print(
			"[BRUNO MUSIC DEBUG] Fade IN avviato | target=",
			boss_music_volume_db,
			" dB | durata=",
			boss_music_fade_in_time,
			"s"
		)


func _debug_check_music_after_start() -> void:
	await get_tree().create_timer(1.5).timeout

	if not is_inside_tree():
		return

	print("")
	print("[BRUNO MUSIC DEBUG] CHECK +1.5s")

	if _boss_music_player == null:
		print("[BRUNO MUSIC DEBUG] ERRORE: player NULL a +1.5s")
		return

	print(
		"[BRUNO MUSIC DEBUG] playing=",
		_boss_music_player.playing
	)
	print(
		"[BRUNO MUSIC DEBUG] playback_position=",
		_boss_music_player.get_playback_position()
	)
	print(
		"[BRUNO MUSIC DEBUG] volume_db=",
		_boss_music_player.volume_db
	)
	print(
		"[BRUNO MUSIC DEBUG] stream=",
		_boss_music_player.stream
	)
	print(
		"[BRUNO MUSIC DEBUG] bus=",
		_boss_music_player.bus
	)

	_debug_print_audio_bus_state("Master")
	_debug_print_audio_bus_state("Music")

	print("[BRUNO MUSIC DEBUG] FINE CHECK +1.5s")
	print("")


func _stop_boss_music_and_restore_ambient() -> void:
	if debug_music_logs:
		print("[BRUNO MUSIC DEBUG] _stop_boss_music_and_restore_ambient()")

	if _boss_music_player == null:
		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] Boss player null -> ripristino ambient"
			)
		_restore_normal_ambient()
		return

	if not _boss_music_player.playing:
		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] Boss music non playing -> ripristino ambient"
			)
		_restore_normal_ambient()
		return

	if boss_music_fade_out_time <= 0.0:
		_boss_music_player.stop()
		_restore_normal_ambient()
		return

	var tween := create_tween()

	tween.tween_property(
		_boss_music_player,
		"volume_db",
		-60.0,
		boss_music_fade_out_time
	)

	await tween.finished

	if not is_inside_tree():
		return

	_boss_music_player.stop()
	_restore_normal_ambient()

	if debug_music_logs:
		print("[BRUNO MUSIC DEBUG] Boss music fermata dopo fade OUT")


func _debug_print_audio_bus_state(
	bus_name: String
) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)

	if bus_index < 0:
		print(
			"[BRUNO MUSIC DEBUG] BUS NON TROVATO: ",
			bus_name
		)
		return

	print(
		"[BRUNO MUSIC DEBUG] BUS ",
		bus_name,
		" | index=",
		bus_index,
		" | mute=",
		AudioServer.is_bus_mute(bus_index),
		" | volume_db=",
		AudioServer.get_bus_volume_db(bus_index),
		" | send=",
		AudioServer.get_bus_send(bus_index)
	)


# ============================================================
# NORMAL AMBIENT
# ============================================================

func _stop_normal_ambient() -> void:
	if normal_ambient_player == null:
		push_warning(
			"[BRUNO ENV] Normal Ambient Player non assegnato."
		)

		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] Ambient player = NULL"
			)

		return

	_ambient_was_playing = bool(
		normal_ambient_player.get("playing")
	)

	if normal_ambient_player.has_method(
		"get_playback_position"
	):
		_ambient_playback_position = float(
			normal_ambient_player.call(
				"get_playback_position"
			)
		)
	else:
		_ambient_playback_position = 0.0

	if debug_music_logs:
		print(
			"[BRUNO MUSIC DEBUG] Ambient player: ",
			normal_ambient_player.get_path(),
			" | playing prima stop=",
			_ambient_was_playing,
			" | pos=",
			_ambient_playback_position
		)

	if normal_ambient_player.has_method("stop"):
		normal_ambient_player.call("stop")

	if debug_logs:
		print(
			"[BRUNO ENV] Ambient normale fermato | ",
			normal_ambient_player.get_path()
		)


func _restore_normal_ambient() -> void:
	if normal_ambient_player == null:
		return

	if not _ambient_was_playing:
		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] Ambient non era playing: non lo riavvio"
			)
		return

	if not normal_ambient_player.has_method("play"):
		return

	normal_ambient_player.call(
		"play",
		_ambient_playback_position
	)

	if debug_logs:
		print(
			"[BRUNO ENV] Ambient normale ripristinato | ",
			normal_ambient_player.get_path()
		)


# ============================================================
# BRUNO DEATH AUDIO
# ============================================================

func _setup_death_audio_player() -> void:
	if _death_audio_player != null:
		return

	_death_audio_player = AudioStreamPlayer3D.new()
	_death_audio_player.name = "BrunoDeathAudio"
	_death_audio_player.bus = bruno_death_bus
	_death_audio_player.volume_db = bruno_death_volume_db
	_death_audio_player.max_distance = bruno_death_max_distance

	if bruno != null:
		bruno.add_child(_death_audio_player)
	else:
		add_child(_death_audio_player)

	if debug_music_logs:
		print(
			"[BRUNO MUSIC DEBUG] Death Audio player creato | parent=",
			_death_audio_player.get_parent().get_path()
		)


func _play_bruno_death_audio() -> void:
	if bruno_death_audio == null:
		push_warning(
			"[BRUNO ENV] Bruno Death Audio non assegnato."
		)

		if debug_music_logs:
			print(
				"[BRUNO MUSIC DEBUG] Death audio resource = NULL"
			)

		return

	if _death_audio_player == null:
		_setup_death_audio_player()

	if _death_audio_player == null:
		return

	_death_audio_player.stop()
	_death_audio_player.stream = bruno_death_audio
	_death_audio_player.bus = bruno_death_bus
	_death_audio_player.volume_db = bruno_death_volume_db
	_death_audio_player.max_distance = bruno_death_max_distance
	_death_audio_player.play()

	if debug_music_logs:
		print(
			"[BRUNO MUSIC DEBUG] Death audio play() | playing=",
			_death_audio_player.playing,
			" | stream=",
			_death_audio_player.stream,
			" | bus=",
			_death_audio_player.bus
		)


# ============================================================
# LAMPS
# ============================================================

func _break_lamp(
	lamp: Node,
	label: String
) -> void:
	if lamp == null:
		push_warning(
			"[BRUNO ENV] ",
			label,
			" non assegnato."
		)
		return

	if not lamp.has_method("set_broken"):
		push_warning(
			"[BRUNO ENV] ",
			label,
			" non espone set_broken(). Nodo: ",
			lamp.get_path()
		)
		return

	lamp.call("set_broken")

	if debug_logs:
		print(
			"[BRUNO ENV] ",
			label,
			" -> BROKEN | ",
			lamp.get_path()
		)


# ============================================================
# LAB DOOR
# ============================================================

func _force_lab_door_open() -> void:
	if lab_exit_door == null:
		push_warning(
			"[BRUNO ENV] Lab Exit Door non assegnata."
		)
		return

	if not lab_exit_door.has_method("set_forced_open"):
		push_warning(
			"[BRUNO ENV] Lab Exit Door non espone set_forced_open(). Nodo: ",
			lab_exit_door.get_path()
		)
		return

	lab_exit_door.call(
		"set_forced_open",
		true
	)

	if debug_logs:
		print(
			"[BRUNO ENV] Porta Lab -> FORCED OPEN | ",
			lab_exit_door.get_path()
		)


func _release_lab_door() -> void:
	if lab_exit_door == null:
		return

	if not lab_exit_door.has_method("set_forced_open"):
		return

	lab_exit_door.call(
		"set_forced_open",
		false
	)

	if debug_logs:
		print(
			"[BRUNO ENV] Porta Lab -> NORMAL | ",
			lab_exit_door.get_path()
		)


# ============================================================
# HELPERS
# ============================================================

func _has_property(
	object: Object,
	property_name: StringName
) -> bool:
	for property_info: Dictionary in object.get_property_list():
		if StringName(
			String(property_info.get("name", ""))
		) == property_name:
			return true

	return false
