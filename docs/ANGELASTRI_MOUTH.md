# Angelastri — bocca e denti

**Chiusura 11/10/2026:** utente conferma V2 «ok perfetta». Le richieste di conferma e i conteggi 24/26 sotto sono storici: la scena salvata successivamente contiene 27 clip mie, 29 totali. Non tutte sono state provate visivamente. Prossimo lavoro autorizzato: [preview modello/animazioni, poi cinematiche e combattimento](ANGELASTRI_IMPLEMENTATION_PLAN.md). Il test con conteggio fisso 26 va aggiornato nella fase 1; voce Bruno ancora provvisoria nella preview.

**Rifinitura attiva V2 — 11/10/2026:** dopo «molto carino», utente richiede denti superiori meno esposti e più separati dall'arcata inferiore. Rialzata solo l'arcata superiore di 1.2 mm; variante in `mouth_preview_v2`, componente aggiornato, prima versione conservata. Apertura, texture, denti inferiori e animazioni invariati. Nuova resa approvata «ok perfetta».

Implementazione locale 11/10/2026, richiesta dell'utente dopo approvazione scorrevoli/audio regia. Fonte ufficiale `assets/models/enemies/Angelastri/sgt_Angelastri.glb`; scena reale `scenes/enemies/angelastri.tscn` (il nome sngelastri indicato in chat non corrisponde a un file presente).

## Prova F6

F8 → aprire `scenes/levels/angelastri_mouth_test.tscn` → F6.

- **M:** apertura manuale; slider da 0 a 1, valore iniziale 0.72.
- **3 / 4:** forma arrotondata / sorriso, visibili in modalità manuale.
- **1 / 2:** frontale / tre quarti.
- **O:** confronto con testa originale.
- **Spazio:** avvia/ferma voce provvisoria per test RMS. È `dialogoBruno2_p1.mp3`, non la voce di Angelastri; resta esclusa dalla scena nemico e non viene copiata.
- Menu animazioni: Corpo fermo oppure una delle 24 animazioni `mie/` già presenti. Test automatico usa idle e talk_to_combat, non prova integralmente ogni clip.

Prova visuale utente ancora aperta: controllare labbra, denti nascosti a riposo, angoli, forma O e sorriso con voce/corpo in movimento. Resta da assegnare in seguito la vera voce e progettare gameplay/cinematica di Angelastri, con nuovo obiettivo dell'utente.

## Geometria e preservazione

Testa originale `sgt_Angelastri/Armature/GeneralSkeleton/mixamorig_Neck/Testa`, rigida sotto il BoneAttachment del collo, senza skin o shape/jaw bone. Corpo skinnato separato, scheletro con Head/Neck e 26 clip disponibili (24 nella libreria mie). Parent del collo conservato: nessun cambio del rig o retargeting.

Testa molto densa: 1.076.121 vertici e 2.016.606 triangoli. Generatore `tools/blender/build_angelastri_mouth.py` mantiene la geometria di base, UV e normali mediante array Blender; taglia solo 444 triangoli attraversati dal contatto labiale. Variante 1.085.631 vertici / 2.019.332 triangoli, incremento di 2.726 triangoli. Nessuna decimazione di cappello/barba/volto.

Taglio calibrato sul render ortografico originale, cinque ancore X [-0.033,-0.019,0,0.019,0.033], Z [-0.0475,-0.0498,-0.0505,-0.049,-0.0468] in metri locali Blender. Movimento inferiore localizzato, rotazione massima 0.10 rad intorno a (0,0.015,-0.028); delta massimo 0.0130845 m a shape completa. Apertura sfuma agli angoli X 0.025–0.035 e sul collo/frontale. Occhi, naso e cappello non sono deformati.

Tre shape: mouth_open, mouth_round, mouth_smile. Cavità ripiegata scura e due arcate continue con UV 0–1, sei separazioni grigie nella texture già approvata di Bruno V6, incorporata nel nuovo GLB. Denti superiori circa 3 mm/inferiori 2 mm oltre il taglio; angoli arretrati fino a 5 mm aggiuntivi per evitare bianco a bocca chiusa. Nessun quadratino separato. Materiale esterno originale ripristinato sul runtime; cavità scura unshaded, terza superficie denti con materiale incorporato. Normali del morph non esportate, normali della base conservate.

Nuovo asset head-only `assets/models/enemies/Angelastri/mouth_preview/angelastri_head_mouth.glb` e sorgente `.blend`. GLB ufficiale invariato, SHA256 C07CED1702FFC506D69048954EE5AA30D0D6255884A1AEA6F98CBCA706994B69. Sorgente Blender e tool sotto tools sono ignorati dal Git: conservare un backup esplicito se si trasferisce il progetto.

## Collegamento alla scena ufficiale

`angelastri.tscn` aggiunge solo ext_resource e nodo `MouthPresentation` con `scripts/characters/angelastri_mouth.gd`; libreria animazioni, bone pose, UID e nodi originali conservati. Copia precedente in `.godot/angelastri_before_mouth.tscn` per confronto, non backup esterno.

Alla ready differita carica il GLB della testa (circa 91 MB, corpo escluso) tramite GLTFDocument e sostituisce soltanto la mesh Testa mantenendo transform/parent/materiale. Senza voce resta a bocca chiusa e non crea bus audio. Espone `voice` per assegnare un AudioStreamPlayer/3D e `bind_voice(player)` per collegarlo più tardi; `set_expression(opening, rounded, smile)` controlla le tre shape manualmente, quando il controller audio non le pilota.

Riuso del controller BrunoMouthMotion esistente, senza modificarlo: RMS, soglia/guadagno/attacco/rilascio, round/smile stilizzati e chiusura su stop/pausa, bus capture privato ripristinato all'uscita. Non riconosce fonemi. Nessuna voce di Bruno o riferimento ai controller boss/intro nella scena nemico.

## Verifiche

Blender 5.2.1: confronto frontale/tre quarti originale, chiuso/aperto. Corrette durante iterazione shape inizialmente a valore 1, taglio troppo largo ai lati e denti che sporgevano agli angoli: valori iniziali finali zero, taglio ristretto, recessione laterale aggiunta.

Godot 4.7.2 Forward+ D3D12 RTX4060: `ANGELASTRI_MOUTH_TEST failures=0`, picco apertura 0.603476 sul dialogo umano provvisorio. Tre superfici/shape, texture denti, transform e materiale originale, confronto O, manuale/round/smile, lista 26 animazioni, audio reale/stop/pausa voce/pausa albero e rimozione bus verificati. Screenshot angelastri_closed_front/open_front/open_quarter/round/smile in `.godot` ispezionati. Log `.godot/angelastri_mouth_test.log`.

GLB ufficiale, mappa e controller Bruno preservati. Nessuna AI, collisione nemico, combattimento, drop, voce ufficiale, integrazione nella mappa o export introdotti in questo lavoro. Nessuno staging/commit/push. Gradimento finale utente aperto.

Ripetizione headless finale: `ANGELASTRI_MOUTH_TEST failures=0`, picco 0.618523; verifica aggiuntiva della scena ufficiale senza voce, bocca chiusa e nessun bus capture. Log `.godot/angelastri_mouth_headless_test.log`. Fixture headless corretta per attendere l'aggiornamento delle shape anche senza screenshot.
