PROJECT BLOB - MENU IMAGE LABELS V3.6

OBIETTIVO:
tutte le scritte PNG devono avere la stessa ALTEZZA VISIVA REALE.

Problema precedente:
i PNG hanno dimensioni canvas e trasparenze differenti.
Ridimensionando l'intero PNG, "NUOVA PARTITA" e soprattutto
"MENU PRINCIPALE" apparivano molto più piccoli.

V3.6:
- legge automaticamente l'alpha di ogni PNG
- trova il bounding box reale dei pixel visibili
- taglia virtualmente il vuoto trasparente
- usa per TUTTE le scritte normali un'altezza visiva di 34 px
- la versione _blob mantiene la STESSA scala del testo normale:
  il blob può quindi espandersi senza rimpicciolire le lettere

Questo vale per:
NUOVA PARTITA
OPZIONI
ESCI
APPLICA
INDIETRO
RIPRENDI
MENU PRINCIPALE

PER CAMBIARE TUTTE LE SCRITTE INSIEME:
nel file scripts/ui/menu_button.gd:

@export var label_visible_height := 34.0

Esempi:
30 = tutte più piccole
34 = baseline V3.6
38 = tutte più grandi
42 = tutte ancora più grandi

Non serve più regolare singolarmente ogni PNG.
