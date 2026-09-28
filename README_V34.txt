PROJECT BLOB - MENU IMAGE LABELS V3.4

NESSUN PASSAGGIO MANUALE NELL'EDITOR.

Sostituisce SOLO:
scripts/ui/menu_button.gd

Usa automaticamente queste immagini già presenti in:
res://assets/ui/

NUOVA PARTITA
- nuova_partita.png
- nuova_partita_blob.png

OPZIONI
- opzioni.png
- opzioni_blob.png

ESCI
- esci.png
- esci_blob.png

APPLICA
- applica.png
- applica_blob.png

INDIETRO
- indietro.png
- indietro_blob.png

COMPORTAMENTO:
- il Button originale resta identico
- mantiene rettangolo, bordo, glow e animazione
- il testo standard viene nascosto
- viene creata automaticamente una TextureRect centrata
- stato normale -> immagine senza blob
- hover/focus -> immagine con blob
- i pulsanti senza immagini dedicate restano con il testo normale

Questo significa che RIPRENDI e MENU PRINCIPALE nel pause menu
non vengono toccati per ora.

PROCEDURA:
1. Chiudi Godot
2. Estrai nella root D:\ProjectBlob\Game
3. Riapri Godot
4. Avvia e prova Main Menu + Opzioni
