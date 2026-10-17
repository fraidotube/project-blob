extends Node
## Configurazione duplicabile dei ruoli delle copie nel laboratorio.
## Ruolo stabile per rigenerare lo stesso tipo quando viene eliminato.
@export var role_id: StringName = &"runner"
## Strategia di inseguimento e attacco.
@export_enum("Assaltatore", "Lanciatore", "Aggiramento") var strategy := 0
## Velocita di corsa in metri al secondo.
@export_range(0.5, 6.0, 0.1) var run_speed := 3.5
## Pausa tra attacchi in secondi.
@export_range(0.1, 5.0, 0.1) var attack_cooldown := 0.35
## Intervallo scenette in secondi; zero le disattiva per questo ruolo.
@export_range(0.0, 30.0, 0.5) var show_interval := 0.0
## Distanza preferita dal giocatore per il lanciatore, metri.
@export_range(1.5, 8.0, 0.1) var ranged_distance := 4.0
## Ampiezza della deviazione laterale dell'aggiratore, metri.
@export_range(1.0, 6.0, 0.1) var flank_radius := 2.6
## Durata della fase larga prima di chiudere verso il player, secondi.
@export_range(0.5, 8.0, 0.1) var flank_seconds := 2.2
