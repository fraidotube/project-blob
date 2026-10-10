extends RefCounted

# Shared palette and buttons from the main/pause menus; no bottom HUD artwork.
const MENU_THEME := preload("res://scenes/ui/project_blob_menu_theme.tres")
const INK := Color("0d0a15")
const PAPER := Color("e5d8ee")
const BLUE := Color("261333")
const GOLD := Color("ce8cf1")
# Kept as native source so the generated icon also works in exported builds.
const KEY_SVG := """<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160" viewBox="0 0 160 160">
<path d="M91 72 L137 118 L137 137 L118 137 L118 125 L106 125 L106 113 L94 113 L78 97" fill="#c68e29" stroke="#26343b" stroke-width="7" stroke-linejoin="round"/>
<circle cx="58" cy="58" r="35" fill="#e9c268" stroke="#26343b" stroke-width="7"/>
<circle cx="58" cy="58" r="15" fill="#26343b"/>
<path d="M34 48 A26 26 0 0 1 72 34 M94 88 L124 118" fill="none" stroke="#fff0b2" stroke-width="6" stroke-linecap="round"/>
</svg>"""

static func font() -> SystemFont:
	var result := SystemFont.new()
	result.font_names = PackedStringArray(["Bebas Neue", "Arial Narrow"])
	result.font_weight = 600
	return result

static func key_icon() -> Texture2D:
	var image := Image.new()
	if image.load_svg_from_string(KEY_SVG) == OK:
		return ImageTexture.create_from_image(image)
	return null

static func plate(background: Color, border: Color, margin: float = 14.0) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = background
	result.border_color = border
	result.set_border_width_all(2)
	result.corner_radius_top_right = 10
	result.corner_radius_bottom_left = 10
	result.content_margin_left = margin
	result.content_margin_right = margin
	result.content_margin_top = margin
	result.content_margin_bottom = margin
	return result

static func detail_panel() -> StyleBoxFlat:
	var result := plate(Color("130d20"), Color("5d2e78"), 22)
	result.shadow_color = Color(0.35, 0.04, 0.50, 0.20)
	result.shadow_size = 8
	return result

static func button(button: Button) -> void:
	button.theme = MENU_THEME
	button.add_theme_font_override("font", font())
	button.add_theme_font_size_override("font_size", 24)
