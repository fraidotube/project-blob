# PROJECT BLOB - STANDARD TECNICI

Baseline: 1 ottobre 2026
Motore: Godot 4.7.2

## Contratto SAFE
- Prima di ogni modifica rilevante, creare una baseline Git.
- Non sovrascrivere scene, script o asset approvati senza verificare la versione corrente.
- Preferire script completi e modifiche verificabili.
- Non includere nel repository asset commerciali senza averne verificato la licenza.

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
