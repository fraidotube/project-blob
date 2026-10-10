# PROJECT BLOB - STANDARD TECNICI

Baseline tecnica: 1 ottobre 2026. Nota di continuità aggiunta: 8 ottobre 2026.
Motore: Godot 4.7.2

## Contratto SAFE
- Prima di ogni modifica rilevante, identificare e documentare una baseline Git ripristinabile e le differenze locali da preservare. Creare un nuovo commit di baseline solo su richiesta dell'utente; non presumere che Git conservi file non tracciati o ignorati.
- Non sovrascrivere scene, script o asset approvati senza verificare la versione corrente.
- Preferire script completi e modifiche verificabili.
- Non includere nel repository asset commerciali senza averne verificato la licenza.
- Nessun commit o push autonomo; staging solo su path espliciti, mai `git add .` o `git add -A`.
- Per il contratto completo e la distinzione tra prove storiche e stato locale, leggere [la baseline SAFE](BASELINE_SAFE_2026-10-08.md) e [l'indice](README.md).

## Impatti balistici
- Gestore condiviso: scripts/effects/impact_manager.gd
- Gli effetti sono collegati alla pistola e non alla singola mappa.
- Il raycast deve escludere il Player per evitare autodanno.
- Preservare le dimensioni degli impatti già approvate.
- Il vetro mostra crepe, ma per ora non si rompe.

## Assegnazione delle superfici
Selezionare il nodo collider (es. StaticBody3D).
Nell'Inspector, aggiungere un Metadata di tipo String:
  surface_type = glass

Valori supportati:
- concrete: cemento
- wood: legno
- metal: metallo
- glass: vetro
- asphalt: asfalto
- drywall: cartongesso
- generic: impatto generico

Senza surface_type viene utilizzato l'impatto generico.
Non assegnare il metadato al MeshInstance3D o al CollisionShape3D.
Per materiali diversi nello stesso oggetto usare collider separati.

Nota verificata localmente: i passi del player usano invece i gruppi `surface_rock`, `surface_tile` e `surface_parquet` sul collider o sugli antenati. Preservare sia questi gruppi sia `surface_type`: servono a sistemi diversi.

## Audio
- I bus separano Music, SFX, Weapons, Player, Ambience e UI.
- Regolare il volume del singolo effetto senza alterare il mix generale.
- Gli impatti utilizzano suoni 3D della categoria corrispondente.
- I file audio degli impatti seguono nomi come concrete1.mp3,
  concrete2.mp3, glass1.mp3, metal1.mp3, wood1.mp3.
- Nuovi suoni con lo stesso schema vengono rilevati automaticamente.
- In assenza di audio generico dedicato si usa il cemento.
- Il volume della pistola è indipendente dal volume generale SFX.

## Opzioni
- Unico gestore globale: SettingsManager.
- Unico archivio persistente: user://settings.cfg.
- Menu principale e menu pausa utilizzano gli stessi valori.
- Non ricaricare il file a ogni cambio scena.
- Non emettere eventi di modifica durante l'inizializzazione degli slider.
- GameSettings è solo un componente temporaneo di compatibilità.

## Atmosfera
- Nebbia esterna approvata come impostazione sperimentale.
- Nella scena definitiva, evitare la nebbia globale intensa negli interni.
- Qualsiasi prova atmosferica deve partire da una baseline funzionante.
