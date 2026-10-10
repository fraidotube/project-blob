# Inventario, chiave di Bruno e salvataggi ConnesiOS

**Passaggio di consegne 10/10/2026:** attraversamento della scorrevole confermato «perfetto ora funziona» dopo raggio player locale 0.35. Nuove immagini utente del comando Carica salvataggio, normale e blob, presenti in `assets/ui/caricasalvataggio.png` e `assets/ui/caricasalvataggio_blob.png`: collegamento UI da fare nella prossima sessione, preservando logica pulsanti/slot. Non dedurre conferma manuale di C/N/salvataggio/riavvio dalla sola conferma passaggio.

**Versione nella mappa, 10/10/2026:** ora collegati sui path scelti dall'utente: scorrevole laboratorio con chiave, scorrevole bagno senza chiave, battente regia, PC/monitor reale, loot Bruno e adattatori mondo. Test runtime/GPU nella mappa passati; [nota di integrazione e prova F6](REGIA_MAP_INTEGRATION.md). Demo e slot distinti preservati. Le sezioni di collegamento futuro sotto descrivono lo stato precedente; nuove modifiche/oggetti richiedono ancora collegamenti espliciti.

Implementazione locale del 10/10/2026, autorizzata con «Implement the plan». Primo collegamento nella scena autonoma `scenes/levels/inventory_save_test.tscn`. La mappa principale non è stata modificata da questo intervento: PC e porta definitivi saranno collegati dopo la reimportazione e l'identificazione dei nodi della nuova stanza.

**Riscontro utente successivo:** «ho provato la scena di test e funziona». Il salvataggio non è stato provato dall'utente e verrà verificato nella mappa. Questa conferma riguarda la scena base, non la revisione grafica descritta sotto o il funzionamento completo della mappa.

## Versione attiva — inventario blob, C/N e slot separati

**Conferma successiva dell'utente — 10/10/2026:** «funziona tutto». La versione attiva nella scena di prova è ora **TESTATO UTENTE**, inclusi nuovo inventario e flusso salvataggio/caricamento/morte descritti nella consegna. Non sono stati forniti dettagli dei singoli scenari eseguiti: non dedurre una prova specifica del riavvio dell'app né della mappa, ancora da integrare.

Ultimo riscontro: ConnesiOS approvato («perfetto»), inventario industriale rifiutato. Ora l'inventario usa palette scura/viola e pulsanti dello stesso `project_blob_menu_theme.tres` di menu/pausa. `blob_inventory_panel.gd` usa un materiale privato dello shader esistente `boss_health_blob.gdshader` per l'accento animato; shader/materiali del boss e HUD inferiore conservati. IndustrialPanel rimane nei file ma non è più referenziato.

Il richiamo **[I] INVENTARIO** è su una riga, solo nelle raccolte; nessun richiamo negli avvisi della porta/errori. Card nascoste anche durante pausa e cancellate al cambio scena.

**Menu iniziale:** il pulsante precedentemente chiamato Continua ora è **CARICA SALVATAGGIO** e legge lo slot principale. **Pausa:** aggiunto CARICA SALVATAGGIO, abilitato solo con un file valido della scena corrente. Dopo load chiude pausa/UI e restituisce il controllo. Nessun comando Salva nella pausa: resta manuale al PC.

**Morte:** sotto il titolo esistente il prompt dinamico mostra **PREMI C PER CONTINUARE** e **PREMI N PER RICOMINCIARE** se il file della scena è valido; senza file mostra solo N. C ripristina il salvataggio, senza file non agisce. N ricostruisce sempre la scena dall'inizio, azzera checkpoint attivo/inventario/mondo, conservando il file; anche dopo N si può caricare il vecchio slot dalla pausa. Questa scelta sostituisce il precedente N/checkpoint.

| Contesto | File |
|---|---|
| Mappa/menu iniziale | `user://savegame.cfg` |
| F6 inventory_save_test | `user://inventory_save_test.cfg` |
| Automazione | Override espliciti sotto `.godot` |

SaveManager.select_scene_slot sceglie prima che il PC legga il timestamp; il menu iniziale torna al principale. Gli slot standard rifiutano dati demo nel principale e altre scene nello slot prova. Nessuna cancellazione/migrazione di file esistenti: una vecchia demo eventualmente scritta nel principale non abilita Carica per la mappa.

**Prova indipendente dalla mappa:** F6 sulla scena di prova → PC a sinistra dello spawn, avvicinarsi/E → SALVA PARTITA/completamento → Esc → spostarsi o raccogliere un oggetto → F8. C ripristina; N riparte da zero. Da vivo Esc → CARICA SALVATAGGIO ripristina lo stesso slot prova. Dopo chiusura dell'app riaprire F6 sulla stessa scena e caricare dalla pausa; il file prova persiste. Il menu iniziale normale legge invece il principale. Il PC demo non sovrascrive il salvataggio della mappa; i controller comuni modificati richiedono comunque la successiva prova SAFE nella scena definitiva.

**Verifiche:** suite principale con eventi reali C/N, morte con/senza file, N con checkpoint presente, pulsante pausa e routing slot: exit 0. Processo separato, menu e chiave non raccolta: exit 0. D3D12 a 1280×720/1600×900: exit 0, CONNESIOS_RENDER_TESTS_OK, immagini inventario/pausa/porta/morte con e senza file in `.godot`. Corretti consumo C/N dopo rimozione del viewport e riassegnazione tardiva del checkpoint dopo restore_completed. Mappa e SavePCStation invariati tramite hash. Nuovo inventario/salvataggio ancora non TESTATO UTENTE.

## Revisione grafica precedente — 10/10/2026 (inventario superato)

Richiesta utente: inventario coerente con il gioco, messaggio raccolta in una zona dedicata della HUD e ConnesiOS ispirato a [connesi.it](https://www.connesi.it/). Intervento limitato alla presentazione; scena della mappa, scena HUD e controller del salvataggio conservati.

- **Inventario:** dossier centrale 920×680, oscuramento del mondo, cornice metallica con viti e porzioni della texture HUD già presente, targhette blu/ocra e tipografia della HUD con fallback di sistema. Elenco oggetti a sinistra; scheda su carta ingiallita, icona, nome e descrizione a destra. Il pannello si ridimensiona per restare nel viewport. Colori/fabbriche in `scripts/ui/inventory_skin.gd`, cornice in `scripts/ui/industrial_panel.gd`; icona originale della chiave generata da SVG incorporato nello script, senza dipendere da file SVG esterni nell'export.
- **Raccolta:** card 500×88 con icona, titolo ocra «OGGETTO RACCOLTO», nome oggetto e richiamo I. Posizionamento rispetto al rettangolo reale `Interface/HudBar/HudBackground`: centrata, **18 unità UI sopra** la barra, mai sul volto/salute/munizioni. Dissolvenza 0,18 s, permanenza 3,2 s, uscita 0,35 s. Messaggi successivi sostituiscono il precedente. Card e figli ignorano il mouse. Si nasconde mentre una modalità UI è aperta, durante restore e quando Interface è nascosta per cinematica/morte. Le altre comunicazioni usano lo stesso spazio con titolo distinto. API compatibile `GameplayUI.notify(message, item_id opzionale)`; il pickup passa il proprio ID.
- **ConnesiOS:** palette ricavata dal [CSS ufficiale letto il 10/10/2026](https://www.connesi.it/wp-content/themes/connesi-theme/style.css): verde `#2BB673`, blu `#25387B`, blu notte `#001F3F`. Intestazione chiara, fascia blu, scheda bianca arrotondata, azione verde e uscita contornata. Composizione originale per il gioco; font/logo/fotografie del sito non scaricati nel progetto. Font di sistema con fallback. Supporto del monitor prototipo arretrato/abbassato per non coprire il footer dello schermo.

**Verifiche della revisione:** suite runtime principale `INVENTORY_SAVE_TESTS_OK`, exit 0; renderer Forward+ D3D12/RTX 4060 `CONNESIOS_RENDER_TESTS_OK`, exit 0, senza warning GUI nella versione finale. Confermati clic sul salvataggio, ritorno Esc, chiusura inventario con mouse, card generata dalla raccolta reale del drop, separazione dalla HUD e soppressione quando Interface è nascosta. Screenshot inventario a 1280×720 e 1600×900, monitor e notifica in `.godot`, rigenerabili dal test. Il test grafico usa una finestra temporanea 16:9 e non salva modifiche alle impostazioni video dell'utente. Suite headless con avvisi ambientali certificati/risorse in uso alla chiusura, già rilevati prima della revisione; non sono asserzioni fallite.

**Stato:** nuova grafica implementata e verificata tecnicamente, conferma estetica utente aperta. Salvataggio provato automaticamente, non ancora TESTATO UTENTE. L'inserimento nella mappa resta il passo successivo dopo revisione di PC/porta reali e della versione corrente della scena.

## Decisioni approvate

- Inventario iniziale per chiavi e oggetti di missione, aperto con **I**, chiuso con I/Esc o pulsante. Definizioni Resource estensibili, quantità e descrizione; armi e consumabili continuano a usare il sistema esistente.
- Bruno lascia **una sola chiave alla morte finale**, senza drop nelle cadute di cambio fase. Raccolta con **E**, nessuna raccolta automatica. La chiave resta nell'inventario dopo lo sblocco.
- Porta scorrevole distinta dalle porte a battente esistenti: E sblocca/apre, poi apre/chiude; chiusura impedita o invertita se il player occupa il passaggio.
- **Solo salvataggio manuale al PC**, principale `user://savegame.cfg` e prova indipendente `user://inventory_save_test.cfg`. Nessun autosave alla raccolta, allo sblocco o alla morte.
- E sul PC attiva una camera dedicata con avvicinamento di 0,75 secondi. ConnesiOS è disegnato sul monitor 3D tramite SubViewport; Salva partita/Esci ricevono i clic proiettati sullo schermo. Esc torna al player con transizione di 0,5 secondi.
- Durante inventario/PC il gameplay è in pausa; clic UI e mouse trattenuto non sparano. Il PC nasconde HUD/viewmodel e ne ripristina la visibilità precedente, insieme a camera, mouse e pausa.
- Non si salva durante combattimento Bruno, cinematica, movimento di porte registrate o azioni/ricarica dell'arma. Il monitor mostra l'esito della scrittura.
- Dopo la morte **C carica il file valido della scena**, **N ricomincia sempre**. Senza file compare soltanto N. Carica salvataggio nei menu legge il rispettivo slot anche dopo riavvio dell'app.
- Nuova partita azzera il checkpoint attivo e lo stato in memoria, conservando il vecchio file fino al successivo salvataggio manuale.
- Skip dell'intro Bruno rinviato; nessuna scorciatoia aggiunta alla cinematica.

## Stato salvato e ripristino

Versione formato **1**, ConfigFile con dizionario `checkpoint/data`: scena, timestamp, player, inventario e oggetti del mondo identificati da ID stabili. Nessun NodePath temporaneo o instance ID nel file. Scrittura su `.tmp` e sostituzione dello slot solo dopo successo; un errore non cambia il checkpoint in memoria.

Il player conserva trasformazione, inclinazione della testa, crouch e salute. Le armi conservano possesso/equipaggiamento, caricatori e riserve pistola/SMG, batterie, carica e accensione della torcia. Il ripristino applica direttamente lo stato senza simulare nuovi pickup o animazioni di equipaggiamento.

Gli oggetti registrati conservano pickup raccolti, porte, eventi una tantum, alimentazione/TV e fine ambiente boss. Il boss conserva sconfitta finale, trasformazione del corpo e posizione del drop. Una chiave non raccolta torna a terra; una raccolta non viene duplicata. C/Carica annullano i progressi successivi al salvataggio; N azzera tutta la partita corrente.

La scena viene ricostruita dietro SceneTransition e in pausa; prima si ripristinano player/inventario, poi gli oggetti registrati. L'alimentazione precede la TV; l'ambiente boss viene applicato dopo le porte. Gli oggetti dinamici possono consultare lo stato per evitare doppi spawn.

Questo sistema salva gli oggetti **collegati e registrati**, non ogni nodo arbitrario della mappa. Gli adattatori per alimentazione, TV, porte a battente e ambiente boss sono disponibili, ma il loro collegamento e playtest nella mappa definitiva restano da eseguire.

## File e contratti

| Componente | File |
|---|---|
| Definizione oggetto e chiave | `scripts/inventory/item_definition.gd`, `resources/items/bruno_key.tres` |
| Autoload inventario | `scripts/systems/inventory_manager.gd` |
| Autoload checkpoint e registro oggetti | `scripts/systems/save_manager.gd` |
| Autoload UI, pausa e camera PC | `scripts/ui/gameplay_ui.gd` |
| Stile inventario/card e cornice attiva | `scripts/ui/inventory_skin.gd`, `scripts/ui/blob_inventory_panel.gd` |
| Base interazione e outline | `scripts/interactables/persistent_interactable.gd` |
| Pickup inventario | `scripts/pickups/inventory_item_pickup.gd`, `scenes/pickups/bruno_key_pickup.tscn` |
| Porta scorrevole | `scripts/interactables/sliding_door.gd`, `scenes/interactables/sliding_key_door.tscn` |
| PC e monitor | `scripts/interactables/save_pc_station.gd`, `scenes/interactables/save_pc_station.tscn` |
| Drop e stato boss | `scripts/systems/boss_loot_drop.gd` |
| Adattatore oggetti esistenti | `scripts/systems/persistent_object.gd` |
| Scena autonoma e allestimento | `scenes/levels/inventory_save_test.tscn`, `scripts/debug/inventory_save_demo.gd` |
| Test persistenti | `scripts/tests/inventory_save_test.gd`, `scripts/tests/connesios_render_test.gd` |

Collegamenti mirati: player espone get/apply_save_state e gestisce C/N; weapon espone get/apply_save_state e blocca il fuoco UI; Bruno emette defeated una sola volta e offre restore_defeated_state; menu iniziale/pausa offrono Carica. project.godot registra autoload e inventory/I. Main scene e scena della mappa conservate.

Gli interagibili usano le API già esistenti `get_interaction_name/action/color`, `set_interaction_focus`, `interact(player)`. Il collider per E è sul layer 2; il pannello fisico prototipo usa layer 1+2, il passaggio rileva il player sul layer 1. Il player reale e la HUD reale sono usati nella prova.

## Provare in editor

Aprire `scenes/levels/inventory_save_test.tscn` e premere **F6**. La scena costruisce un pavimento, Bruno reale con 30 HP, pickup reali, porta e PC prototipo. **F7** avvia il boss; **F8** provoca la morte del player. Questi comandi sono esclusivi della scena di prova; **C** carica dopo la morte e **N** ricomincia.

1. Porta senza chiave: E deve rifiutare. I deve mostrare un inventario vuoto.
2. Sconfiggere tutte le fasi di Bruno, raccogliere la chiave con E e controllare I. La chiave compare solo dopo la morte finale.
3. Sbloccare la porta, attraversarla, aprirla/chiuderla e verificare che non chiuda sul player. La chiave resta in inventario.
4. E sul PC, clic Salva partita, Esc. Verificare zoom, monitor, messaggio, camera/HUD e ripresa senza spari involontari.
5. Cambiare posizione, salute, munizioni e pickup; F8/C annulla i progressi dopo il salvataggio. F8/N riparte da zero.
6. Chiudere l'app e riaprire F6: Esc → Carica salvataggio legge lo slot prova. Il menu iniziale normale legge soltanto il principale.

F6 salva solo in user://inventory_save_test.cfg. Gli script automatici reindirizzano ulteriormente lo slot in `.godot`.

## Verifiche eseguite il 10/10/2026

Godot **4.7.2.stable.official.ed1daf0bf**. Test runtime automatizzati, senza conferma playtest utente:

- Suite principale: inventario vuoto, key gating, cambi fase senza loot, morte finale/drop unico, raccolta unica, chiave conservata, porta in movimento/occupata, salvataggio manuale ripetuto, blocco combattimento, UI senza spari, snapshot del player anziché camera monitor, rollback di salute/posizione/equipaggiamento/munizioni/batterie/porte/pickup/evento, nessun doppio drop, nuova partita e scrittura fallita. Esito `INVENTORY_SAVE_TESTS_OK`, exit 0.
- Processo separato `--continue-test`: stato boss, inventario e porta persistono dopo riavvio. `--uncollected-test`: chiave non raccolta ripristinata alla posizione salvata. `--menu-test`: pulsante Carica salvataggio abilitato e caricamento della scena salvata. Tutti exit 0.
- Forward+ **D3D12 / RTX 4060**: monitor renderizzato; eventi mouse attraversano lo schermo 3D e salvano; Esc ripristina camera/pausa/viewmodel; inventario mostra la chiave e il pulsante Chiudi funziona con mouse. Esito `CONNESIOS_RENDER_TESTS_OK`, exit 0. Screenshot/log rigenerabili in `.godot`.

Comando suite dalla radice (PowerShell):

```powershell
& 'D:/ProjectBlob/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe' --headless --path 'D:/ProjectBlob/Game' --audio-driver Dummy --script 'res://scripts/tests/inventory_save_test.gd'
```

Dopo la suite principale ripetere con `-- --continue-test`, `-- --uncollected-test` e `-- --menu-test`. Per la prova grafica usare `--rendering-method forward_plus --rendering-driver d3d12` e `--script res://scripts/tests/connesios_render_test.gd`, senza `--headless`.

I processi headless segnalano l'errore ambientale di lettura dello store certificati. Alcune esecuzioni di test hanno segnalato risorse ancora in uso alla chiusura; il test menu e quello grafico finali non lo segnalano. Non dichiarare assenza globale di warning. Le impostazioni video locali producono un viewport verticale; monitor e pannello si adattano, ma la resa alle risoluzioni definitive va confermata dal playtest. Nessuna prova della mappa reimportata, dell'audio finale o degli adattatori alimentazione/TV/ambiente nella loro scena reale.

## Collegamento futuro alla nuova stanza

**Nuova estensione concordata 10/10/2026:** oltre alla porta con chiave, aggiungere una scorrevole senza chiave del bagno regia e una porta a battente della regia. Utente indica mesh con pivot predisposto. Nel GLB verificati nomi `PCRegia`, `Porta Bagno Regia`, `Porta Regia`, `Porta Regia.001`; non attribuire automaticamente a questi ultimi due il ruolo di porta bloccata/a battente. Richiesti path Godot e pannelli mobili/telaio/monitor; collegamento ancora da eseguire dopo identificazione. Per scorrevoli verificare asse locale, corsa e collider/Area3D; per battente conservare pivot stipite e separare telaio fisso. La versione corrente SlidingKeyDoor non tratta ancora required_key vuoto come porta libera: supporto da implementare e testare senza cambiare default chiave Bruno.

**Ripresa confermata dall'utente il 10/10/2026:** implementare questi collegamenti nella scena principale, oltre a terminare l'animazione della bocca di Bruno. I componenti della demo sono già approvati; manca l'integrazione reale e la sua prova. Alla ripresa verificare la mappa locale reimportata, PC e porta effettivi prima di intervenire. Provare l'intero percorso: morte finale boss → chiave → inventario → apertura porta → salvataggio PC → caricamento e ripristino senza doppio drop; includere C/N, pausa/Carica e riavvio dell'app. Conservare lo slot demo indipendente.

Prima identificare i nodi **reali**, leggerne script/scene e confrontare le differenze Git. Nessun path della regia o del modello definitivo è stato inventato.

- PC: istanziare `save_pc_station.tscn`, assegnare `persistent_id` unico, disattivare `generate_test_geometry`, allineare la radice/screen_origin/screen_size al monitor reale. Il quad guarda verso +Z locale. Un Marker3D in `focus_marker` definisce la camera definitiva, orientata verso il monitor. Il modello può essere figlio della radice o rimanere nell'ambiente; verificare collider e distanza di E.
- Porta: istanziare `sliding_key_door.tscn`, assegnare ID unico, disattivare geometria prototipo, indicare `panel_path` a un **AnimatableBody3D** che contiene mesh e collider mobili e `passage_path` a un **Area3D** fisso. Configurare offset locale/velocità, interazione layer 2 e suoni SFX approvati. Non applicare lo script alle porte a battente esistenti.
- Boss: aggiungere un Node con `boss_loot_drop.gd`, assegnare boss reale, ID boss e `loot_id` separati; assegnare cinematic_controller reale per disattivare i blocchi intro al ripristino della sconfitta. Il semplice segnale defeated nella scena boss non aggiunge da solo un drop nella mappa.
- Pickup esistenti: figlio con `persistent_object.gd`, target al pickup e Kind PICKUP; ID stabile per ciascun oggetto. Il raccolto deve avere `collected=true` prima di queue_free, come nei pickup correnti.
- Evento meteorite: adattatore Kind METEORITE_EVENT. Porte a battente: SWING_DOOR; `connesi_power.gd`: POWER; `tv_controller.gd`: TV; `bruno_fight_environment.gd`: BOSS_ENVIRONMENT. Verificare ordine, eventuali trigger sovrapposti al punto di spawn e audio: questi collegamenti non sono ancora playtestati.

Gli ID devono restare unici e stabili tra avvii. Duplicarli produce un errore; rinominarli perde la corrispondenza con i salvataggi esistenti. Per nuovi oggetti usare Resource registrata con InventoryManager.register_item, item_id stabile e pickup configurato. La prima versione non include inventario drag/drop, crafting, gestione armi duplicata o salvataggio di nemici generici.

Prossimo passo: valutazione della nuova grafica in F6 e identificazione PC/porta della regia reimportata; poi integrazione mirata e prova utente del salvataggio nella mappa. La scena base è già stata confermata funzionante dall'utente. Nessuno staging, commit o push eseguito.
