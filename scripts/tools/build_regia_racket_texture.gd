extends SceneTree

# Native glyph compositing; preserves the original texture and font files.
const GLYPHS := preload("res://scripts/ui/regia_alien_glyphs.gd")
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1024, 1024)
	viewport.disable_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var background := TextureRect.new()
	background.texture = load("res://assets/models/enemies/bruno_buozzi/tennis-racket-wilson-blade/textures/Rychka_Base_color.png")
	background.size = Vector2(1024, 1024)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	viewport.add_child(background)
	var font := GLYPHS.font()
	var symbols: Array = load("res://scripts/systems/regia_network_state.gd").PASSWORD
	for i in 4:
		var label := Label.new()
		label.text = GLYPHS.symbol(symbols[i])
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 82)
		label.add_theme_color_override("font_color", Color("20192c"))
		label.position = Vector2(235 + i * 139, 468)
		viewport.add_child(label)
	await create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	var result := image.save_png("res://assets/textures/regia_racket_handle.png")
	if result == OK:
		result = ResourceSaver.save(ImageTexture.create_from_image(image), "res://assets/textures/regia_racket_handle.res", ResourceSaver.FLAG_COMPRESS)
	print("REGIA_RACKET_TEXTURE result=", result)
	quit(0 if result == OK else 1)
