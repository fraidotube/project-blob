extends SceneTree

class PreviewFixture extends Node:
	var presentation: Node3D
	func clear_preview() -> void:
		presentation.free()
		presentation = null

class PresentationFixture extends Node3D:
	var presentation_stage := "rest"

class PlayerFixture extends CharacterBody3D:
	var is_dead := false

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var encounter = load("res://scripts/tests/angelastri_return_fixture.gd").new()
	var preview := PreviewFixture.new()
	var actor := PresentationFixture.new()
	var player := PlayerFixture.new()
	preview.presentation = actor
	encounter.preview = preview
	encounter.player = player
	encounter.configured = true
	encounter.cinematic = true
	encounter.returning = true
	encounter._process(1.0 / 60.0)
	assert(encounter.return_requests == 0, "Completed return restarted and deleted the actor")
	assert(is_instance_valid(preview.presentation), "Actor deleted after completed return")
	assert(encounter.event.stage == "waiting")
	actor.free()
	player.free()
	preview.free()
	encounter.free()
	print("ANGELASTRI_RETURN_FRAME_TEST passed: actor retained after cinematic handoff")
	quit()
