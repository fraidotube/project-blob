extends RefCounted

static var cache: Dictionary = {}

static func texture(id: String) -> Texture2D:
	if cache.has(id): return cache[id]
	var drawing := ""
	match id:
		"bruno_key", "switch_key", "assistance_key", "production_key":
			drawing = '<circle cx="48" cy="48" r="22" fill="#c4bfae"/><circle cx="48" cy="48" r="8" fill="#28202e"/><path d="M62 62L98 98L89 107L79 97L84 92L72 80L67 85L56 74" fill="#c4bfae"/><circle cx="112" cy="112" r="17" fill="none" stroke="#ddd5ba" stroke-width="4"/><path d="M119 123L146 136L132 159L107 144Z" fill="#637080"/>'
		"network_cable":
			drawing = '<path d="M28 37C-2 119 154 150 125 67C113 37 53 43 53 84C53 121 125 139 141 100" fill="none" stroke="#d5b652" stroke-width="9"/><path d="M19 17H39V45H19ZM131 82H151V110H131Z" fill="#dae3eb" stroke="#738397" stroke-width="3"/><path d="M23 19V30M28 19V30M33 19V30M135 84V95M140 84V95M145 84V95" stroke="#a78e48" stroke-width="2"/>'
		"regia_laptop":
			drawing = '<rect x="24" y="25" width="112" height="78" rx="6" fill="#4c5864" stroke="#b6c6d1" stroke-width="4"/><rect x="32" y="33" width="96" height="60" fill="#125879"/><path d="M24 103H136L152 137H8Z" fill="#70838f"/><path d="M32 110H128L135 124H25Z" fill="#252d35"/><rect x="62" y="128" width="36" height="6" fill="#b6c6d1"/>'
		"regia_charger":
			drawing = '<path d="M50 52C15 9 7 108 47 113M115 83C167 127 149 13 125 22" fill="none" stroke="#8b8295" stroke-width="6"/><rect x="41" y="50" width="78" height="54" rx="6" fill="#242a31" stroke="#8994a0" stroke-width="3"/><path d="M61 69H100M61 78H100M61 87H86" stroke="#636b75" stroke-width="3"/><rect x="118" y="15" width="17" height="16" fill="#9da3ae"/>'
		"bruno_racket":
			drawing = '<ellipse cx="69" cy="52" rx="36" ry="44" transform="rotate(30 69 52)" fill="none" stroke="#afce88" stroke-width="8"/><path d="M47 20L80 91M60 10L94 81M37 36L71 99M27 47L97 18M29 65L108 34M39 81L112 52" stroke="#c6b7cb" stroke-width="2"/><path d="M85 83L128 143" stroke="#afce88" stroke-width="9"/><path d="M107 113L128 143" stroke="#5b6370" stroke-width="15"/>'
		_:
			drawing = '<path d="M30 35H130V130H30Z" fill="#758998"/><path d="M30 35L80 15L130 35L80 55Z" fill="#b4c3cc"/>'
	var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160" viewBox="0 0 160 160">' + drawing + '</svg>'
	var image := Image.new()
	image.load_svg_from_string(svg)
	var icon := ImageTexture.create_from_image(image)
	cache[id] = icon
	return icon
