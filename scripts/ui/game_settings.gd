extends Node
class_name GameSettings

# Compatibility facade only: scenes still contain a legacy GameSettings node.
# All data and disk access belongs to the SettingsManager autoload.
# No independent defaults or file writes are permitted here.

func load_settings() -> void:
	# SettingsManager is initialized before the game scenes.
	pass


func save_settings() -> void:
	SettingsManager.save_settings()


func apply_settings() -> void:
	SettingsManager.apply_settings()


func apply_audio() -> void:
	SettingsManager.apply_audio()
