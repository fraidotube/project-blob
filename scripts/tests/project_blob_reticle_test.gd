extends SceneTree

class EnemyFixture extends StaticBody3D:
	func take_damage(_amount: int) -> void: pass

class InteractionFixture extends StaticBody3D:
	func get_interaction_name() -> String: return "Oggetto prova"
	func get_interaction_action() -> String: return "Prendi"
	func interact(_player: Node) -> void: pass

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	current_scene = world
	var player: CharacterBody3D = load("res://scenes/player/player.tscn").instantiate()
	world.add_child(player)
	player.position = Vector3(0, 0.9, 0)
	var hud: Node = load("res://scenes/ui/hud.tscn").instantiate()
	world.add_child(hud)
	var reticle: Control = hud.game_reticle
	assert(not hud.crosshair_image.visible, "Old crosshair still visible")
	var enemy := EnemyFixture.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1, 3, 1)
	shape.shape = box
	enemy.add_child(shape)
	world.add_child(enemy)
	enemy.position = Vector3(0, 1.5, -4)
	await physics_frame
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	reticle._process(0.3)
	assert(reticle.target_kind == "enemy" and reticle.radius > 15, "Enemy did not expand shared crosshair")
	assert(reticle.classify(enemy) == "enemy")
	enemy.queue_free()
	await physics_frame
	var item := InteractionFixture.new()
	item.collision_layer = 2
	var item_shape := CollisionShape3D.new()
	item_shape.shape = box
	item.add_child(item_shape)
	world.add_child(item)
	item.position = Vector3(0, 1.5, -1.5)
	await physics_frame
	await process_frame
	player.global_position = Vector3(0, 0.9, 0)
	player.global_rotation = Vector3.ZERO
	player.get_node("InteractionSystem")._update_focus()
	reticle._process(0.3)
	assert(reticle.target_kind == "interaction", "Legacy interaction did not expand shared crosshair")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	reticle._process(0.1)
	assert(not reticle.visible, "Crosshair visible during menu")
	print("PROJECT_BLOB_RETICLE_TEST passed: shared HUD, enemy targeting, legacy interaction, modal visibility")
	world.queue_free()
	await process_frame
	quit()
