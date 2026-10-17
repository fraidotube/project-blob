extends SceneTree

# Read-only dependency inventory. Does not load the map, move or delete assets.
var files: Dictionary = {}
var reachable: Dictionary = {}
var reasons: Dictionary = {}
var queue: Array[String] = []
var folders: Dictionary = {}
var missing: Dictionary = {}
var asset_classes: Dictionary = {}
var references := RegEx.new()
var uid_references := RegEx.new()
var class_declarations := RegEx.new()
var relative_assets := RegEx.new()
const TEXT_EXTENSIONS := ["gd", "tscn", "tres", "godot", "gdshader", "shader", "svg", "json", "cfg", "gltf", "mtl", "obj", "py", "md", "txt"]
const ROOT_EXTENSIONS := ["gd", "tscn", "tres", "godot", "gdshader", "shader", "py", "md", "txt", "cfg"]

func _initialize() -> void:
	call_deferred("run")

func walk(path: String) -> void:
	if path != "res://" and FileAccess.file_exists(path.path_join(".gdignore")): return
	var directory := DirAccess.open(path)
	if directory == null: return
	for name in directory.get_files():
		var full := path.path_join(name)
		var file := FileAccess.open(full, FileAccess.READ)
		if file: files[full] = file.get_length()
	for name in directory.get_directories():
		if name.begins_with(".") or name in ["local_optimization", "asset_archive", "node_modules"]: continue
		walk(path.path_join(name))

func mark(path: String, reason: String) -> void:
	path = path.simplify_path()
	if path == "res://": return
	if path.begins_with("uid://"):
		var id := ResourceUID.text_to_id(path)
		if ResourceUID.has_id(id): path = ResourceUID.get_id_path(id)
		else:
			missing[path] = reason
			return
	if not path.begins_with("res://") or path.begins_with("res://.godot/"): return
	if DirAccess.dir_exists_absolute(path):
		folders[path.trim_suffix("/") + "/"] = reason
		return
	if not files.has(path):
		# Formatted names such as swoosh%d.mp3 are runtime dependencies.
		if path.contains("%") or path.contains("*"):
			var directory := path.get_base_dir() + "/"
			var name_prefix := path.get_file().split("%")[0].split("*")[0]
			for candidate in files:
				if candidate.begins_with(directory) and candidate.get_file().begins_with(name_prefix):
					mark(candidate, "formatted runtime name: " + path)
			return
		missing[path] = reason
		return
	if not reachable.has(path):
		reachable[path] = true
		reasons[path] = reason
		queue.append(path)

func dependency(path: String, source: String) -> void:
	var sections := path.split("::")
	if sections.size() > 1:
		mark(sections[0], "UID dependency: " + source)
		mark(sections[sections.size() - 1], "dependency fallback: " + source)
	else: mark(path, "dependency: " + source)

func inspect(path: String) -> void:
	var extension := path.get_extension().to_lower()
	if extension in TEXT_EXTENSIONS:
		var text := FileAccess.get_file_as_string(path)
		for result in references.search_all(text): mark(result.get_string().trim_suffix("/"), "text reference: " + path)
		for result in uid_references.search_all(text): mark(result.get_string(), "UID text: " + path)
		if extension == "py":
			for result in relative_assets.search_all(text): mark("res://" + result.get_string(), "tool/editor relative asset: " + path)
		if extension == "gltf":
			var gltf = JSON.parse_string(text)
			if gltf is Dictionary:
				for section in ["buffers", "images"]:
					for item in gltf.get(section, []):
						var uri: String = item.get("uri", "")
						if not uri.is_empty() and not uri.begins_with("data:"):
							mark(path.get_base_dir().path_join(uri.uri_decode()), "glTF source dependency: " + path)
		for name in asset_classes:
			if text.contains(name): mark(asset_classes[name], "global class " + name + ": " + path)
	# Binary resources and imported models can carry dependencies absent from text.
	if extension in ["res", "scn", "glb", "gltf", "fbx", "obj", "tscn", "tres"] and ResourceLoader.exists(path):
		for item in ResourceLoader.get_dependencies(path): dependency(item, path)
	if FileAccess.file_exists(path + ".import"):
		reachable[path + ".import"] = true
		reasons[path + ".import"] = "import metadata: " + path
		var config := ConfigFile.new()
		if config.load(path + ".import") == OK:
			if config.has_section("params"):
				for key in config.get_section_keys("params"):
					var value = config.get_value("params", key)
					if value is String and value.begins_with("res://"): mark(value, "import parameter: " + path)
	if FileAccess.file_exists(path + ".uid"):
		reachable[path + ".uid"] = true
		reasons[path + ".uid"] = "UID sidecar: " + path

func run() -> void:
	references.compile("res://[^\\\"'\\r\\n\\t<>]+")
	relative_assets.compile("assets/[^\\\"'\\r\\n\\t<>`]+")
	uid_references.compile("uid://[a-z0-9]+")
	class_declarations.compile("class_name\\s+([A-Za-z_][A-Za-z_0-9]*)")
	var inventory: Array = JSON.parse_string(FileAccess.get_file_as_string("res://.godot/project_file_inventory.json"))
	for row in inventory: files[String(row.path)] = int(row.bytes)
	print("ASSET_AUDIT_INVENTORY ", files.size())
	for path in files:
		if path.begins_with("res://assets/") and path.get_extension() == "gd":
			var match := class_declarations.search(FileAccess.get_file_as_string(path))
			if match: asset_classes[match.get_string(1)] = path
	for path in files:
		if path == get_script().resource_path: continue
		if not path.begins_with("res://assets/") and path.get_extension().to_lower() in ROOT_EXTENSIONS:
			mark(path, "project/code/test/document root")
	var cursor := 0
	while cursor < queue.size():
		inspect(queue[cursor])
		cursor += 1
		if cursor % 250 == 0: print("ASSET_AUDIT_PROGRESS ", cursor, "/", queue.size())
		# Folder literals protect dynamic loads. Revisit as more folders appear.
		if cursor == queue.size():
			for path in files:
				for folder in folders:
					if path.begins_with(folder):
						mark(path, "dynamic folder protection: " + folder)
	var rows: Array = []
	var totals := {"keep_count": 0, "candidate_count": 0, "keep_bytes": 0, "candidate_bytes": 0}
	for path in files:
		if not path.begins_with("res://assets/"): continue
		var kept := reachable.has(path)
		var base: String = path.trim_suffix(".import").trim_suffix(".uid")
		if reachable.has(base): kept = true
		var status := "keep" if kept else "unreferenced_candidate"
		rows.append({"path": path, "bytes": files[path], "status": status, "reason": reasons.get(path, reasons.get(base, "no dependency found in conservative project graph"))})
		totals[("keep_count" if kept else "candidate_count")] += 1
		totals[("keep_bytes" if kept else "candidate_bytes")] += files[path]
	rows.sort_custom(func(a, b): return a.bytes > b.bytes)
	var report := {"totals": totals, "rows": rows, "protected_folders": folders, "missing_references": missing, "roots_include_tests_docs_and_tools": true}
	var output := FileAccess.open("res://.godot/asset_dependency_audit_v2.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "\t"))
	print("ASSET_AUDIT_TOTALS ", JSON.stringify(totals))
	print("ASSET_AUDIT_MISSING ", missing.size(), " protected_folders=", folders.size())
	quit()
