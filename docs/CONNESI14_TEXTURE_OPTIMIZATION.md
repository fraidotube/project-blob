# Connesi14 — verifica mesh e prima copia texture

12/10/2026. Richiesta: verificare connesi14 e aiutare sulle texture senza rovinare il lavoro. Rilevato salvataggio durante il primo audit; utente conferma di avere terminato. Usata l'ultima versione di `D:/ProjectBlob/Assets_Source/connesi14.blend`, 2.049.265.923byte, LastWriteTime00:21:00. Sorgente e texture originali conservati.

## Mesh

Confronto omogeneo dei triangoli base sommati sugli oggetti: connesi13 8.576.436 → connesi14 6.199.362, riduzione27,7%. Oggetti mesh3.069; totale con modificatori viewport5.652.174. Quest'ultimo non equivale automaticamente al risultato glTF/render: dipende dai modificatori esportati e dagli oggetti inclusi.

| Oggetto | Connesi13 base | Connesi14 base |
|---|---:|---:|
| Fiat_Panda_2011 | 1.307.542 | 523.016 |
| Contatori_Sx.SportelloSx | 254.502 | 12 |
| Contatori_Sx.SportelloDx | 223.376 | 12 |
| Officina | 398.823 | 303.801 |
| Casa Vicina | 398.456 | 378.730 |

Panda ancora maggiore candidato singolo; Casa Vicina/Officina/Colonnina Ricarica rimangono pesanti. Sphere001 ha11.988 triangoli base ma193.584 dopo Subsurf/Displace viewport: misurare il risultato esportato. I vecchi sportelli `_old`, presenti nel salvataggio iniziale analizzato, non sono nel definitivo. Nessuna modifica alle mesh effettuata dall'assistente.

## Copia consegnata

`local_optimization/connesi14/connesi14_textures_candidate.blend`, 1.896.379.428byte (~1,90GB), circa153MB/7,46% meno del sorgente. Cartella esclusa dall'import Godot tramite `.gdignore`; file pesanti locali non committati.

26 immagini ottimizzate selettivamente:

- Materiali Iveco `Back door`, `Body exterior 1`, `Body exterior 2`, `Body Interior`:20 immagini4K→2K.
- `Cardboard_Box_Mat`:4 immagini4K→2K.
- Auto rotta `car03_u1_v1.jpeg`:8K→2K.
- Pavimentazione `paved.png`:8K→4K.

Pixel nelle26 immagini536.870.912→121.634.816 (−77,34%). Non equivale al77% di risparmio di tutte le texture della mappa o a un guadagno FPS misurato. La terza8K, Toolbox, non risulta assegnata a materiali nella nuova versione e non è stata ridimensionata. Tutte le altre immagini fuori dalla selezione conservate, inclusi materiali di puzzle/scritte/display.

Immagini ottimizzate PNG, packed nella copia e salvate anche in `textures/`. Nessuna riscrittura dei file originali esterni. Non applicati modificatori né cambiate mesh/UV/pivot/gerarchie/materiali; varia solo il contenuto delle immagini selezionate e, nella copia, il loro percorso. Normali/spazi colore/alpha conservati. Downsampling introduce una riduzione del dettaglio: approvazione visiva da vicino ancora aperta.

## Verifiche e problemi incontrati

Auditor aggiornato `tools/blender/audit_connesi14_readonly.py`; produce `.godot/connesi14_audit.json` con modificatori, triangoli valutati, visibilità e associazioni immagini/materiali. Script nativi Blender per creazione/verifica: `build_connesi14_texture_candidate.py`, `verify_connesi14_texture_candidate.py`. Non sono patch testuali automatiche a script/scene del gioco; operano su un nuovo asset Blender isolato.

Prima creazione fermata dalla verifica dimensioni: il PNG ridotto era2K ma pack/reload conservava dati originali. Correzione: rimuovere il vecchio packed payload solo nella sessione in memoria, incorporare esattamente i byte PNG nuovi e controllare reload. Salvataggio successivo eseguito ma segnalato errore autopack per riferimento sorgente già mancante `Car/HD_Vehicles_Materials/GENERIC_HEADLIGHT_GLASS_dif.jpg`. Recuperata la copia salvata, verificati gli hash packed contro i PNG, disattivato autopack solo nella copia e corretti percorsi relativi. Nessuna texture sostitutiva inventata. Il materiale mancante va verificato prima dell'export.

Riapertura completata: nomi oggetti mesh/datablock e conteggi triangoli di3.069 oggetti confrontati con audit sorgente; dimensioni/hash packed/spazi colore/alpha di26 immagini verificati. `manifest.json` e `validation.json` nella cartella consegnata. Confronto visivo atlante Back_door originale/copia e ispezione auto rotta: nessun cambiamento grossolano di colore/composizione; non prova della resa3D ravvicinata. Avviso thumbnail OpenImageIO nel salvataggio, file blend salvato; nessun errore di validazione.

Dimensione/data del sorgente finali invariati. Gioco ancora sul GLB precedente (LastWriteTime10/10), quindi non attribuire miglioramenti runtime alla nuova versione senza export/import e benchmark. Nessun playtest/benchmark mappa ripetuto su asset vecchio; nessun commit/push.

Prossimo passo: aprire la copia consegnata, confrontare oggetti selezionati da vicino, poi esportare/importare preservando i nodi funzionali e verificare sportelli/passaggi/illuminazione. Se gradita, proseguire selettivamente sui restanti set4K; conservare il sorgente14 come ripristino.

API consultata: [Blender Image — scale, save e pack](https://docs.blender.org/api/5.2/bpy.types.Image.html).
