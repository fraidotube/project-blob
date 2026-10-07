extends TextureRect
class_name HudFaceController


# ============================================================
# PROJECT BLOB - HUD FACE CONTROLLER
# ============================================================
#
# Gestisce:
# - 4 stati salute
# - 20 frame per stato
# - idle casuale controllato
# - reaction sequences
# - priorità
# - interruzioni
# - cambio stato salute anche durante una reazione
#
# Tutto il resto del gioco comunica soltanto eventi semantici:
#
# get_tree().call_group(
#     "player_face",
#     "react",
#     "pickup_major"
# )
#
# ============================================================


# ------------------------------------------------------------
# PRIORITA'
# ------------------------------------------------------------

const PRIORITY_IDLE := 0
const PRIORITY_FOCUS := 30
const PRIORITY_PICKUP_SMALL := 50
const PRIORITY_PICKUP_MAJOR := 60
const PRIORITY_HIT := 80
const PRIORITY_CRITICAL := 100


# ------------------------------------------------------------
# ASSET
# ------------------------------------------------------------

@export_group("Face Assets")

@export_dir var face_asset_directory := (
	"res://assets/ui/face"
)


# ------------------------------------------------------------
# SOGLIE SALUTE
# ------------------------------------------------------------

@export_group("Face Health")

@export_range(
	0.0,
	100.0,
	1.0
) var critical_threshold_percent := 25.0

@export_range(
	0.0,
	100.0,
	1.0
) var low_threshold_percent := 50.0

@export_range(
	0.0,
	100.0,
	1.0
) var medium_threshold_percent := 75.0


# ------------------------------------------------------------
# IDLE
# ------------------------------------------------------------

@export_group("Face Idle")

@export_range(
	0.2,
	20.0,
	0.1
) var idle_pause_min := 1.8

@export_range(
	0.2,
	20.0,
	0.1
) var idle_pause_max := 4.5

@export_range(
	0.05,
	2.0,
	0.05
) var idle_glance_duration_min := 0.22

@export_range(
	0.05,
	2.0,
	0.05
) var idle_glance_duration_max := 0.42

@export_range(
	0.05,
	3.0,
	0.05
) var idle_expression_duration_min := 0.30

@export_range(
	0.05,
	3.0,
	0.05
) var idle_expression_duration_max := 0.65


# ------------------------------------------------------------
# REAZIONI
# ------------------------------------------------------------

@export_group("Face Reactions")

@export_range(
	0.05,
	2.0,
	0.05
) var hit_direction_duration := 0.18

@export_range(
	0.05,
	3.0,
	0.05
) var hit_followup_duration := 0.38

@export_range(
	0.05,
	3.0,
	0.05
) var pickup_small_duration := 0.55

@export_range(
	0.05,
	3.0,
	0.05
) var pickup_major_duration := 0.80

@export_range(
	0.05,
	3.0,
	0.05
) var alert_duration := 0.55

@export_range(
	0.05,
	3.0,
	0.05
) var focus_duration := 0.65

@export_range(
	0.05,
	3.0,
	0.05
) var grunt_duration := 0.45

@export_range(
	0.05,
	3.0,
	0.05
) var determined_duration := 0.70


# ------------------------------------------------------------
# STATO
# ------------------------------------------------------------

var _current_health := 100
var _max_health := 100

var _current_frame := 1

var _textures: Dictionary = {}
var _reactions: Dictionary = {}

var _sequence: Array = []
var _sequence_index := -1
var _sequence_time_left := 0.0

var _active_priority := -1

var _idle_wait_left := 0.0


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	add_to_group(
		"player_face"
	)

	_cache_all_textures()
	_build_reaction_definitions()

	_show_frame(
		1
	)

	_schedule_next_idle()


# ============================================================
# PROCESS
# ============================================================

func _process(
	delta: float
) -> void:
	if not _sequence.is_empty():
		_sequence_time_left -= delta

		if _sequence_time_left <= 0.0:
			_advance_sequence()

		return

	_idle_wait_left -= delta

	if _idle_wait_left <= 0.0:
		_start_random_idle()


# ============================================================
# SALUTE
# ============================================================

func set_health(
	current_health: int,
	max_health: int
) -> void:
	_current_health = maxi(
		current_health,
		0
	)

	_max_health = maxi(
		max_health,
		1
	)

	# Se cambia fascia salute mentre è visualizzata
	# una reazione, manteniamo la stessa espressione
	# ma usando immediatamente il nuovo set grafico.
	_show_frame(
		_current_frame
	)


func _get_health_state() -> int:
	var health_percent := (
		float(_current_health)
		/ float(_max_health)
		* 100.0
	)

	var critical_threshold := clampf(
		critical_threshold_percent,
		0.0,
		100.0
	)

	var low_threshold := clampf(
		maxf(
			low_threshold_percent,
			critical_threshold
		),
		0.0,
		100.0
	)

	var medium_threshold := clampf(
		maxf(
			medium_threshold_percent,
			low_threshold
		),
		0.0,
		100.0
	)

	if health_percent <= critical_threshold:
		return 4

	if health_percent <= low_threshold:
		return 3

	if health_percent <= medium_threshold:
		return 2

	return 1


# ============================================================
# API PUBBLICA
# ============================================================

func react(
	reaction_name: String,
	severity: float = 0.5
) -> bool:
	var requested_reaction := reaction_name

	# Per adesso la direzione del danno non arriva
	# dal gameplay.
	#
	# hit_random sceglie quindi casualmente SX/DX.
	if requested_reaction == "hit_random":
		if randi_range(0, 1) == 0:
			requested_reaction = (
				"hit_left"
			)

		else:
			requested_reaction = (
				"hit_right"
			)

	if not _reactions.has(
		requested_reaction
	):
		push_warning(
			"HUD Face: reazione sconosciuta: "
			+ requested_reaction
		)

		return false

	var definition: Dictionary = (
		_reactions[
			requested_reaction
		]
	)

	var priority := int(
		definition.get(
			"priority",
			PRIORITY_IDLE
		)
	)

	# Una reazione con priorità inferiore non può
	# interrompere quella attualmente in corso.
	if (
		not _sequence.is_empty()
		and priority < _active_priority
	):
		return false

	var sequence := _choose_reaction_variant(
		requested_reaction,
		definition,
		severity
	)

	if sequence.is_empty():
		return false

	_start_sequence(
		sequence,
		priority
	)

	return true


# ============================================================
# DEFINIZIONI REAZIONI
# ============================================================

func _build_reaction_definitions() -> void:
	_reactions.clear()

	_reactions["hit_left"] = {
		"priority": PRIORITY_HIT,
		"variants": [
			[
				_step(
					9,
					hit_direction_duration
				),
				_step(
					15,
					hit_followup_duration
				)
			],
			[
				_step(
					9,
					hit_direction_duration
				),
				_step(
					16,
					hit_followup_duration
				)
			],
			[
				_step(
					9,
					hit_direction_duration
				),
				_step(
					11,
					hit_followup_duration
				)
			]
		]
	}

	_reactions["hit_right"] = {
		"priority": PRIORITY_HIT,
		"variants": [
			[
				_step(
					10,
					hit_direction_duration
				),
				_step(
					15,
					hit_followup_duration
				)
			],
			[
				_step(
					10,
					hit_direction_duration
				),
				_step(
					16,
					hit_followup_duration
				)
			],
			[
				_step(
					10,
					hit_direction_duration
				),
				_step(
					11,
					hit_followup_duration
				)
			]
		]
	}

	_reactions["hit_front"] = {
		"priority": PRIORITY_HIT,
		"variants": [
			[
				_step(
					14,
					hit_direction_duration
				),
				_step(
					15,
					hit_followup_duration
				)
			],
			[
				_step(
					14,
					hit_direction_duration
				),
				_step(
					16,
					hit_followup_duration
				)
			],
			[
				_step(
					14,
					hit_direction_duration
				),
				_step(
					11,
					hit_followup_duration
				)
			]
		]
	}

	_reactions["pain"] = {
		"priority": PRIORITY_HIT,
		"variants": [
			[
				_step(
					15,
					hit_followup_duration
				)
			]
		]
	}

	_reactions["angry_after_hit"] = {
		"priority": PRIORITY_HIT,
		"variants": [
			[
				_step(
					16,
					hit_followup_duration
				)
			]
		]
	}

	_reactions["pickup_small"] = {
		"priority": PRIORITY_PICKUP_SMALL,
		"variants": [
			[
				_step(
					8,
					pickup_small_duration
				)
			]
		]
	}

	_reactions["pickup_major"] = {
		"priority": PRIORITY_PICKUP_MAJOR,
		"variants": [
			[
				_step(
					13,
					pickup_major_duration
				)
			]
		]
	}

	_reactions["alert"] = {
		"priority": PRIORITY_FOCUS,
		"variants": [
			[
				_step(
					17,
					alert_duration
				)
			]
		]
	}

	_reactions["focus"] = {
		"priority": PRIORITY_FOCUS,
		"variants": [
			[
				_step(
					18,
					focus_duration
				)
			]
		]
	}

	_reactions["grunt"] = {
		"priority": PRIORITY_FOCUS,
		"variants": [
			[
				_step(
					19,
					grunt_duration
				)
			]
		]
	}

	_reactions["determined"] = {
		"priority": PRIORITY_FOCUS,
		"variants": [
			[
				_step(
					20,
					determined_duration
				)
			]
		]
	}


func _choose_reaction_variant(
	reaction_name: String,
	definition: Dictionary,
	severity: float
) -> Array:
	var variants: Array = (
		definition.get(
			"variants",
			[]
		)
	)

	if variants.is_empty():
		return []

	var safe_severity := clampf(
		severity,
		0.0,
		1.0
	)

	# Per i colpi forti privilegiamo il frame 15.
	if (
		reaction_name == "hit_left"
		or reaction_name == "hit_right"
		or reaction_name == "hit_front"
	):
		if (
			safe_severity >= 0.70
			and randf() < 0.70
		):
			return (
				variants[0]
				as Array
			).duplicate(true)

		# Per colpi leggeri riduciamo leggermente
		# la probabilità del dolore forte.
		if safe_severity <= 0.30:
			var light_index := randi_range(
				1,
				variants.size() - 1
			)

			return (
				variants[
					light_index
				]
				as Array
			).duplicate(true)

	var selected_index := randi_range(
		0,
		variants.size() - 1
	)

	return (
		variants[
			selected_index
		]
		as Array
	).duplicate(true)


# ============================================================
# IDLE
# ============================================================

func _schedule_next_idle() -> void:
	var minimum := minf(
		idle_pause_min,
		idle_pause_max
	)

	var maximum := maxf(
		idle_pause_min,
		idle_pause_max
	)

	_idle_wait_left = randf_range(
		minimum,
		maximum
	)


func _start_random_idle() -> void:
	if not _sequence.is_empty():
		return

	var roll := randi_range(
		1,
		100
	)

	var sequence: Array = []

	if roll <= 25:
		sequence = _build_idle_glance(
			2
		)

	elif roll <= 50:
		sequence = _build_idle_glance(
			3
		)

	elif roll <= 60:
		sequence = [
			_step(
				4,
				_random_idle_glance_duration()
			)
		]

	elif roll <= 70:
		sequence = [
			_step(
				5,
				_random_idle_glance_duration()
			)
		]

	elif roll <= 80:
		sequence = [
			_step(
				6,
				_random_idle_expression_duration()
			)
		]

	elif roll <= 87:
		sequence = [
			_step(
				11,
				_random_idle_expression_duration()
			)
		]

	elif roll <= 93:
		sequence = [
			_step(
				12,
				_random_idle_expression_duration()
			)
		]

	elif roll <= 98:
		sequence = [
			_step(
				18,
				_random_idle_expression_duration()
			)
		]

	else:
		sequence = [
			_step(
				20,
				_random_idle_expression_duration()
			)
		]

	_start_sequence(
		sequence,
		PRIORITY_IDLE
	)


func _build_idle_glance(
	frame_number: int
) -> Array:
	var sequence: Array = [
		_step(
			frame_number,
			_random_idle_glance_duration()
		)
	]

	# Alcuni sguardi vengono mantenuti un po' più a lungo.
	# È intenzionale: evita l'effetto GIF regolare.
	if randf() < 0.32:
		sequence.append(
			_step(
				frame_number,
				_random_idle_glance_duration()
			)
		)

	return sequence


func _random_idle_glance_duration() -> float:
	var minimum := minf(
		idle_glance_duration_min,
		idle_glance_duration_max
	)

	var maximum := maxf(
		idle_glance_duration_min,
		idle_glance_duration_max
	)

	return randf_range(
		minimum,
		maximum
	)


func _random_idle_expression_duration() -> float:
	var minimum := minf(
		idle_expression_duration_min,
		idle_expression_duration_max
	)

	var maximum := maxf(
		idle_expression_duration_min,
		idle_expression_duration_max
	)

	return randf_range(
		minimum,
		maximum
	)


# ============================================================
# MACCHINA SEQUENZE
# ============================================================

func _start_sequence(
	sequence: Array,
	priority: int
) -> void:
	if sequence.is_empty():
		return

	_sequence = sequence.duplicate(
		true
	)

	_sequence_index = 0
	_active_priority = priority

	_show_current_sequence_step()


func _show_current_sequence_step() -> void:
	if _sequence.is_empty():
		return

	if (
		_sequence_index < 0
		or _sequence_index
			>= _sequence.size()
	):
		_finish_sequence()
		return

	var step: Dictionary = (
		_sequence[
			_sequence_index
		]
	)

	var frame_number := int(
		step.get(
			"frame",
			1
		)
	)

	var duration := float(
		step.get(
			"duration",
			0.25
		)
	)

	_show_frame(
		frame_number
	)

	_sequence_time_left = maxf(
		duration,
		0.01
	)


func _advance_sequence() -> void:
	_sequence_index += 1

	if _sequence_index >= _sequence.size():
		_finish_sequence()
		return

	_show_current_sequence_step()


func _finish_sequence() -> void:
	_sequence.clear()

	_sequence_index = -1
	_sequence_time_left = 0.0

	_active_priority = -1

	_show_frame(
		1
	)

	_schedule_next_idle()


# ============================================================
# FRAME / TEXTURE
# ============================================================

func _show_frame(
	frame_number: int
) -> void:
	var safe_frame := clampi(
		frame_number,
		1,
		20
	)

	_current_frame = safe_frame

	var health_state := (
		_get_health_state()
	)

	var face_texture := _get_texture(
		health_state,
		safe_frame
	)

	if face_texture == null:
		return

	texture = face_texture


func _cache_all_textures() -> void:
	_textures.clear()

	for state: int in range(
		1,
		5
	):
		for frame_number: int in range(
			1,
			21
		):
			var path := (
				"%s/stato%d_%d.png"
				% [
					face_asset_directory,
					state,
					frame_number
				]
			)

			var loaded_texture := (
				load(path)
				as Texture2D
			)

			if loaded_texture == null:
				push_error(
					"HUD Face: texture non trovata: "
					+ path
				)

				continue

			_textures[
				_texture_key(
					state,
					frame_number
				)
			] = loaded_texture


func _get_texture(
	state: int,
	frame_number: int
) -> Texture2D:
	var key := _texture_key(
		state,
		frame_number
	)

	if not _textures.has(
		key
	):
		return null

	return (
		_textures[
			key
		]
		as Texture2D
	)


func _texture_key(
	state: int,
	frame_number: int
) -> String:
	return (
		"%d:%d"
		% [
			state,
			frame_number
		]
	)


func _step(
	frame_number: int,
	duration: float
) -> Dictionary:
	return {
		"frame": frame_number,
		"duration": duration
	}
