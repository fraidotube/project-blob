PROJECT BLOB V4.3.1 - DOOR CLOSE SOUND TIMING

Modifica SOLO:
scripts/interactables/door.gd

Comportamento:
- Open Sound: parte all'inizio dell'apertura.
- Close Sound: NON parte più all'inizio della chiusura.
- Close Sound viene eseguito quando la porta arriva a battuta.
- Vale anche per auto-close.
- Se la porta viene riaperta prima di arrivare a battuta,
  il suono di chiusura pendente viene annullato.

La soglia di arrivo è 0.6 gradi; al raggiungimento viene anche
agganciata esattamente alla rotazione finale per evitare residui
dell'interpolazione lerp_angle.
