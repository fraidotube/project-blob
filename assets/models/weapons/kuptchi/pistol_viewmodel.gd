extends Node3D

const RELOAD_SCENE := preload(
	"res://assets/models/weapons/kuptchi/pistol_reload.glb"
)

@onready var animation_player: AnimationPlayer = $pistol_fire/AnimationPlayer


func _ready() -> void:
	var reload_instance := RELOAD_SCENE.instantiate()

	var reload_animation_player := reload_instance.get_node(
		"AnimationPlayer"
	) as AnimationPlayer

	if reload_animation_player == null:
		push_error("AnimationPlayer non trovato in pistol_reload.glb")
		reload_instance.queue_free()
		return

	if not reload_animation_player.has_animation("Reload"):
		push_error("Animazione Reload non trovata in pistol_reload.glb")
		reload_instance.queue_free()
		return

	var reload_animation := reload_animation_player.get_animation(
		"Reload"
	).duplicate(true)

	var library := animation_player.get_animation_library("")

	if library == null:
		push_error("AnimationLibrary principale non trovata")
		reload_instance.queue_free()
		return

	if library.has_animation("Reload"):
		library.remove_animation("Reload")

	library.add_animation("Reload", reload_animation)

	reload_instance.queue_free()
