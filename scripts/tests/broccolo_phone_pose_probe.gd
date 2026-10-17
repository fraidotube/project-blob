extends SceneTree
## Confronta la posa del telefono nella scena diretta e nel presenter runtime.

var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func run() -> void:
	var direct := load("res://scenes/enemies/broccolo.tscn").instantiate() as CharacterBody3D
	root.add_child(direct)
	var direct_animation: AnimationPlayer = direct.get_node("Broccolo/AnimationPlayer")
	var direct_skeleton: Skeleton3D = direct.get_node("Broccolo/Armature/GeneralSkeleton")
	var direct_phone: Node3D = direct.get_node("Broccolo/Armature/GeneralSkeleton/BoneAttachment3D/Smartphone")
	direct_phone.show()
	var presenter := load("res://scenes/cinematics/broccolo_map_presentation.tscn").instantiate() as Node3D
	root.add_child(presenter)
	while not presenter.ready_for_preview:
		await process_frame
	var runtime_actor: CharacterBody3D = presenter.actor
	var runtime_animation: AnimationPlayer = presenter.animation
	var runtime_skeleton: Skeleton3D = presenter.skeleton
	var runtime_phone: Node3D = presenter.phone.phone_visual
	runtime_phone.show()
	for sample_time in [1.46, 3.3, 10.0, 23.0, 26.5]:
		direct_animation.play(&"mie/phone_answer_talk", 0.0)
		direct_animation.pause()
		direct_animation.seek(sample_time, true)
		runtime_animation.play(&"mie/phone_answer_talk", 0.0)
		runtime_animation.pause()
		runtime_animation.seek(sample_time, true)
		direct_skeleton.force_update_all_bone_transforms()
		runtime_skeleton.force_update_all_bone_transforms()
		await process_frame
		var direct_relative: Transform3D = direct.global_transform.affine_inverse() * direct_phone.get_node("Object_2").global_transform
		var runtime_relative: Transform3D = runtime_actor.global_transform.affine_inverse() * runtime_phone.get_node("Object_2").global_transform
		var direct_hand_relative: Transform3D = direct.get_node("Broccolo/Armature/GeneralSkeleton/BoneAttachment3D").global_transform.affine_inverse() * direct_phone.get_node("Object_2").global_transform
		var runtime_hand_relative: Transform3D = runtime_actor.get_node("Broccolo/Armature/GeneralSkeleton/BoneAttachment3D").global_transform.affine_inverse() * runtime_phone.get_node("Object_2").global_transform
		var difference := direct_relative.origin.distance_to(runtime_relative.origin)
		var direct_scale := direct_relative.basis.get_scale()
		var runtime_scale := runtime_relative.basis.get_scale()
		var global_delta: float = direct_phone.get_node("Object_2").global_position.distance_to(runtime_phone.get_node("Object_2").global_position)
		var hand_local_delta: float = direct_hand_relative.origin.distance_to(runtime_hand_relative.origin)
		var direct_hand_scale: Vector3 = direct_hand_relative.basis.get_scale()
		var runtime_hand_scale: Vector3 = runtime_hand_relative.basis.get_scale()
		check(global_delta < 0.001, "La posa globale diretta/runtime coincide a %.2fs" % sample_time)
		check(hand_local_delta < 0.001, "Telefono invariato rispetto alla mano a %.2fs" % sample_time)
		check((direct_hand_scale - runtime_hand_scale).length() < 0.001, "Scala rispetto alla mano invariata a %.2fs" % sample_time)
		print("BROCCOLO_PHONE_POSE t=", sample_time, " global_delta=", global_delta,
			" hand_local_delta=", hand_local_delta, " scale_direct=", direct_hand_scale,
			" scale_runtime=", runtime_hand_scale, " actor_root_motion=", runtime_actor.position)
	direct.queue_free()
	presenter.queue_free()
	await process_frame
	print("BROCCOLO_PHONE_POSE_PROBE failures=", failures)
	quit(failures)
