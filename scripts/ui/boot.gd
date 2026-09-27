extends Control


const NEXT_SCENE := "res://scenes/maps/map_test.tscn"


@export var fraidosoft_hold_time: float = 1.5
@export var project_blob_hold_time: float = 2.0

@export var fade_in_time: float = 0.8
@export var fade_out_time: float = 0.8


@onready var black_background: ColorRect = $BlackBackground
@onready var fraidosoft_logo: TextureRect = $FraidoSoftLogo
@onready var project_blob_logo: TextureRect = $ProjectBlobLogo


func _ready() -> void:
	print("BOOT: avvio")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	fraidosoft_logo.modulate.a = 0.0
	project_blob_logo.modulate.a = 0.0

	await get_tree().process_frame

	print("BOOT: FraidoSoft")

	await _show_logo(
		fraidosoft_logo,
		fraidosoft_hold_time
	)

	print("BOOT: Project Blob")

	await _show_logo(
		project_blob_logo,
		project_blob_hold_time
	)

	print("BOOT: caricamento map_test")

	_finish_boot()


func _show_logo(
	logo: TextureRect,
	hold_time: float
) -> void:
	var fade_in := create_tween()

	fade_in.tween_property(
		logo,
		"modulate:a",
		1.0,
		fade_in_time
	)

	await fade_in.finished

	await get_tree().create_timer(
		hold_time
	).timeout

	var fade_out := create_tween()

	fade_out.tween_property(
		logo,
		"modulate:a",
		0.0,
		fade_out_time
	)

	await fade_out.finished


func _finish_boot() -> void:
	if not ResourceLoader.exists(NEXT_SCENE):
		push_error(
			"BOOT: scena non trovata: "
			+ NEXT_SCENE
		)
		return

	var error := get_tree().change_scene_to_file(
		NEXT_SCENE
	)

	if error != OK:
		push_error(
			"BOOT: errore cambio scena: "
			+ str(error)
		)
	else:
		print(
			"BOOT: cambio scena richiesto correttamente"
		)
