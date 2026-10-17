# Connesi14 reimportato — benchmark e continuità

12/10/2026, dopo conferma utente di fine importazione. Utente approva la resa della prova texture («rende bene lo stesso»), ma la verifica del GLB attivo dimostra che contiene ancora risoluzioni originali per le immagini controllate. Non confondere approvazione della copia Blender con applicazione nel gioco.

## Stato verificato

GLB `assets/models/environment/connesi_building_test2.glb`:1.876.509.872byte, LastWriteTime16:28:14. Import `.godot/imported/connesi_building_test2.glb-fa320ef5f50fe16a82e4ea4e85742058.scn`:190.270.200byte/16:36:31, metadataMD5aggiornati16:36:47. Prima era257.618.712byte: −26,14%. Atteso completamento import esplicitamente prima di avviare il test.

Sorgente `Assets_Source/connesi14.blend` ora2.009.144.942byte/16:30:18; la copia texture precedente è del00:26. Non esportare automaticamente quella copia vecchia per evitare di perdere il lavoro successivo dell'utente. Un'applicazione delle texture deve partire dal sorgente più recente.

## Benchmark GPU

Harness invariato `scripts/tests/map_performance_probe.gd`, RTX4060/Forward+/D3D12,1920×1080,render scale1.0,vsyncoff/fpslimit0 solamente nel processo. Una sola istanza Godot nel nuovo test; precedente benchmark11/10con editor aperto. Confronto sintetico indicativo, non A/Bcontrollato: cache, carico PC e altre condizioni possono influire. Non attribuire tutto il guadagno automaticamente alla sola riduzione mesh.

| Misura | Prima | Reimport14 |
|---|---:|---:|
| Caricamento risorse | 59,306s | 49,157s |
| Istanziazione | 0,603s | 0,256s |
| Ready | 5,668s | 6,267s |
| Frame medio fermo | 24,36ms | 12,19ms |
| Prima rotazione, media/p95 | 29,68/61,59ms | 10,05/13,53ms |
| Seconda rotazione, media/p95 | 29,67/61,95ms | 9,97/13,37ms |
| Seconda rotazione, frameoltre50ms | 56/360 | 0/360 |
| Rotazione in pausa | 28,29ms | 7,33ms |
| Rotazione senza ombre | 20,83ms | 7,79ms |
| Rotazione scale0.5 | 22,09ms | 9,70ms |
| Risorse texture dal motore | 3.663,98MiB | 3.598,21MiB |
| Risorse video complessive dal motore | 6.138,23MiB | 5.832,33MiB |

Primi frame: ancora un picco4,24s, quindi preparazione differita/prewarm e caricamento restano problemi aperti. Frame oltre50ms assenti nelle fasi stabili misurate, non garanzia di assenza scatti in tutta la partita. Rendering con ombre beneficia ancora di ottimizzazione selettiva, ma ridurre la risoluzione nel nuovo test aiuta poco. Contatori memoria motore non sono una misura diretta di saturazione VRAM.

Report precedente conservato `.godot/map_performance_before_connesi14.json`; nuovo `.godot/map_performance_report.json`, log `.godot/performance_connesi14.log`.

## Texture ancora originali nel GLB

Lettura in sola lettura dell'headerJSON e dei PNGincorporati (dimensioni daheaderPNG): `paved`8192×8192, `Back_door_normal`4096×4096, `Body_exterior_1_normal`4096×4096, mappe metallic/roughness dei due set4096×4096, `Cardboard_boxes_1_BaseColor`4096×4096. Albedo/car03incorporati JPEG, dimensioni non decodificate in questo controllo. Basta il confronto dei PNGverificati per stabilire che la selezione26texture ridotte non è presente integralmente nell'export attuale. Non dedurre risoluzioni JPEG non misurate.

## Riparazione mirata del collider rack

Nuovi due avvisi parentvanished: parent del collider era `Electronics_Networking_Tripp-Lite_45U-SmartRack-4-Post-Open-Frame-Rack-100`, ora rinominato `Rack Regia`. La mesh figlia `L_1a8b6df6_73d4_4ad3_8f47_3b570b4ecf40_I2` esiste nel GLB, non è stata rimossa. Prima della modifica map_test era uguale a HEAD; letti blocchi nodo/collider/risorsaBox e verificato il parent reale nel GLB.

Modificati soltanto i due path parent in `scenes/maps/map_test.tscn`; rimosso il vecchio parent_id_path del body per usare il percorso esplicito corrente. BoxShape3D_wcoao, transform, UUIDnodi e geometria conservati. Nessuna modifica AI/player/arme/cinematiche o agli asset esportati. Diff2righe cambiate; baselineGitidentificata3b685e42.

Scorrevoli: `sliding_passage_test.gd` passa failures0 nelle due direzioni con colliderplayer reale, prima della riparazione rack. Dopo la riparazione: `bruno_passage_test.gd` passa failures0, fineZ15,08, colliderparete e bocca verificati; avvisi parentrack spariti. Log `.godot/sliding_connesi14.log`, `.godot/bruno_connesi14.log`. AvvisoSparksElectric lampione già storico; headless segnala certificate store, ma test completati. Non equivalgono a playtest completo combat/PC/save/contatori.

Nessun commit/push. Prossimo: playtest utente dei nuovi sportelli/rack/porte e prestazioni durante combat; applicare le texture ridotte alla versione Blender più recente in una copia separata, poi esportare/importare e misurare nuovamente.
