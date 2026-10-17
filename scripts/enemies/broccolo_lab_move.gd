extends Node
## Mossa duplicabile nella scena di laboratorio; non modifica le risorse originali.

## Clip della libreria mie; nome verificato all'avvio.
@export var clip: StringName = &"mie/FlyingKick"
## Attacco: applica un colpo. Scenetta: apre la vulnerabilita del boss.
@export_enum("Attacco", "Scenetta", "Lancio") var kind := 0
## Frazione della clip al momento dell'impatto.
@export_range(0.05, 0.95, 0.01) var impact_fraction := 0.45
## Danno al player per un colpo connesso.
@export_range(1, 100, 1) var damage := 5
## Portata frontale del colpo, in metri.
@export_range(0.2, 3.0, 0.05) var reach := 0.85
## Impulso verticale al decollo, m/s; zero per mosse a terra.
@export_range(0.0, 8.0, 0.1) var jump_speed := 0.0
## Velocita frontale durante la prima parte della mossa, m/s.
@export_range(0.0, 4.0, 0.1) var advance_speed := 0.0
## Velocita della sfera energetica, metri al secondo.
@export_range(1.0, 12.0, 0.5) var projectile_speed := 5.0
## Raggio dell'esplosione della sfera, metri; danno impedito dai muri.
@export_range(0.2, 3.0, 0.1) var blast_radius := 1.2
