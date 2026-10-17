# Project Blob — diagnosi prestazioni e piano Blender

Analisi 11/10/2026; obiettivo utente: ottimizzare prima di aggiungere gameplay. Successivo vincolo: ispezionare `D:/ProjectBlob/Assets_Source/connesi13.blend` senza modificarlo e suggerire interventi. Nessuna modifica a scene, import, impostazioni persistenti o asset.

## Dati verificati

- Git: `dev/prototype-0.1`, HEAD `3b685e42b67e616334c81008d10575044f95b8e6`. Cancellazioni SilverDelivery, sei audio modificati e asset locali preesistenti conservati; nessun commit/push.
- Sorgente Blender: 2.146.813.884 byte; GLB edificio: 2.022.385.736 byte; risorsa Godot importata principale: 257.618.712 byte; map_test: 25.371.419 byte. Il peso del GLB sorgente NON equivale ai byte letti a ogni avvio: Godot usa la risorsa importata e le sue dipendenze.
- Blender 5.2.1: 3.068 oggetti mesh, 2.721 datablock mesh, 299 materiali, 8.576.436 triangoli base sommati sulle istanze. I modificatori possono cambiare il totale esportato; il GLB corrente conta circa 7.880.363 triangoli sulle definizioni mesh, 2.666 mesh e 369 immagini. Questi due conteggi hanno basi diverse.
- Immagini Blender: 123 immagini 4096×4096 e tre 8192×8192, oltre alle risoluzioni inferiori. Le tre 8K sono `car03_u1_v1.jpeg`, `paved.png`, `Toolbox_RC_LOD0_u0_v0_diffuse.png`. Non tutte le immagini Blender sono necessariamente usate dalla mappa.
- Le import texture controllate (`Cardboard_boxes_1_Normal`, `Fiat132_Base_Color`) hanno già compressione VRAM/mipmap e `process/size_limit=0`. L'import del GLB ha già generazione LOD e shadow mesh attiva. Non suggerire di attivare nuovamente funzioni già presenti.
- Hardware letto: RTX 4060, GPU integrata AMD, RAM utilizzabile circa 13,9 GiB. `AdapterRAM` di WMI non costituisce una misura affidabile della VRAM della RTX; non usarlo per dedurre che abbia 4 GB.

## Priorità Blender, sulla futura copia ottimizzata

| Oggetto esatto | Triangoli base | Intervento suggerito |
|---|---:|---|
| Fiat_Panda_2011 | 1.307.542 | Primo candidato: semplificare particolari piccoli/interni non visibili, poi decimazione selettiva; valutare una versione da 50–100 mila triangoli |
| Default (collezione VEICOLI) | 999.970 | Identificare visivamente la parte prima di ridurre; dimensioni circa 1,14×0,46×0,57 m, quasi un milione di triangoli su un elemento piccolo |
| Contatori_Sx.SportelloSx | 254.502 | Semplificare superfici piane/microdettagli; prova iniziale 5–15 mila triangoli per sportello |
| Contatori_Sx.SportelloDx | 223.376 | Stesso intervento; preservare separazione, pivot, nomi, UV, silhouette e montaggio |
| Officina | 398.823 | Semplificare edificio di sfondo in base alla distanza reale di osservazione |
| Casa Vicina | 398.456 | Stesso criterio; evitare perdita della silhouette |
| Colonnina Ricarica | 202.571 | Ridurre dettaglio non percepibile; prova iniziale 10–20 mila triangoli |

I budget sono obiettivi iniziali da valutare visivamente, non soglie del motore né garanzia di qualità. `Casa Vicina Cancello` (622.666 base) e `Cassonetti` (313.812 base) hanno già Decimate: controllare il risultato valutato prima di aggiungere altra decimazione. Non attribuire questi totali base automaticamente alla versione esportata.

Procedura consigliata: creare una copia separata del blend; lavorare su un oggetto alla volta, aggiungere Decimate non applicato e confrontare silhouette/UV/normali alla distanza FPS e nelle cinematiche. Sulle superfici piane valutare Planar; su forme organiche Collapse. Un ratio basso è una prova, non un'impostazione globale per tutto l'edificio. Usare normal map per dettagli che non cambiano la silhouette. Non semplificare indiscriminatamente porte, scala, pavimenti, monitor o chiusura aliena.

Texture: iniziare da auto rotta e cassetta attrezzi 8K, provare copie 2K (16 volte meno texel). Per `paved.png`, confrontare 2K/4K da vicino e valutare ripetizione della texture. Successivamente valutare i set 4K di veicoli/oggetti piccoli a 1K/2K. Ridurre roughness/metallic/AO può essere meno visibile della riduzione dell'albedo. Conservare originali, UV e leggibilità di scritte/display; cambiare soltanto PNG/JPEG o qualità di compressione su disco non assicura un risparmio VRAM.

Oggetti ripetuti: 468 istanze mesh hanno già un datablock con più utenti. Non convertire ciecamente tutto in copie collegate: condividere solo oggetti realmente identici. Riutilizzare materiali equivalenti; raggruppare piccoli dettagli statici per stanza e materiale soltanto dopo avere misurato le chiamate di disegno. Non unire l'intero edificio: peggiorerebbe la possibilità di escludere stanze/parti non visibili e romperebbe i collegamenti ai nodi interattivi.

## Interventi Godot successivi da misurare

Occlusion culling per pareti solide/stanze, distanza di visibilità degli oggetti decorativi e LOD effettivi; controllare beneficio e sparizioni alle porte/camere cinematiche. Confrontare ombre delle numerose luci locali e fumo/trasparenze; non cambiare l'atmosfera approvata senza confronto visivo. Non eliminare collider, gruppi superficie o metadati per risolvere un problema di rendering.

Per caricare meno memoria fin dall'avvio servono asset importati più leggeri o una suddivisione delle dipendenze caricate. LOD e occlusione possono ridurre il lavoro di rendering ma non eliminano automaticamente il costo di caricamento di tutti gli asset della scena.

## Strumenti, verifiche e limiti

`tools/blender/audit_connesi_readonly.py` legge il blend, inventaria mesh/modificatori/immagini e scrive soltanto `.godot/connesi_blender_audit.json`; non salva il blend. Lettura completata e Blender chiuso. Dimensione e data ultima modifica del sorgente restano quelle precedenti all'analisi.

`scripts/tests/map_performance_probe.gd` carica player/mappa reali, isola lo slot in `.godot`, non salva opzioni e misura caricamento, istanziazione, ready, frame iniziali, fermo, due rotazioni, pausa, ombre disattivate, scala rendering 0.5 e rendering 3D disattivato. Le variazioni diagnostiche esistono soltanto nel processo di prova. Report `.godot/map_performance_report.json`; log della ripetizione `.godot/performance_gpu_retry.log`.

Prima prova headless: picchi iniziali fino a 2,8 s, poi frame regolari senza rendering; inventario finale interrotto da chiamata ArrayMesh su BoxMesh, corretta limitando l'inventario alle ArrayMesh. Processo bloccato su errore terminato esplicitamente.

Prima prova GPU parziale: risorse 53,76 s, istanziazione 0,327 s, ready 5,607 s; fermo media 10,22 ms, prima rotazione media 24,24 ms/p95 54,77 ms/max 137,55 ms, 41/360 frame oltre50ms, massimo 13.382 draw call. Condizioni non pulite: processo headless rimasto attivo e interruzione utente; non usare questi risultati come benchmark definitivo. I primitivi contati includono passaggi di rendering, non sono triangoli unici della scena. I monitor process/physics non sono misure per-frame sincronizzate: usare tempi frame e profiling dedicato per conclusioni CPU.

Ripetizione GPU completata, dopo la chiusura di headless e Blender, RTX4060/Forward+/D3D12, 1920×1080, render scale1.0, VSync disattivato e limite FPS0 soltanto nel processo; editor utente rimasto aperto. Caricamento risorse59,306s, istanziazione0,603s, ready5,668s. Test sintetico, non benchmark della partita completa né misura a cache fredda controllata.

| Fase | Media frame ms | p95 ms | Frame oltre50ms |
|---|---:|---:|---:|
| Fermo (240 frame) | 24,36 | 47,12 | 1 |
| Prima rotazione (360 frame) | 29,68 | 61,59 | 55 |
| Seconda rotazione (360 frame) | 29,67 | 61,95 | 56 |
| Rotazione in pausa (360 frame) | 28,29 | 59,00 | 49 |
| Rotazione senza ombre (360 frame) | 20,83 | 49,17 | 13 |
| Rotazione render scale0.5 (360 frame) | 22,09 | 52,49 | 34 |
| Senza rendering3D, fermo (240 frame) | 5,38 | 27,26 | 0 |

17 luci con ombre; massimo draw call nella rotazione6.868, senza ombre2.151. Disattivare ombre comporta anche un picco di transizione319,7ms incluso nella media. Non è proposta di eliminare tutte le ombre: il confronto indica di selezionare luci/distanze/caster da ottimizzare. Pausa poco efficace e scatti ripetuti nella seconda rotazione indicano lavoro continuativo di rendering, non esclusivamente caricamento iniziale degli shader. Risoluzione ridotta aiuta ma lascia scatti, dunque non basta come soluzione.

Allocazioni riportate dal motore: texture3.663,98MiB (~3,58GiB), video complessivo6.138,23MiB (~5,99GiB). Sono contatori del motore, non prova di saturazione VRAM o paginazione. Picco frame iniziale3,73s: preparazioni differite/prewarm restano un secondo problema da profilare separatamente.

Inventario runtime segnala anche testa Angelastri circa2,02milioni di triangoli e testa di confronto nascosta che riferisce la mesh originale. Non confondere istanze nascoste con triangoli renderizzati o risorse necessariamente duplicate. Analisi/ottimizzazione di questo modello richiede audit separato dall'edificio. Nessuna modifica applicata.

Nessuna ottimizzazione applicata: il risultato di questa fase è una diagnosi con priorità verificabili. Prossimo passo: una copia con un singolo asset ottimizzato e confronto prima/dopo, con regressione passaggi/interazioni e playtest utente.

Riferimenti: [Decimate Blender](https://docs.blender.org/manual/en/5.2/modeling/modifiers/generate/decimate.html), [ottimizzazione 3D Godot](https://docs.godotengine.org/en/4.4/tutorials/performance/optimizing_3d_performance.html), [demo ufficiale occlusion/LOD](https://github.com/godotengine/godot-demo-projects/tree/master/3d/occlusion_culling_mesh_lod).
