extends SceneTree

class EncounterFixture extends Node:
	var player: CharacterBody3D
	var event: RefCounted

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if DisplayServer.get_name() != "headless":
		root.size = Vector2i(1280, 720)
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(40, 0.2, 40)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	world.add_child(floor_body)
	floor_body.position.y = -0.1
	var player: CharacterBody3D = load("res://scenes/player/player.tscn").instantiate()
	world.add_child(player)
	player.global_position = Vector3(0, 0.9, 1.0)
	player.set_physics_process(false)
	var weapon: Node = player.get_node("Head/Camera3D/WeaponHolder")
	for clip in weapon.arms_animation_player.get_animation_list():
		if "hold" in clip and "attack" in clip: print("RACKET_ATTACK_CLIP ", clip)
	root.get_node("InventoryManager").add_item(&"bruno_racket")
	assert(not weapon.equip_racket(), "Racket unlocked before combat")
	var presentation: Node3D = load("res://scripts/debug/angelastri_mouth_preview.gd").new()
	presentation.map_presentation = true
	presentation.automatic_preview = false
	world.add_child(presentation)
	await presentation.presentation_loaded
	var fixture := EncounterFixture.new()
	fixture.player = player
	fixture.event = load("res://scripts/systems/angelastri_event_state.gd").new()
	world.add_child(fixture)
	var combat: CharacterBody3D = load("res://scripts/enemies/angelastri_combat.gd").new()
	world.add_child(combat)
	combat.configure(fixture, presentation)
	combat.set_physics_process(false)
	await physics_frame
	var bump := StaticBody3D.new()
	var bump_shape := CollisionShape3D.new()
	var bump_box := BoxShape3D.new()
	bump_box.size = Vector3(8, 0.2, 1)
	bump_shape.shape = bump_box
	bump.add_child(bump_shape)
	world.add_child(bump)
	bump.position = Vector3(0, 0.1, 2)
	player.global_position = Vector3(0, 0.9, 10)
	for i in range(90):
		await physics_frame
		combat._physics_process(1.0 / 60.0)
	assert(combat.global_position.z > 3.0, "Monster stuck on 20 cm terrain step")
	bump.queue_free()
	combat.global_position = Vector3.ZERO
	combat.velocity = Vector3.ZERO
	combat.state = "chase"
	player.global_position = Vector3(0, 0.9, 1)
	await physics_frame
	var initial_health: int = combat.health
	for i in range(20):
		combat.take_bullet_hit(100, combat.global_position)
	assert(combat.health == initial_health, "Bullets damaged Angelastri")
	assert(combat.state == "dodge", "Bullet did not trigger dodge")
	var dodge_start: Vector3 = combat.global_position
	combat._physics_process(0.1)
	assert(Vector2(combat.global_position.x - dodge_start.x, combat.global_position.z - dodge_start.z).length() < 0.01, "Dodge slid across ground")
	player.global_position = Vector3(0, 0.9, 10)
	combat.state = "chase"
	var run_start: Vector3 = combat.global_position
	combat._physics_process(0.1)
	assert(animation_name(combat) == &"mie/running", "Chase did not use running")
	assert(combat.global_position.distance_to(run_start) > 0.01, "Chase did not translate body")
	combat.global_position = Vector3.ZERO
	player.global_position = Vector3(0, 0.9, 1)
	assert(weapon.equip_racket(), "Owned racket did not equip after combat")
	assert(weapon.racket_model.visible and weapon.racket_used)
	if DisplayServer.get_name() != "headless":
		player.get_node("Head/Camera3D").make_current()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/angelastri_combat_hud.png")
	weapon.stow_racket()
	assert(not weapon.racket_model.visible)
	weapon.select_weapon_slot(5)
	assert(weapon.equipped_weapon == weapon.WEAPON_RACKET)
	var saved: Dictionary = weapon.get_save_state()
	weapon.apply_save_state(saved)
	assert(weapon.equipped_weapon == weapon.WEAPON_RACKET, "Racket save/restore lost equipment")
	combat.state = "chase"
	combat.take_damage(5)
	assert(combat.health == initial_health - 5 and combat.bar.value == combat.health)
	combat._process(0.0)
	assert(float(combat.invulnerable_material.get_shader_parameter("active")) == 1.0, "Invulnerability outline inactive")
	player.get_node("Head/Camera3D").look_at(combat.global_position + Vector3.UP * 1.3)
	await physics_frame
	var before_racket: int = combat.health
	weapon.perform_melee_hit()
	assert(combat.health == before_racket, "Hit reaction did not protect against repeated melee")
	combat._physics_process(combat.duration + 0.01)
	weapon.perform_melee_hit()
	assert(combat.health == before_racket - weapon.racket_damage, "Racket ray did not apply melee damage to real collider")
	assert(world.find_child("MeleeBloodSpray", true, false) != null, "Accepted hit did not spawn blood")
	if DisplayServer.get_name() != "headless":
		player.global_position = Vector3(0, 0.9, 3.5)
		player.get_node("Head/Camera3D").look_at(combat.global_position + Vector3.UP * 1.2)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/angelastri_invulnerable_feedback.png")
		player.global_position = Vector3(0, 0.9, 1)
	player.set_physics_process(true)
	var ui: Node = root.get_node("GameplayUI")
	assert(ui.open_inventory(), "Inventory did not open during combat")
	assert(ui._use_weapon_button.visible, "Racket use/stow button missing after fight unlock")
	ui._toggle_racket()
	assert(weapon.equipped_weapon == weapon.WEAPON_UNARMED and not paused, "Inventory stow did not return to gameplay")
	assert(ui.open_inventory())
	ui._toggle_racket()
	assert(weapon.equipped_weapon == weapon.WEAPON_RACKET and not paused, "Inventory did not equip racket")
	player.set_physics_process(false)
	combat.state = "chase"
	var swing_health: int = combat.health
	await weapon.attack_racket()
	assert(combat.health == swing_health - weapon.racket_damage, "Full racket animation missed its timed impact")
	# Both strike clips must damage at the impact, once per swing.
	for i in range(2):
		combat._begin_attack(false)
		var before: int = player.health
		combat._physics_process(combat.duration * 0.46)
		assert(player.health < before, "Melee attack did not hurt player")
		var wave: Node3D = world.get_node_or_null("ZombieImpactWave")
		assert(wave != null and absf(wave.reach - 1.95) < 0.01, "Impact wave did not delimit actual attack reach")
		var after: int = player.health
		combat._physics_process(0.01)
		assert(player.health == after, "Melee hit repeated per frame")
	# Bite holds during the clip, applies once and restores the previous input state.
	player.set_physics_process(true)
	combat._begin_attack(true)
	var wounded_bite_duration: float = combat.duration
	assert(wounded_bite_duration < animation_duration(combat, &"mie/bite_neck"), "Wounds did not accelerate bite")
	combat._physics_process(combat.duration * 0.3)
	assert(not player.is_physics_processing() and not combat.grab_state.is_empty(), "Bite failed to immobilize player")
	combat._physics_process(combat.duration * 0.3)
	combat._physics_process(combat.duration)
	assert(player.is_physics_processing() and player.is_processing_unhandled_input(), "Bite did not release player")
	assert(combat.bite_cooldown >= 5.0, "Successful bite lacks post-release cooldown")
	player.set_physics_process(false)
	combat._begin_attack(true)
	combat._physics_process(combat.duration * 0.3)
	combat.reaction_cooldown = 0.0
	var held_health: int = combat.health
	combat.take_damage(1)
	assert(combat.health == held_health and not combat.grab_state.is_empty(), "Bite was interrupted by melee despite animation immunity")
	combat.release_player()
	combat.state = "chase"
	combat.take_damage(100)
	assert(combat.health == 0 and combat.state == "dead" and fixture.event.stage == "defeated")
	assert(not combat.hud.visible and combat.collision_layer == 0)
	assert(is_instance_valid(presentation.model), "Death deleted actor")
	print("ANGELASTRI_COMBAT_TEST passed: bullet immunity/dodge, two strikes, bite/release/interruption, death, racket gate/slot/save")
	world.queue_free()
	await process_frame
	await process_frame
	quit()

func animation_name(combat: Node) -> StringName:
	return combat.animation.assigned_animation

func animation_duration(combat: Node, clip: StringName) -> float:
	return combat.animation.get_animation(clip).length
