PROJECT BLOB V4.2.1 - MENU BACKGROUND FX VISIBILI

Problema V4.2:
main_menu.tscn continuava a forzare:
AtmosphereMaterial -> intensity = 0.62

Quindi alzare soltanto il default nello shader non bastava.

V4.2.1:
- main_menu.tscn: intensity 0.62 -> 1.35
- shader atmosphere rifatto per essere chiaramente percepibile
- nebbia menu_fog.gdshader NON modificata
- nessuna modifica a logo, bottoni, audio, opzioni, FOV, loading o gameplay

EFFETTI:
- glow meteorite più forte e pulsante
- anello energetico sul cratere
- due raggi magenta dinamici
- nubi ciano/viola laterali più evidenti
- particelle più grandi e più numerose
- sweep ciano lento
- breathing delle luci laterali
- impulso magenta raro

TEST:
Lascia il menu fermo 15-20 secondi.
Questa versione deve risultare visibilmente animata anche senza cercare
l'effetto con attenzione.
