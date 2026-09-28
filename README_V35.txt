PROJECT BLOB - MENU IMAGE LABELS V3.5

Sostituisce SOLO:
scripts/ui/menu_button.gd

Aggiunge anche:
assets/ui/riprendi.png
assets/ui/riprendi_blob.png
assets/ui/menu_principale.png
assets/ui/menu_principale_blob.png

NOVITA:
- NUOVA PARTITA viene resa più grande automaticamente.
- RIPRENDI ora usa le immagini normale/blob.
- MENU PRINCIPALE ora usa le immagini normale/blob.
- Nessuna modifica manuale alle scene richiesta.

PERCHE' NON VEDI LE IMMAGINI NELL'EDITOR:
Il nodo TextureRect viene creato a runtime da menu_button.gd.
Quindi nella scena salvata non esiste fisicamente: compare solo quando il gioco gira.

RIDIMENSIONAMENTO:
Le dimensioni sono controllate in _get_label_config() tramite:
pad_x
pad_y

Meno padding = immagine più grande.
Più padding = immagine più piccola.

Esempio NUOVA PARTITA:
pad_x = 10
pad_y = 1

Questo è già impostato in V3.5.
