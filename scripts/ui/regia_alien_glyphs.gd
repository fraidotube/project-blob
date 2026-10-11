extends RefCounted

# One alphabet across the physical keys, display and racket clue.
# Read the installed font privately; do not redistribute Windows fonts.
const SOURCE := "C:/Windows/Fonts/sylfaen.ttf"
const CODES := [0x0531, 0x0532, 0x0533, 0x0534, 0x0535, 0x0536, 0x0537, 0x0539, 0x053a, 0x053d, 0x053e, 0x0556]

static func font() -> FontFile:
	var result := FontFile.new()
	var path := "res://assets/fonts/regia_alien.ttf"
	if not FileAccess.file_exists(path):
		path = SOURCE
	var error := result.load_dynamic_font(path)
	if error != OK:
		push_error("Alien font unavailable: " + path)
	result.allow_system_fallback = false
	return result

static func symbol(index: int) -> String:
	return String.chr(CODES[clampi(index, 0, CODES.size() - 1)])

static func inscription(indices: Array) -> String:
	var text := ""
	for index in indices:
		text += symbol(index)
	return text
