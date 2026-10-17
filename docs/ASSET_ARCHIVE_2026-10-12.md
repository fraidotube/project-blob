# Archiviazione degli asset non referenziati

Richiesta utente: spostare gli asset non usati prima di continuare; eccezione esplicita per tutte le cartelle dei nemici. Godot salvato e chiuso dall'utente prima dello spostamento.

## Risultato

Spostati 6.047 file, 14.916.740.460 byte (13,89 GiB), in `asset_archive/2026-10-12/assets/`, conservando la struttura originale. Nessun file cancellato e nessuna destinazione sovrascritta. Tutto `assets/models/enemies/` conservato, incluse varianti, sorgenti, audio, animazioni e nuovi file broccolo comparsi durante la sessione. Conservati anche README e metadati di licenza.

Archivio escluso dalla scansione Godot (`asset_archive/.gdignore`) e da Git (`asset_archive/` aggiunto a .gitignore). Non è spazio liberato dal disco: i file sono sullo stesso volume. Riduce gli asset da scandire/importare nell'editor; non implica un miglioramento FPS delle risorse già caricate.

L'inventario originale aveva circa24,24GB in assets; dopo lo spostamento restano circa9,32GB, inclusi nuovi file dei nemici. Nessun intervento sulla cache `.godot` o su `Assets_Source/connesi14.blend`.

## Metodo conservativo

Inventario filesystem, riferimenti res:// e UID nel codice e nei file testuali, dipendenze di risorse binarie e modelli importati tramite ResourceLoader.get_dependencies, classi globali, sorgenti glTF relativi, riferimenti dei tool Python, metadata import/UID e nomi costruiti con formato. Root includono scene, codice, test, strumenti e documenti fuori da assets; non soltanto map_test.

Le cartelle usate con percorsi dinamici sono protette per intero, tra cui audio enemy/impatti, texture impatti e volti HUD. L'eccezione nemici è applicata in aggiunta e verificata su tutti i percorsi assoluti prima dello spostamento.

Non essere raggiunto da questo grafo non prova l'inutilizzo in ogni possibile percorso futuro o modifica manuale dell'editor. Per questo si archivia e si mantiene un ripristino. Licenze e pacchetti commerciali non vengono pubblicati automaticamente.

## Verifiche

- Tutti i2.909 file protetti dell'inventario presenti nella posizione originale e con stessa dimensione; zero file nemici nel registro degli spostamenti.
- Inventario dipendenze ripetuto con filesystem aggiornato: nessuna nuova referenza mancante rispetto al prima. Le29 segnalazioni già presenti comprendono percorsi storici SilverDelivery, UID import di animazioni e stringhe documentali; non sono create dall'archiviazione.
- `sliding_passage_test.gd` passa failures0 caricando la mappa vera, player/HUD/armi, regia e presentazione Angelastri; scorrevoli libere nelle due direzioni.
- `inventory_save_test.gd` passa INVENTORY_SAVE_TESTS_OK; slot automatici `.godot`, salvataggio utente non scritto.
- Avvisi certificate store headless/SparksElectric già storici. Non verificati tutti i combattimenti, ogni audio a runtime, resa GPU completa o importazione da cache vuota. Un playtest dopo riapertura resta necessario.

## Blender e GLB

Il GLB attivo dell'edificio contiene404 immagini, zero URI esterni per immagini e buffer: il modello esportato è incorporato per questi dati. [Manuale Blender glTF](https://docs.blender.org/manual/en/5.1/addons/import_export/scene_gltf2.html).

Questo non include automaticamente le risorse di tutto il progetto Godot: scene, script, audio, UI, shader e texture assegnate nei materiali/override restano dipendenze esterne. Le immagini packed del blend corrente sono state verificate nella sessione texture; packing delle immagini non implica packing universale di ogni libreria, cache, font o altro file Blender. Non cancellare l'archivio sulla sola base dell'export GLB.

## Registri e ripristino

`manifest.json` conserva elenco/reason/byte dei candidati e file protetti; `checked_paths.json` conserva i percorsi assoluti validati; `moves.json` e `moves.jsonl` registrano i file realmente spostati; `dependencies_before.json` e `dependencies_after.json` documentano il confronto. Tutti nell'archivio locale.

`tools/restore_archived_assets.ps1` ripristina i file dopo aver controllato percorsi, presenza e dimensioni, senza sovrascrivere file esistenti. Non eseguito in questa sessione. Chiudere Godot prima di usarlo; per ripristini selettivi seguire il registro dei percorsi.

Il primo preflight si fermava per lettura JSON non UTF8, risolta prima di muovere alcun file. Durante lo spostamento il limite Windows dei percorsi lunghi fermava Move-Item; completato con API .NET e prefisso extended-length, sempre nella stessa shell e dopo verifica dei target. Registro verificato6047 movimenti senza duplicati. Nessun reset/clean, staging, commit o push. Le nuove cancellazioni Git degli asset tracciati rappresentano spostamenti nell'archivio, non perdita dei file.

Strumento diagnostico completo: `scripts/tools/audit_asset_dependencies.gd`; script movimento: `tools/archive_unused_assets.ps1`. Inventario JSON e log test nella cache `.godot`; i registri necessari al ripristino sono nell'archivio, non dipendono dalla cache.
