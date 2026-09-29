PROJECT BLOB V4.3 - DOOR AUDIO

Modifica SOLO:
scripts/interactables/door.gd

NON cambia:
- sistema RayCast centrale
- outline
- HUD interazione
- logica DoorBody/Area3D
- auto close
- collisioni
- apertura su asse Y

NUOVI CAMPI INSPECTOR
Door Audio:
- Open Sound
- Close Sound
- Door Audio Volume Db
- Door Audio Max Distance

Ogni porta può quindi avere file audio diversi.

Lo script crea da solo un AudioStreamPlayer3D chiamato DoorAudio:
- Bus = SFX
- posizione = root della porta
- max_distance configurabile

USO
1. Sostituisci door.gd con questo file.
2. Seleziona ogni porta.
3. In Inspector > Door Audio:
   Open Sound  -> trascina il suono apertura specifico.
   Close Sound -> trascina il suono chiusura specifico.
4. Regola Door Audio Volume Db per quella porta.
5. Se serve, regola Max Distance.

Se Open Sound o Close Sound è vuoto, quella fase resta silenziosa.

L'audio di chiusura funziona anche con auto-close.
