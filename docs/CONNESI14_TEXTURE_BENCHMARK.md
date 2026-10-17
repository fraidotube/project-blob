# Connesi14: verifica delle texture nel GLB e benchmark

12/10/2026, dopo «fatto» dell'utente per nuovo export/import. Nessuna modifica a scene, script o impostazioni persistenti in questa fase.

## Import verificato

GLB 1.745.796.796 byte, LastWriteTime17:20:29, contro 1.876.509.872 prima delle texture (circa131MB meno). Import190.267.877byte/17:35:18, metadataMD5aggiornati17:35:30. Import completato prima del benchmark.

Dimensioni lette direttamente dagli headerPNGincorporati: `Back_door_normal.png.optimized`2048×2048, `Body_exterior_1_normal.png.optimized`2048×2048, `Cardboard_boxes_1_BaseColor.png.optimized`2048×2048, `paved.png.optimized`4096×4096. Questi campioni confermano che l'export contiene le riduzioni, mentre prima erano4K/8K.

## Risultati

Harness invariato `map_performance_probe.gd`, RTX4060/Forward+/D3D12,1920×1080,render scale1.0,VSync disattivato e fpslimit0 soltanto nella fixture. Vecchio confronto mesh14 senza editor; nuovo con editor aperto, il cui working set cresce da circa0,7 a3,2GB durante la prova. Confronto indicativo: caricoPC/cache/vista e stato di luci/effetti non sono controllati. Non usare i numeri per attribuire causalmente ogni differenza alle texture.

| Misura | Mesh14 prima delle texture | Texture ridotte |
|---|---:|---:|
| Risorse texture riportate dal motore | 3.598,21MiB | 3.366,89MiB |
| Risorse video complessive | 5.832,33MiB | 5.601,02MiB |
| Risorse, caricamento | 49,157s | 56,460s |
| Istanziazione | 0,256s | 0,340s |
| Ready | 6,267s | 6,450s |
| Prima rotazione, media/p95 | 10,05/13,53ms | 10,63/13,99ms |
| Seconda rotazione, media/p95 | 9,97/13,37ms | 10,46/13,91ms |
| Seconda rotazione, frameoltre50ms | 0/360 | 0/360 |
| Rotazione senza ombre | 7,79ms | 5,98ms |
| Rotazione scale0.5 | 9,70ms | 9,64ms |

Risparmio misurato texture231,31MiB (6,43%); sono contatori risorse del motore, non misura della memoriaGPUfisicamente residente. Fluidità delle rotazioni simile; nessun miglioramento FPS sostanziale dimostrato. Il caricamento non migliora in questa prova; non concludere che la riduzione abbia causato il rallentamento senza confronto controllato.

Primi frame ancora con picco3,33s e4frameoltre50ms; successivi campioni stabili senza frameoltre50ms. Il fermo cambia molto anche come drawcall/primitivi rispetto alla prova precedente: confronto FPSdafermo non utile per isolare l'effetto delle sole texture.

Nessun errore nuovo nel logGPU; solo avviso SparksElectric già storico. Meshinstances2714, maggiori mesh uguali alla prova precedente (Panda523.016, CasaVicina378.730, Officina303.801),17luci conombre. Nessun playtest esaustivo di combat/interazioni/salvataggi; geometria/UV/gerarchie preservate nella preparazione Blender e prove passaggi già documentate nella fase precedente.

Report prima `.godot/map_performance_mesh14_before_textures.json`; dopo `.godot/map_performance_textures14.json`; log `.godot/performance_connesi14_textures.log`. `map_performance_report.json` contiene l'ultimo risultato.

## Punto di ripresa

Ottimizzazione26texture presente nel GLBattivo e risparmio memoria confermato. Prossimo obiettivo performance: profilare separatamente caricamento risorse, ready e prewarm differito; benchmark con editor chiuso e percorso/camera controllati se serve confrontoFPSpreciso. Non applicate ulteriori riduzioni aggressive o eliminazioni di ombre. Backupconnesi14delle16:55conservato; nessuncommit/push.
