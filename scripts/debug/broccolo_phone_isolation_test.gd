extends Node3D
## Riproduce la clip originale sul PackedScene Broccolo senza riscrivere
## trasformazioni, pose del rig o risorse Animation.

const PHONE_ANSWER: StringName = &"mie/phone_answer_talk"
const FRAME_STEP := 1.0 / 30.0

@onready var animation_player: AnimationPlayer = $Broccolo/Broccolo/AnimationPlayer
@onready var phone_visual: Node3D = $Broccolo/Broccolo/Armature/GeneralSkeleton/BoneAttachment3D/Smartphone
@onready var front_camera: Camera3D = $FrontCamera
@onready var back_camera: Camera3D = $BackCamera

var back_view := false

func _ready() -> void:
	# PhonePresentation hides the prop on instantiation; this isolated scene
	# reveals the existing node and leaves its local transform untouched.
	phone_visual.show()
	front_camera.look_at(Vector3(0.0, 1.0, 0.0))
	back_camera.look_at(Vector3(0.0, 1.0, 0.0))
	animation_player.play(PHONE_ANSWER, 0.0)
	animation_player.advance(0.0)
	print("BROCCOLO_PHONE_ISOLATION_READY clip=", PHONE_ANSWER,
		" phone_local_transform=", phone_visual.transform,
		" mesh_local_transform=", phone_visual.get_node("Object_2").transform)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_SPACE:
			if animation_player.is_playing():
				animation_player.pause()
			else:
				animation_player.play()
		KEY_R:
			animation_player.play(PHONE_ANSWER, 0.0)
			animation_player.advance(0.0)
		KEY_F:
			back_view = not back_view
			if back_view:
				back_camera.make_current()
			else:
				front_camera.make_current()
		KEY_LEFT:
			_seek(-FRAME_STEP)
		KEY_RIGHT:
			_seek(FRAME_STEP)

func _seek(offset: float) -> void:
	var clip: Animation = animation_player.get_animation(PHONE_ANSWER)
	var time := clampf(animation_player.current_animation_position + offset, 0.0, clip.length)
	animation_player.seek(time, true)
	animation_player.advance(0.0)
