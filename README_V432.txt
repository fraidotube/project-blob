PROJECT BLOB V4.3.2 - CONTATORE + INTERRUTTORE AUDIO

Modifica SOLO:
scripts/interactables/connesi_meter.gd
scripts/interactables/interruttore.gd

CONTATORE
Nuova sezione Inspector "Meter Audio":
- Switch Sound: click meccanico dello switch, suona ad ogni toggle.
- Power On Sound: effetto elettrico quando PowerSystem passa ON.
- Power Off Sound: opzionale, quando PowerSystem passa OFF.
- Switch Volume Db
- Power Volume Db
- Audio Max Distance

Sono usati due AudioStreamPlayer3D distinti a runtime sul bus SFX,
così il click e l'effetto elettrico possono sovrapporsi.

INTERRUTTORE
Nuova sezione Inspector "Switch Audio":
- Switch On Sound
- Switch Off Sound
- Switch Volume Db
- Audio Max Distance

Se vuoi lo stesso click in entrambe le direzioni, assegna lo stesso
file sia a Switch On Sound sia a Switch Off Sound.

Il click viene eseguito solo quando il toggle è realmente accettato
dal PowerSystem. Se manca alimentazione, l'interruttore continua a
comportarsi esattamente come prima e non suona.

NON MODIFICATI:
- RayCast / InteractionSystem
- outline
- PowerSystem
- logica luci
- LED del contatore
- porte / door.gd
