extends Node
class_name RegiaNetworkState

signal changed
const PASSWORD := [9, 2, 7, 4]
var laptop_collected := false
var laptop_placed := false
var laptop_open := false
var charger_connected := false
var laptop_on := false
var charger_collected := false
var laptop_shutdown := false
var laptop_recovered := false
var cables_taken := 0
var pc_link := false
var switch_link := false
var pppoe_valid := false
var wifi_enabled := false
var wifi_protected := true
var wifi_password := ""
var unlocked := false
var racket_available := false
var racket_collected := false
var racket_position := Vector3.ZERO
var notes_read := false
var book_read := false
var light_regia := false
var light_corridor := false
var powered := false
var online := false
var connecting_seconds := 0.0
var entered: Array[int] = []
var status := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if connecting_seconds > 0.0:
		connecting_seconds = maxf(0.0, connecting_seconds - delta)
		if connecting_seconds == 0.0:
			online = powered and switch_link and pppoe_valid
			changed.emit()

func local_network() -> bool:
	return powered and laptop_placed and charger_connected and laptop_on and pc_link

func alien_connected() -> bool:
	return powered and online and switch_link and wifi_enabled and not wifi_protected and wifi_password.is_empty()

func set_power(value: bool) -> void:
	powered = value
	if not powered:
		online = false
		connecting_seconds = 0.0
		light_regia = false
		light_corridor = false
		entered.clear()
	else:
		_negotiate()
	changed.emit()

func _negotiate() -> void:
	online = false
	connecting_seconds = 3.0 if powered and switch_link and pppoe_valid else 0.0

func take_laptop() -> bool:
	if laptop_collected or not InventoryManager.add_item(&"regia_laptop"):
		return false
	laptop_collected = true
	changed.emit()
	return true

func place_laptop() -> bool:
	if unlocked:
		status = "Non c'è più bisogno ora."
		return false
	if laptop_placed or not InventoryManager.remove_item(&"regia_laptop"):
		status = "Non ho il portatile."
		return false
	laptop_placed = true
	changed.emit()
	return true

func connect_charger() -> bool:
	if not laptop_placed:
		status = "Prima devo appoggiare il portatile sulla scrivania."
		return false
	if charger_connected:
		return true
	if not InventoryManager.remove_item(&"regia_charger"):
		status = "PC scarico."
		return false
	charger_collected = true
	charger_connected = true
	changed.emit()
	return true

func take_charger() -> bool:
	if charger_collected or not InventoryManager.add_item(&"regia_charger"):
		return false
	charger_collected = true
	changed.emit()
	return true

func shutdown_laptop() -> bool:
	if not unlocked:
		status = "Ancora mi serve, non posso spegnerlo."
		return false
	if not laptop_placed or not laptop_on:
		return false
	laptop_on = false
	laptop_open = false
	laptop_shutdown = true
	changed.emit()
	return true

func recover_laptop() -> bool:
	if not unlocked or not laptop_shutdown or not laptop_placed or laptop_recovered:
		return false
	var items := {"regia_laptop": 1, "regia_charger": 1}
	if pc_link: items["network_cable"] = 1
	# Check every capacity before changing inventory or links.
	for id: String in items:
		if not InventoryManager.definitions.has(id) or int(InventoryManager.items.get(id, 0)) + int(items[id]) > int(InventoryManager.definitions[id].max_quantity):
			return false
	for id: String in items: InventoryManager.add_item(StringName(id), items[id])
	laptop_recovered = true
	laptop_placed = false
	charger_connected = false
	pc_link = false
	changed.emit()
	return true

func use_laptop() -> String:
	if laptop_shutdown:
		return "RACCOLTO" if recover_laptop() else ""
	if not laptop_placed:
		return "Prima devo appoggiare il portatile."
	if not laptop_open:
		laptop_open = true
		if not charger_connected and InventoryManager.has_item(&"regia_charger"):
			connect_charger()
			return "Caricatore collegato."
		changed.emit()
		return "PC scarico." if not charger_connected else "Portatile aperto."
	if not charger_connected:
		if InventoryManager.has_item(&"regia_charger"):
			connect_charger()
			return "Caricatore collegato."
		return "PC scarico."
	if not powered:
		return "L'alimentatore non riceve corrente."
	if not laptop_on:
		laptop_on = true
		changed.emit()
		return "PC acceso. Interagisci di nuovo per usarlo."
	return "terminal"

func take_cable() -> bool:
	if cables_taken >= 2:
		status = "Ho già preso tutti e due i cavi utilizzabili."
		return false
	if not InventoryManager.add_item(&"network_cable"):
		return false
	cables_taken += 1
	changed.emit()
	return true

func toggle_cable(destination: String) -> bool:
	if destination not in ["pc", "switch"]:
		return false
	var attached := pc_link if destination == "pc" else switch_link
	if attached:
		if not InventoryManager.add_item(&"network_cable"):
			return false
	else:
		if not laptop_collected:
			status = "Mi serve un PC ed un cavo di rete per configurarlo."
			return false
		if destination == "pc" and not laptop_placed:
			status = "Prima devo appoggiare il PC sulla scrivania."
			return false
		if not InventoryManager.remove_item(&"network_cable"):
			status = "Mi serve un cavo di rete."
			return false
	if destination == "pc":
		pc_link = not attached
	else:
		switch_link = not attached
		_negotiate()
	if not alien_connected():
		entered.clear()
	changed.emit()
	return true

func configure_pppoe(username: String, password: String) -> bool:
	if not local_network():
		status = "Il Fritz non è raggiungibile. Controlla corrente e cavo del PC."
		return false
	pppoe_valid = username == "narcisolo" and password == "ottavonano"
	status = "Credenziali salvate. Attendo l'uplink allo switch." if pppoe_valid else "Autenticazione PPPoE fallita."
	_negotiate()
	changed.emit()
	return pppoe_valid

func configure_wifi(enabled: bool, protected: bool, password: String) -> bool:
	if not local_network():
		status = "Il Fritz non è raggiungibile."
		return false
	wifi_enabled = enabled
	wifi_protected = protected
	wifi_password = password if protected else ""
	if not alien_connected():
		entered.clear()
	changed.emit()
	return true

func press_symbol(index: int) -> String:
	if unlocked:
		return "APERTA"
	if not alien_connected():
		entered.clear()
		return "NO_WIFI"
	if index < 0 or index >= 12:
		return ""
	entered.append(index)
	if entered.size() < 4:
		changed.emit()
		return "INPUT"
	unlocked = entered == PASSWORD
	entered.clear()
	changed.emit()
	return "APERTA" if unlocked else "ERRATA"

func snapshot() -> Dictionary:
	return {
		"laptop_collected": laptop_collected, "laptop_placed": laptop_placed,
		"laptop_open": laptop_open, "charger_connected": charger_connected, "laptop_on": laptop_on,
		"charger_collected": charger_collected, "laptop_shutdown": laptop_shutdown, "laptop_recovered": laptop_recovered,
		"cables_taken": cables_taken, "pc_link": pc_link, "switch_link": switch_link,
		"pppoe_valid": pppoe_valid, "wifi_enabled": wifi_enabled, "wifi_protected": wifi_protected,
		"wifi_password": wifi_password, "unlocked": unlocked, "racket_available": racket_available,
		"racket_collected": racket_collected, "racket_position": racket_position,
		"notes_read": notes_read, "book_read": book_read, "light_regia": light_regia, "light_corridor": light_corridor
	}

func restore(data: Dictionary) -> void:
	for key: String in snapshot():
		if data.has(key) and typeof(data[key]) == typeof(get(key)):
			set(key, data[key])
	cables_taken = clampi(cables_taken, 0, 2)
	# Old snapshots already had the charger physically connected.
	charger_collected = charger_collected or charger_connected
	entered.clear()
	_negotiate()
	changed.emit()
