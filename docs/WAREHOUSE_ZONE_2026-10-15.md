# Nuova zona dopo la porta aliena — 15/10/2026

## Porta segreta, retro e accesso Assistenza Tecnica — 23/10/2026

Il foro della porta segreta era già presente nella mesh nuova, ma il collider concavo storico lo chiudeva: rigenerata soltanto la shape del tetto in `resources/collisions/warehouse_secret_roof.tres` (44triangoli), senza cambiare il visuale. Le scatole Yealink utente davanti alla014 bloccano il percorso centrale del test; posizione degli arredi conservata.

Due configurazioni aggiunte ai12battenti esistenti: `WarehouseDoors/PortaSegreta` (mesh `Porta Segreta/Porta_100`, libera,+90°/+Z) e `PortaRetroDX` (gruppo `Porta Retro Dx`,−90°/−X, chiave rear_key). Retro è un'anta a12mesh:6parti strutturali/vetro formano il collider unico,6maniglie/serratura seguono il gruppo; la metàSx non viene modificata. Segreta usa la protezione al contatto delle porte strette. Nessun pickup shotgun o chiave retro collocato in questa fase.

Porta Assistenza00 era già collegata a `AssistanceMainDoor / assistance_key`: preservati ID e meccanica. Il boss Broccolo ora lascia a terra questa chiave alla morte del principale, con IDpickup main.broccolo.assistance_key, modello originale Bruno e copia privata della targhetta blu. Collected/posizione sono persistenti, nessuna assegnazione automatica all'inventario; ripristini ripetuti non duplicano e vecchi checkpoint già sconfitti ricevono il drop fisico al marker. [Parametri Inspector](INSPECTOR_CONFIGURATION.md).

## Luci boss e neon a sensore — 22/10/2026

Durante Broccolo solo i circuiti `Luci Corridoio Magazzino` (6Omni) e `Luci Lampadario Magazzino` (2Spot), con14materiali emissivi, ricevono tinta viola; alla fine ritornano ai colori precedenti. Collegamenti/ID/interruttori, energia e stato acceso/spento sono conservati. Non vengono aggiunti blackout: la sequenza precedente resta invariata; spegnere manualmente il contatore toglie corrente anche ai neon nuovi.

Le mesh importate `connesi_building_test2/NeonMagazzino`, `_001`, `_002` hanno tre componenti in `NeonMagazzinoSensors/Neon01–03`, ciascuno con una Omni `Light`. Sensore di presenza orizzontale2,2m, isteresi0,5m e ritardo off0,6s; controlla dislivello e visibilità contro muri/porte. Si alimentano dalla corrente aziendale, indipendentemente dai due interruttori esistenti. Nessuno stato persistente nuovo: al caricamento ricalcolano la presenza. Materiali duplicati in memoria per emissione del tubo e shading reale quando spento; GLB e texture originali preservati. [Tuning e duplicazione](INSPECTOR_CONFIGURATION.md).

## Configurazione dall'Inspector — 17/10

La precedente tabella CONFIG nel factory e' stata migrata nei12figli di WarehouseDoors nella scena, con stessi ID, nomi runtime, sorgenti, cardini e valori. Selezionare un figlio per modificare la singola porta; selezionare il genitore per il lettore fingerprint. La direzione di sicurezza viene ricavata automaticamente dal segno dell'angolo e dal cardine. Niente modifiche al codice per regolare apertura/serratura/audio. I controller fisici continuano a essere creati soltanto in gioco, conservando pose/materiali e telai fissi.

Gruppi e descrizioni italiane `##` aggiunti anche agli interruttori e alla porta base. Standard permanente richiesto dall'utente in AGENTS e PROJECT_BLOB_STANDARDS, con [guida pratica](INSPECTOR_CONFIGURATION.md). Test round-trip di una configurazione, valori non predefiniti, warning duplicati, fingerprint con timer/colori modificati e lettore indipendente dall'ordine passati. Auto Close resta false per tutte le porte correnti; quando attivato dall'Inspector riprova una chiusura rimandata dal passaggio occupato, verificato in fixture.

Suite mappa12porte passata failures=0 con ID e direzioni storici, ray/E/outline, chiavi/CED, restore e passaggio reale in entrambe le direzioni; fixture6switch/12luci passata. Verifica Engine.is_editor_hint=true su scena piccola conferma nessuna costruzione fisica/riparentazione e avvisi aggiornati correggendo un valore. Non e' un nuovo playtest manuale/GPU della mappa. Backup in local_optimization/inspector_configuration_20261017; scena128righe aggiunte/1sostituita, soltanto collegamento lettore e configurazioni. Nessun asset o transform visivo modificato, nessun commit/push.

## Ingresso magazzino e lampadine lampadari — 17/10

Nuovo gruppo importato `Luce Tonda_006` in posizione(6,992199;2,325993;1,891911), due superfici emissive centro/corpo. Il nuovo `Interruttore Luce Ingresso Magazzino` era copia del comando lampadari con medesimo persistent_id e lights_root: corretti a `main.lights.warehouse_entrance` e `../Luce Ingresso Magazzino`, etichetta dedicata, gruppo006 tra gli emissive_visual_roots. Non esisteva una Light3D dedicata: aggiunta Omni0,8 come gli altri punti luce, a(6,992199;2,266993;1,891911), leggermente sotto la plafoniera montata a soffitto. Nuovo circuito indipendente e persistente,6switch/12luci totali.

Lampadario e Lampadario_001 avevano già materiale Scene_-_Root con energia emissiva2,785167, ma la texture esterna estratta usata da Godot `...Image_2_42.png` era completamente nera. La PNG incorporata nel GLB contiene invece la maschera bianca della lampadina. Estratti gli stessi byte in `assets/textures/warehouse/chandelier_emission.png` (1024²,2937byte) e importati; immagine esterna nera e GLB non modificati. Esame visivo di entrambe conferma la differenza. Il comando lampadari ora seleziona le due mesh e imposta `emission_texture_override`: nuovo export opzionale di zone_light_switch, applicato alle sole copie locali dei materiali. Le altre texture/colore/energia restano originali. Maschera limita il bagliore alla lampadina; Spotlight restano quelli utente.

Verifiche passate: fixture vera12luci/6switch con indipendenza, input/E/click, blackout e snapshot/recreate; suite mappa vera18materiali (12corridoio,2ingresso,2lampadari,2specchi), ID distinti, maschera con pixel chiaro lampadina/nero altrove, off/on/restore/blackout, originali intatti, porte038 regressione. Render GPU D3D12/RTX4060 sulla mesh vera in fixture con materiale locale corretto: immagini chandelier_off/on sotto.godot ispezionate, pixel bianchi159→8873, lampadina luminosa e paralume conservato. Non è un nuovo playtest integrale della mappa. Nessuno slot utente scritto.

Backup scena/controller precedenti in `local_optimization/warehouse_entrance_20261017`. Diff scena11aggiunte/3rimozioni; nuove sole configurazioni eOmni, transform interruttori e altre luci invariati. Log warehouse_entrance_lights/warehouse_entrance_emission/chandelier_render_check sotto.godot. Import headless della PNG concluso, successivo caricamento layout editor interrotto per evitare una seconda mappa pesante; errori di import dei file macOS._zombie.wav preesistenti. Nessun commit/push. Riavviare scena e provare ingresso/lampadari separatamente.

## Correzione successiva 17/10 — anche i lati delle Luce Tonda

Utente conferma centro spento ma segnala lati ancora emissivi. Il materiale `01_black_metall` dei sei `body_002_01_black_metall_0` ha anch'esso emissione0,5. Estesi i sei riferimenti del circuito ai gruppi Luce Tonda interi: il controller ricorsivo già esistente prepara così copie locali sia dei centri sia dei corpi laterali. Nessuna modifica allo script runtime o agli asset. Totale12materiali corridoio +2specchi bagno; accesi mantengono intensità/colori originali, spenti/blackout/restore disattivano l'emissione di tutte le parti. Questa correzione supera la precedente limitazione ai soli centri.

Scena modificata su una sola riga; backup `local_optimization/warehouse_emission_20261017/map_before_housings.tscn`. Test mappa esteso a12materiali corridoio e verifica ricorsiva di tutte le superfici emissive dei gruppi, incluse preservazione originali/texture. Porte, luci reali e circuiti invariati.

Test finale sulla mappa reale passato failures=0 per tutte14superfici, off/on/restore/blackout e conservazione originali. Log warehouse_emission_housings sotto.godot; nessuno slot utente scritto. Resta solo riscontro visivo dopo riavvio scena.

## Rifinitura 17/10 — verso038 ed emissione lampade

Utente conferma funzionamento della zona, ma richiede038 verso il giocatore perché nell'altro verso urta gli scaffali. Questa richiesta supera il verso scelto nella voce precedente: ora −90°/+X, verso le scale. Pivot, geometria, telaio, ID persistente e controller restano uguali.

Utente specifica le sei `light_003_03_light_0` e varianti dentro Luce Tonda. La loro emissione è ora comandata dallo stesso interruttore delle6Omni corridoio. Le due superfici specchio emissive sono `Luce Bagno` (DX, materiale mirror_light) e `LuceBagno1` (SX, mirror_light); i pezzi metal separati non richiedono controllo emissivo. Collegamenti espliciti in `zone_light_switch.emissive_visual_roots` per i tre circuiti; nessuna modifica ai lampadari o ai carter delle Luce Tonda.

Il controller duplica in RAM soltanto i BaseMaterial3D emissivi delle mesh selezionate, mantenendo texture condivise, albedo, intensità e colore originali. Usa override locali per superficie (o material_override locale se presente); gli asset importati e gli altri utilizzatori dei materiali rimangono intatti. `_set_lights` sincronizza visibilità Light3D ed emission_enabled, quindi anche avvio spento, blackout e restore silenzioso. Scena: soltanto3proprietà export aggiunte agli interruttori, nessun transform/materiale serializzato modificato. Backup in `local_optimization/warehouse_emission_20261017`.

Suite nuova `warehouse_emission_map_test.gd` headless sulla mappa vera passata failures=0:8materiali privati, originali ancora emissivi e inalterati, texture/albedo/normal/emission e colore/intensità preservati, circuiti indipendenti, off/on/restore silenzioso/blackout/ritorno corrente,038 nel verso richiesto, apertura/chiusura/telai fermi e passaggio con capsula reale nei due sensi. Regressione fixture luci passata11luci/5switch; fixture esclude soltanto i nuovi riferimenti ai modelli, verificati invece dalla suite mappa. Log warehouse_emission_map e warehouse_emission_lights_regression sotto.godot. Nessuno slot utente scritto; non è verifica visiva GPU o nuovo playtest utente. Riavviare la scena per applicare i nuovi collegamenti.

## Aggiornamento 17/10 — altre luci e quattro porte grigliate

Utente aggiunge luci ai gruppi esistenti e richiede Porta_013/014/015 del magazzino verso l'interno e Porta_038 sopra le scale. Nessuna modifica alla scena corrente o alle impostazioni delle luci: il controllo ricorsivo già presente copre ora6Omni nel corridoio,2Spot lampadari e3Spot bagni,11luci totali/5interruttori. Test fixture reale passato con on/off, circuiti indipendenti, blackout, restore silenzioso, transform ed energie conservati. Generatore fixture esteso ai discendenti annidati e conteggio finale dinamico, prima stampava7 fissi pur verificando tutte le luci.

`warehouse_doors_integration.gd` esteso con quattro configurazioni libere, senza chiave. Originali8ID e regole CED invariati; telai fermi, griglie/maniglie figlie dell'anta seguono il movimento. Ante013–015: larghezza0,799998m, pivotX massimo e apertura+90°/+Z dal corridoio verso l'interno. Porta038: sogliaY2,440907m, pivotZ massimo, +90°/−X verso pianerottolo; scala Cube_030 si trova a+X del battente, dunque non apre sui gradini.

| Percorso sotto connesi_building_test2 | Nodo runtime / ID finale |
|---|---|
| Porta Magazzino 01/Porta_013 | WarehouseGrid013 |
| Porta Magazzino 01_001/Porta_014 | WarehouseGrid014 |
| Porta Magazzino 01_002/Porta_015 | WarehouseGrid015 |
| Porta Magazzino 01_003/Porta_038 | WarehouseStairs038 |

ID persistenti `main.door.warehouse.<nome runtime>`. Piccola correzione nel solo controller warehouse: l'arretramento controlla anche il piano verticale, così la038 non sposta un giocatore al piano inferiore con X/Z simili. Suite `warehouse_door_height_test.gd` passata sia per esclusione del piano sotto sia per protezione/ritorno fisica allo stesso piano. Suite mappa `warehouse_doors_test.gd` aggiornata a12porte e quota corretta della038: failures=0, passaggio reale chiuso/aperto in entrambe le direzioni, ray/outline, E sul primo battente, serrature e CED, persistenza silenziosa. Nessuno slot utente scritto. Non è un playtest manuale/GPU delle nuove porte.

Backup scena e configurazione precedenti in `local_optimization/warehouse_zone_20261017` con.gdignore; confronto scena prima/dopo identico, configurazione soltanto4righe aggiunte. Log sotto.godot `warehouse_doors_20261017`, `warehouse_lights_20261017`, `warehouse_height_20261017`. Avvisi certificati/sparks lampione preesistenti; fixture luci/altezza segnalano2ObjectDB/1risorsa al teardown come audio menu storico. Nessun commit/push. Riavviare la scena per costruire i nuovi controller.

Utente conferma reimportazione GLB con nuovi elementi/materiali, luci e interruttori di magazzino/bagni. Obiettivo per gradi: luci e porte, poi CED chiuso con fingerprint legato a un enigma futuro, infine boss nel corridoio davanti al magazzino che lascia un indizio. Luci e F4 confermati dall'utente; aggiunto successivamente il collegamento delle otto porte elencate sotto. Boss, posizioni chiavi e acquisizione impronta restano fasi future.

## Primo intervento: cinque interruttori

| Interruttore root in map_test | Luci comandate | ID persistente |
|---|---|---|
| Interruttore Luce Corridoio Magazzino | Luci Corridoio Magazzino,3Omni | main.lights.warehouse_corridor |
| Interruttore Luce Lampadario Magazzino | Luci Lampadario Magazzino,1Spot | main.lights.warehouse_chandelier |
| Interruttore Luce Antibagno | Luce AntiBagno | main.lights.anteroom |
| Interruttore Luce Bagno DX | Luce Bagno DX | main.lights.bath_right |
| Interruttore Luce Bagno SX | Luce Bagno SX | main.lights.bath_left |

Le5MeshInstance3D già posizionate ricevono scripts/interactables/zone_light_switch.gd, subclass di interruttore.gd invariato. Riusa E/prompt/outline bianco e click3D SFX già esistente; aggiunge body layer2 dimensionato sull'AABB originale (piastra12,688cm, tolleranza12mm), senza duplicare la mesh o cambiarne transform/materiale. Supporta sia gruppo di luci sia Light3D singola; nessuna riparentazione dei nodi. Collegate a ConnesiPower: inizialmente spente, interazione senza corrente non accende, blackout spegne e azzera gli interruttori; ritorno corrente richiede riaccensione come gli interruttori esistenti. Nessun cambio energia/colore/cono/ombre/range/materiali impostati dall'utente.

Stato indipendente persistente tramite SaveManager esistente; registrazione differita dopo RegiaMapIntegration/start_new_game, restorepriority20 dopo corrente−10. Restore silenzioso e accensione subordinata alla corrente; checkpoint senza questiID rimangono con luci spente. Nessuna modifica SaveManager, interruttore condiviso, controller porte o boss.

Backup completo prepatch map_test in local_optimization/warehouse_zone_20261015/map_before_lights.tscn con.gdignore. Mappa già molto diversa da HEAD prima dell'intervento; diff storico preservato, aggiunti soltanto ext_resource del componente e proprietà delle5mesh.

## Verifica e prova

`scripts/tests/warehouse_lights_test.gd` estrae dalla mappa vera i5interruttori/7luci/ConnesiPower e solo le risorse effettivamente necessarie in.godot/warehouse_lights_fixture.tscn, evitando di caricare edificio/boss multiGB. Runtime headless finale passa failures=0: collegamenti corretti, Inputinteract attraverso InteractionSystem e RayCast reale, tutti5i collider colpiti con mask2, circuiti indipendenti, click, prompt/outline, corrente/blackout, snapshot e ricostruzione dei nodi reali con restore silenzioso, transform/energia immutati e unregisterID. Nessuno slot utente letto o scritto; stato salvato solo nella memoria del processo di test.

Prime esecuzioni rilevano difetti del generatorefixture(uid letto come id) e castself GDScript, corretti. TestE inizialmente chiamava manualmente process nel frame sbagliato, corretto usando il processo/Input reale; finale passato. Chiusura esplicita audio3D evita7playbackWAV pendenti; restano2ObjectDB/1risorsa dell'audio menu MP3 autoload al teardown, distinto dagli interruttori. Warning certificati Windows storico. Log warehouse_lights_final e verbose sotto.godot.

Questa prova isolata non certifica accessibilità nella mappa completa o resa luminosa GPU. Manuale F6 map_test (o checkpoint compatibile): corrente attiva, E sui5interruttori, verificare ogni ambiente separatamente, click, contatoreOFF/ON e salvataggio/caricamento. Porte/ostacoli attuali possono limitare accesso: saranno il prossimo intervento. Il controllore della zona non apre alcuna porta.

## Accesso temporaneo F4 per test

L'utente conferma le luci funzionanti in gioco. In `map_test`, F4 prima dell'incontro con Angelastri sblocca/apre l'uscita aliena tramite il controller esistente e sospende l'evento del boss nella sessione corrente. Non assegna vittorie, oggetti o completamenti. Solo build debug; pausa, caricamento, morte e sequenza/combat già in corso impediscono l'attivazione. Componente isolato `scripts/debug/warehouse_test_access.gd`, nodo `WarehouseTestAccess`.

Dopo F4 i salvataggi sono bloccati tramite il contratto `blocks_saving` di SaveManager: il checkpoint prima di Angelastri rimane intatto. Ricaricare il checkpoint o riavviare la partita elimina il bypass. Nessun cambio ai controller condivisi di porte, puzzle o boss. Test runtime headless della mappa reale `warehouse_test_access_test.gd` passato: apertura, sospensione evento, inventario/progressione boss invariati, registrazione e blocco salvataggio, ripetizione F4 senza effetti aggiuntivi. Nessuno slot utente scritto; non equivale a playtest manuale dal checkpoint.

Porte indicate dall'utente: Antibagno, BagnoDX, BagnoSX e PortoneAssistenzaInterno libere; Switch, AssistenzaPrincipale e Produzione con **tre chiavi diverse**; CED con fingerprint (blu a riposo, rosso errato, verde corretto, sblocco 10 secondi). Dopo F4 è stato completato il collegamento descritto sotto; posizioni delle chiavi e acquisizione dell'impronta non definite.

## Otto porte e lettore CED

`WarehouseDoors` in map_test usa `scripts/systems/warehouse_doors_integration.gd`. Crea i battenti a runtime partendo dalle mesh vere, conservando transform globali, materiali, gruppi, vetri e maniglie; telai fermi. Per CED muove tutto il gruppo Porta DC (maniglie sorelle del pannello Porta_092). Disattiva soltanto eventuali collisioni dei visual mobili e crea AnimatableBody3D layer3 con Box dal pannello, non dalle maniglie. Riusa outline/interact/E e audio porte esistenti senza cambiare controller condivisi. Backup scena precedente: `local_optimization/warehouse_zone_20261015/map_before_doors.tscn`; diff scena soltanto cinque righe aggiunte.

| Porta / nodo runtime | Cardine / apertura | Serratura |
|---|---|---|
| Antibagno / AnteroomDoor | DX, interno +X | Libera |
| BagnoDX / BathroomRightDoor | SX, interno +Z | Libera |
| BagnoSX / BathroomLeftDoor | DX, interno −Z | Libera |
| Switch / SwitchRoomDoor | DX, interno +X | switch_key |
| AssistenzaInterno / AssistanceInternalDoor | SX, interno +X | Libera |
| AssistenzaPrincipale / AssistanceMainDoor | DX, interno −Z | assistance_key |
| Produzione / ProductionDoor | DX, interno −X | production_key |
| CED / CEDDoor | SX, esterno +X | Fingerprint |

`warehouse_swing_door.gd` eredita door.gd, gestisce chiavi non consumate, prompt serratura, sblocco persistente, apertura/chiusura e ripristino silenzioso. ID `main.door.warehouse.<nome runtime>`. Blocca salvataggi durante movimento, non chiude sul player e controlla sovrapposizioni col giocatore al prossimo passo fisico. Dal lato verso cui apre richiede spazio e arretra dolcemente il player solo con sweep libero; altrimenti chiede di fare spazio. La capsula privata della sola mappa passa da raggio0,35 a0,32 tramite export RegiaIntegration già esistente: i due battenti bagni misurano0,697776m e prima il pannello aperto bloccava la capsula sul centro del vano. Altezza, camera, movimento e shape condivisa della scena player non modificati.

`warehouse_fingerprint.gd` interagisce con E sul lettore Plane_019, prompt SCANSIONA/USA IMPRONTA e piccolo LED aggiunto davanti alla superficie originale, senza sostituire texture/materiali. Blu a riposo, rosso1,5s se errata, verde10s se autorizzata. L'autorizzazione sblocca per10s senza aprire automaticamente: il player apre con E; se non apre torna bloccata. Una volta aperta resta aperta finché richiusa; alla chiusura serve una nuova scansione. L'autorizzazione temporanea non viene salvata. Credenziale `ced_fingerprint` e API `scan(authorized)` predisposte all'enigma futuro, nessun pickup o metodo di acquisizione inventato.

Tre risorse chiave e una credenziale in resources/items, registrate all'avvio InventoryManager affinché sopravvivano al restore precedente alla costruzione mappa. Le chiavi riusano l'icona esistente. Non sono assegnate da F4 e non sono ancora collocate nella mappa: le tre porte devono segnalare SERVE LA CHIAVE fino alla futura raccolta.

Verifica finale `scripts/tests/warehouse_doors_test.gd` headless sulla mappa vera: failures=0. Otto collider raggiungibili da ray mask2 e outline, prompt/input E attraverso InteractionSystem reale sul primo battente, chiuso bloccante e aperto attraversabile con capsula reale nelle due direzioni per tutte le otto porte, chiavi assente/errata/corretta, registrazione persistente e restore silenzioso, fingerprint errato/rosso, corretto/verde, scadenza10s e blu, apertura manuale e chiusura. Lo slot utente non è stato scritto. Regressione `inventory_save_test.gd` passata INVENTORY_SAVE_TESTS_OK con soli slot.godot. Non ripetute le suite complete Bruno/sliding né playtest GPU delle nuove porte: il nuovo raggio è una riduzione della capsula già in uso, ma gradimento e versi dalla visuale player restano da confermare. Avvisi certificati/sparks lampione preesistenti.

## Prossimi interventi, uno alla volta

1. Playtest utente delle otto porte: bordo/E, cardine e verso corretti; tre porte chiuse con chiavi distinte. Scegliere poi dove collocare le chiavi.
2. Definire l'enigma che fornisce l'impronta autorizzata CED; lettore e serratura predisposti, nessun accesso libero.
3. Boss nel corridoio davanti al magazzino e drop dell'indizio per l'enigma successivo, dopo approvazione di luci e porte.

Inventario preliminare storico da JSONGLB successivamente verificato nel runtime della mappa: Porta DC è il CED indicato dall'utente. Audit e test sotto.godot; nessun nuovo boss/drop/enigma, commit o push.
