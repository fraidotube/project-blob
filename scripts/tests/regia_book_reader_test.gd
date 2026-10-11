extends SceneTree

var failures := 0
var reader: Control
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error("BOOK_READER: " + message)
func photo(name: String) -> void:
	await create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/book_reader_" + name + ".png")
func run() -> void:
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(1280, 800)
	root.content_scale_size = Vector2i(1280, 800)
	var layer := CanvasLayer.new()
	root.add_child(layer)
	reader = load("res://scripts/ui/regia_book_reader.gd").new()
	reader.kind = "book"
	reader.source_texture = load("res://assets/models/environment/connesi_building_test2_addon_1_Book_Base_Color.png")
	reader.size = Vector2(1440, 940)
	reader.scale = Vector2.ONE * 0.8
	reader.position = Vector2(64, 24)
	layer.add_child(reader)
	check(not reader.wifi_visible, "Initial book reveals WiFi")
	await photo("alien_first")
	await reader.turn_page(1)
	check(reader.page_index == 1 and not reader.wifi_visible, "First page transition failed")
	await reader.turn_page(1)
	check(reader.page_index == 2 and reader.wifi_visible and not reader.turning, "WiFi page not reached")
	await photo("alien_wifi")
	await reader.turn_page(-1)
	check(reader.page_index == 1 and not reader.wifi_visible, "Previous page failed")
	reader.queue_free()
	await process_frame
	reader = load("res://scripts/ui/regia_book_reader.gd").new()
	reader.kind = "notes"
	reader.source_texture = load("res://assets/models/environment/connesi_building_test2_addon_1_Image_0_14.jpg")
	reader.size = Vector2(1440, 940)
	reader.scale = Vector2.ONE * 0.8
	reader.position = Vector2(64, 24)
	layer.add_child(reader)
	var notes := ""
	for page: Control in reader.page_roots:
		for label: Label in page.find_children("*", "Label", true, false): notes += label.text
	check(notes.contains("narcisolo / ottavonano") and notes.contains("admin / admin2026"), "Handwritten credentials missing")
	check(reader.next_button.disabled and reader.previous_button.disabled, "Notebook offers empty pages")
	await photo("notes")
	print("REGIA_BOOK_READER_TEST failures=", failures)
	layer.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)
