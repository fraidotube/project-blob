extends "res://scripts/enemies/broccolo_map_combat.gd"
## Fixture per esercitare la tinta senza inizializzare AI, navigazione o audio boss.
func _ready() -> void: pass
func _process(_delta: float) -> void: pass
func _exit_tree() -> void: _restore_map_lighting()
