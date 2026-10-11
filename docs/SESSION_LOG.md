# Project Blob — registro delle sessioni

Registro append-only: aggiungere voci cronologiche, senza cancellare la storia. Per correzioni aggiungere nota datata. La baseline PDF resta distinta.

## 2026-10-08 — analisi, documentazione e continuità

**Richiesta:** analizzare progetto Godot, verificare Git, leggere PDF in docs, produrre i Markdown per riprendere le sessioni. Piano approvato con “Implement the plan”.

**Baseline:** `dev/prototype-0.1`, HEAD `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c`. Prima della documentazione: 10 modificati, 26 cancellati, 258 non tracciati (incluso PDF), nessun file staged. [Inventario completo](CURRENT_STATE.md).

**Acquisito:** tutte le 10 pagine del PDF; standard tecnici; configurazione, riferimenti scene, controller principali, Git/cronologia/ignore/LFS. Rilevati mappa da 26.608.635 byte / 50 sub_resource concavi, override Bruno 90 HP contro default 180 e protezione locale del prompt a HUD nascosta. Rilievi aperti su dipendenze SilverDelivery/GodotLootVFX, sensibilità pausa, errori transizione e attese animazione.

**Correzione al primo resoconto:** Godot non era nel PATH, ma l'eseguibile esiste nel percorso indicato dal PDF. Il numero 62 si riferiva ai `.gd` sotto `scripts/`, non all'intero progetto; l'inventario PDF contiene 80 script nel commit storico. Il conteggio iniziale dei non tracciati era 257, poi 258 con PDF.

**Documenti creati:** `AGENTS.md`, `docs/README.md`, `docs/BASELINE_SAFE_2026-10-08.md`, `docs/ARCHITECTURE.md`, `docs/CURRENT_STATE.md`, `docs/DECISIONS_AND_BACKLOG.md`, `docs/WORKFLOW_AND_TESTING.md`, questo registro.

**Documenti aggiornati:** README principale (stato/indice); standard tecnici (baseline senza commit autonomo, staging mirato, distinzione superfici impatti/passi).

**Validazione documentale:** sezioni 0–17 e inventario di 80 script preservati, collegamenti locali controllati, contenuto confrontato con la fonte, stato Git confrontato prima/dopo per il solo intervento documentale; PDF conservato. Nessun playtest dichiarato da questa sessione.

**Esclusioni:** nessuna modifica autorizzata a gameplay/scene/asset/configurazione Git; nessun Godot/Blender, build/export, fetch, staging, commit o push. Il lavoro preesistente è rimasto nella working directory. Anche questi Markdown sono locali finché l'utente non ne richiede il salvataggio in Git.

**Ripresa:** leggere indice e stato, ripetere controlli Git, riconfermare un obiettivo. Il prossimo lavoro storico è Blender/nuova stanza, non ancora iniziato qui. Per bug/rifiniture usare ID del backlog e relative prove.

## 2026-10-08 — onda Bruno lilla, pulsante e gelatinosa

**Obiettivo/richiesta:** modificare il materiale dell'onda a banana dell'attacco con racchetta: più chiaro, pulsante e simile a un blob. Preferenza esplicita “Morbida e gelatinosa”; piano implementato su richiesta.

**Baseline:** dev/prototype-0.1, HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c; i tre file VFX/anteprima coinvolti non avevano differenze da Git prima dell'intervento. Working directory già modificata come documentato, nessun staging. Fonti lette: contratto/documenti, shader e scena attivi, controller completo dell'onda, script/scena anteprima e richiamo start_wave() da Bruno.

**File modificati:**

- assets/vfx/bruno_melee_banana3d/magical_waterball_fire_godot4.gdshader: noise locale senza cucitura UV, colori morbidi, pulsazione e vertex wobble radiale con punte attenuate; attribuzione/licenza conservate.
- assets/vfx/bruno_melee_banana3d/bruno_melee_banana3d.tscn: Core lilla chiaro / Shell trasparente, parametri Inspector sincronizzati e margine culling 0,25.
- scenes/vfx_tests/bruno_melee_banana3d_test.gd: file completo aggiornato, metodo start_wave() corretto e damage_enabled=false per la sola anteprima.
- Documenti: stato corrente, architettura, backlog B03 e questo registro.

**Parametri prima versione:**

| Controllo | Core | Shell |
|---|---|---|
| root_color RGB | 0,84 / 0,68 / 1 | 0,75 / 0,48 / 1 |
| tip_color RGB | 0,58 / 0,32 / 0,90 | 0,48 / 0,23 / 0,82 |
| specular_color RGB | 0,96 / 0,90 / 1 | 0,92 / 0,80 / 1 |
| fire_alpha | 0,85 | 0,25 |
| emission_boost | 1,8 | 0,95 |
| wave_noise_scale | 0,025 | 0,035 |
| fire_speed XY | 0,12 / 0,25 | 0,12 / 0,25 |
| wave_noise_speed XY | 0,12 / 0,08 | 0,12 / 0,08 |
| pulse_frequency Hz | 1,2 | 1,2 |
| pulse_intensity | 0,18 | 0,18 |
| blob_wobble_amplitude locale | 0,06 | 0,06 |
| blob_wobble_speed | 0,8 | 0,8 |

**Verifiche:** Godot 4.7.2.stable.official.ed1daf0bf; avvio anteprima headless con quit-after 120. Prima verifica GPU Compatibility/OpenGL: shader compilato, ma pulsazione su sola EMISSION poco visibile. Correzione: luminosità HDR su ALBEDO, come previsto per unshaded dalla [documentazione Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/spatial_shader.html). Versione finale verificata in Forward+ D3D12 su RTX 4060: exit 0, senza errori shader/script, uniform verificati su Core/Shell; screenshot frontali in due istanti, laterale, dissolvenza completa e attenuazione al 45%. Controllato avvio dell'onda senza danno e conservazione dei parametri del controller.

Il controllo headless iniziale ha segnalato un errore di lettura dello store certificati del sistema, estraneo al VFX; il primo OpenGL ha segnalato FXAA non disponibile in Compatibility. Il rendering finale D3D12 non ha prodotto tali errori/avvisi. Il controller movimento/danni, lo script Bruno e la mappa sono preservati e verificati tramite hash. Il diff dei file modificati è stato controllato.

**Artefatti locali:** script di verifica, log e PNG bruno_wave_front, front_pulse, side, dissolved, attenuated sotto .godot; cache ignorata, non necessaria al gioco. Nessun test automatico permanente aggiunto.

**Stato/conferma utente:** implementazione e anteprima tecnica completate; prova in arena e conferma estetica dell'utente ancora da ricevere. Non dichiarare B03 concluso né TESTATO UTENTE.

**Git:** nessuno staging, commit o push; modifiche locali preesistenti conservate.

**Ripresa:** aprire scenes/vfx_tests/bruno_melee_banana3d_test.tscn e usare F6; poi valutare l'attacco di Bruno nella mappa. Regolare i parametri dei due materiali soltanto in base a feedback concreto, mantenendo coerenti fase/deformazione. La richiesta onda prende precedenza sul prossimo lavoro storico Blender per questa sessione.

## 2026-10-08 — scritta connesi sulla maglietta BetterBuozzi

**Richiesta:** aggiungere “connesi” alla maglietta, partendo da BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture.png. Posizione predefinita comunicata: centro della porzione bianca integra del petto, minuscolo blu scuro.

**Baseline:** branch dev/prototype-0.1 / HEAD e5ff3c8, working directory già modificata; scena Bruno letta e confrontata con Git prima dell'intervento. Le differenze locali preesistenti sono preservate.

**Lavoro:** ispezionato GLB/materiale effettivo e UV; lettering trasparente creato con built-in imagegen, i puntata corretta con una seconda modifica; baking geometrico nelle UV frontali. Prima prova troppo larga/tagliata dalla mutazione, adattata allo spazio bianco. Variante PNG 2508×2508, originale 1254×1254 preservato, materiale copiato e assegnato soltanto alla superficie del corpo nella scena boss.

**File:** nuova texture _texture_connesi.png, connesi_wordmark.png e BetterBuozzi_connesi_material.tres sotto assets/models/enemies/bruno_buozzi; scenes/enemies/bruno_buozzi.tscn aggiornata con override; indice, stato corrente, backlog e [nota asset completa](BETTERBUOZZI_CONNESI_TEXTURE.md).

**Verifiche:** import Godot e caricamento del materiale dalla scena boss confermati; rendering frontale/posteriore della mesh di riposo in D3D12, parola leggibile; hash originale/GLB/controller invariati. Avvisi di import su asset preesistenti e limitazioni delle impostazioni globali editor documentati nella nota; materiale finale caricato senza errori.

**Limiti:** nessuna conferma estetica utente, nessun playtest di combattimento/cinematica. Rendering della mesh di riposo, non test delle animazioni. Cache di baking/preview ignorata, asset finali dentro workspace.

**Git:** nessuno staging/commit/push. **Ripresa:** aprire la scena Bruno o la mappa e verificare la maglietta nelle animazioni; leggere la nota asset per texture, materiale, posizionamento e prompt.

## 2026-10-10 — inventario, chiave Bruno, porta scorrevole e PC ConnesiOS

**Obiettivo:** implementare il piano approvato nella scena autonoma prima dell'integrazione della nuova stanza. Inventario I, raccolta E, drop finale unico, chiave conservata; salvataggio manuale soltanto al PC, uno slot, morte/N e Continua. Skip intro rinviato.

**Baseline:** `dev/prototype-0.1`, HEAD `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c`, staging vuoto. Working directory già modificata, con asset ignorati/non tracciati e mappa locale differente da Git. Script coinvolti letti e confrontati prima delle modifiche; differenze precedenti preservate. La scena principale non è stata modificata; GLB ambiente aggiornato dall'utente distinto dalla scena map_test esistente.

**File:** nuovi script inventario, SaveManager, GameplayUI, PersistentObject, PersistentInteractable, SlidingKeyDoor, SavePCStation, BossLootDrop e InventoryItemPickup; Resource bruno_key; tre scene riutilizzabili; inventory_save_test.tscn/inventory_save_demo.gd; due script di test. Modifiche mirate a project.godot e ai controller completi player, weapon, bruno_buozzi e main_menu. Elenco e contratti in [INVENTORY_SAVES_CONNESIOS.md](INVENTORY_SAVES_CONNESIOS.md).

**Verifiche:** Godot 4.7.2, suite headless principale exit 0/INVENTORY_SAVE_TESTS_OK; suite processo separato Continua, chiave non raccolta e pulsante menu Continua exit 0. Controllati blocco combattimento/movimento, transizioni fase senza drop, doppia raccolta, chiave non consumata, passaggio occupato, scrittura ripetuta/fallita, rollback salute/posizione/armi/munizioni/batterie/porte/pickup/evento, nuova partita senza cancellare disco. Porta testata con attesa di aggiornamento effettivo Area3D; posizione confrontata con tolleranza per assestamento fisico al pavimento.

**Grafica/input:** Forward+ D3D12 su RTX 4060, exit 0/CONNESIOS_RENDER_TESTS_OK: ConnesiOS sul monitor, clic proiettati sul pulsante Salva, Esc e camera/HUD/viewmodel ripristinati, inventario con chiave e chiusura mouse. Corretto il passaggio degli eventi dell'inventario alla GUI e l'adattamento del pannello alle dimensioni viewport. Log, screenshot e slot automatici in `.godot`; i test non scrivono lo slot utente.

**Limiti:** errore ambientale certificati nei processi headless; alcuni test di chiusura hanno segnalato risorse ancora in uso, senza fallimenti delle asserzioni. Menu e rendering finali senza questi avvisi. Nessun playtest umano, nuova mappa non provata, adattatori POWER/TV/BOSS_ENVIRONMENT non collegati/testati nella mappa; audio e modelli finali da definire. Le impostazioni locali generano un viewport verticale: UI adattata, altre risoluzioni da confermare.

**Documenti:** indice, stato corrente, backlog B15/B16, architettura, questa sessione e nuova nota completa. Baseline storica inalterata. **Git:** nessuno staging/commit/push.

**Mappa al controllo finale:** map_test.tscn 26.936.463 byte, LastWriteTime locale 10/10/2026 00:30:45; diversa dalla lettura iniziale. Nessuna patch dell'intervento modifica questo file. Considerare la versione reale al prossimo collegamento, senza dedurne che i nuovi nodi siano già presenti.

**Ripresa:** F6 su inventory_save_test.tscn, E/I/F7/F8/N; confermare il comportamento, poi identificare i nodi reali del PC regia e della porta scorrevole reimportati e collegare i componenti con ID stabili. Leggere la nota prima di introdurre nuovi stati salvati.

## 2026-10-10 — rifinitura inventario, card raccolta e ConnesiOS

**Richiesta/riscontro:** l'utente ha provato la scena autonoma e dice che funziona. Non ha provato il salvataggio: verrà verificato nella mappa. Richiede inventario in stile gioco, notifica raccolta in una zona dedicata della HUD e monitor ispirato a www.connesi.it; integrazione nella mappa successiva e SAFE.

**Baseline:** branch dev/prototype-0.1 / HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c, staging vuoto. File UI nuovi della precedente implementazione ancora non tracciati: letti integralmente e confrontati con il contesto della consegna, conservando gameplay/checkpoint. Letti documenti SAFE, standard, architettura e procedura; ispezionate scena/texture HUD e test grafico esistente.

**Intervento:** inventario come dossier con cornice metallica/viti, targhette blu/ocra, carta ricavata dalla HUD e icona originale della chiave; backdrop e dimensioni adattive. Card raccolta animata 18 unità sopra HudBackground, con icona/titolo/nome/I, input passante e visibilità coerente con HUD/modalità. notify aggiunge solo l'ID opzionale; pickup chiave aggiornato. ConnesiOS con intestazione chiara, fascia blu, card bianca, Salva verde e Esci contornato; supporto prototipo monitor spostato per non coprire lo schermo.

**Fonte:** homepage e CSS https://www.connesi.it/wp-content/themes/connesi-theme/style.css letti: verde #2BB673, blu #25387B, notte #001F3F. Composizione del monitor originale per il gioco; nessun font, logo o foto commerciale aggiunto. HTML/CSS di riferimento soltanto in .godot. Riutilizzata hud_empty.png senza modificarla; SVG originale incorporato nel codice per evitare dipendenze sorgenti esterne nell'export.

**File:** scripts/ui/gameplay_ui.gd, nuovi scripts/ui/inventory_skin.gd e scripts/ui/industrial_panel.gd; scripts/pickups/inventory_item_pickup.gd; scripts/interactables/save_pc_station.gd; scripts/tests/connesios_render_test.gd esteso. Documentazione: stato, nota inventario, backlog B15/B17, architettura, procedura e registro.

**Verifiche:** Godot 4.7.2, suite runtime principale exit 0/INVENTORY_SAVE_TESTS_OK, nessuna asserzione fallita; avvisi headless certificati e risorse in uso alla chiusura già rilevati nella precedente implementazione. D3D12 Forward+ RTX4060 exit 0/CONNESIOS_RENDER_TESTS_OK, senza warning GUI nella versione finale. Clic sul monitor salvano, Esc ripristina, chiusura inventario mouse funziona; raccolta del drop reale produce card fuori dalla barra HUD, Interface nascosta sopprime la card. Inventario verificato in immagini 1280×720 e 1600×900, proporzioni/viewport e testi controllati. La prova video cambia solo la finestra corrente, non settings.cfg.

**Artefatti:** .godot/inventory_panel.png, inventory_panel_1600.png, inventory_pickup_notice.png, connesios_monitor.png e relativi log/slot, rigenerabili dai test. **Protezione:** hash mappa invariato 7CDA6E5602A5AB72D72BA445BA15595C5F0699B7A6DD2A803DC4FB4E15FB7EA2; scena HUD invariata CBB70A86D3DA7A8B11D60B47B1C7CB507DAA3A9A55897D7E7187E3BD510F1C8D. Nessuna patch a player/weapon/Bruno/SaveManager/mappa in questa revisione. Nessuno staging/commit/push.

**Stato e ripresa:** scena base TESTATO UTENTE; nuova estetica verificata tecnicamente ma non ancora confermata; salvataggio non TESTATO UTENTE. Riprova F6 per nuova grafica; successivamente identificare i nodi reali della regia/porta e integrare in modo SAFE, poi provare il salvataggio insieme nella mappa. Non trasformare la generica conferma della scena base in conferma del salvataggio.

## 2026-10-10 — inventario blob, C/N, pausa e slot prova

**Richiesta:** ConnesiOS «perfetto», da preservare; inventario industriale respinto, riferimenti boss/menu/pausa. HUD inferiore rinviata. Carica nei menu, C per continuare quando salvato e N per ricominciare, sistemazione della I isolata e prova salvataggio separata dalla mappa.

**Baseline/letture:** dev/prototype-0.1 / e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c, staging vuoto. Letti script completi UI, player, SaveManager, pausa/menu, demo e test. Player locale confrontato con Git: sole aggiunte precedenti della persistenza; pausa inizialmente pulita. Ispezionati Theme/scena menu e shader boss reali; consultati SAFE, architettura/procedura.

**Intervento grafico:** nuova BlobInventoryPanel scura/viola, bordo/glow, materiale privato di boss_health_blob e pulsanti della Theme menu. InventorySkin non usa più la texture HUD; IndustrialPanel conservato ma non referenziato. [I] INVENTARIO su una riga solo nei pickup; card nascoste in pausa e cancellate al cambio scena. ConnesiOS/HUD inferiore conservati.

**Caricamento/morte:** pausa aggiunge Carica disabilitato senza file della scena; menu iniziale rinomina Continua in Carica salvataggio. Titolo/caduta morte conservati, istruzioni come Label C/N dinamica. C carica dal disco; N riparte sempre senza cancellare il file. Demo usa user://inventory_save_test.cfg, principale user://savegame.cfg; selezione prima della creazione PC, ritorno al principale nel menu. Override espliciti .godot preservati. Dati demo nel vecchio principale rifiutati, senza migrazione/cancellazione.

**File:** scripts/ui/gameplay_ui.gd, inventory_skin.gd, nuovo blob_inventory_panel.gd, pause_menu.gd, main_menu.gd; scripts/player/player.gd; scripts/systems/save_manager.gd; scripts/debug/inventory_save_demo.gd; entrambe le suite scripts/tests. Nessuna patch alla mappa, scena HUD, shader boss o SavePCStation.

**Verifiche:** suite principale headless exit 0/INVENTORY_SAVE_TESTS_OK, eventi C/N reali, assenza file, N con checkpoint, C/rollback, pulsante pausa/ripresa, routing e invarianti precedenti. Processo separato Continue, menu e chiave non raccolta tutti exit 0. Certificati ambientali e, nella principale, risorse in uso alla chiusura già segnalati precedentemente; nessuna asserzione fallita. GPU D3D12 RTX4060 a 1280×720/1600×900 exit 0/CONNESIOS_RENDER_TESTS_OK, senza errori script/shader; clic PC/pausa, C/N, prompt con/senza file, warning porta senza I e inventario in viewport. Nessuno slot utente sovrascritto dai test automatici.

**Problemi corretti dai test:** consumare C/N prima del cambio scena (dopo get_viewport può essere nullo); eliminare la riassegnazione tardiva del checkpoint dopo restore_completed che poteva sovrascrivere un reset N avviato dalla callback. PauseMenu chiusa nel restore e notifiche precedenti cancellate.

**Artefatti/protezione:** PNG inventory_panel, inventory_panel_1600, pause_load_save, door_missing_key, death_continue, death_no_save e log/slot in .godot. Hash mappa invariato 7CDA6E5602A5AB72D72BA445BA15595C5F0699B7A6DD2A803DC4FB4E15FB7EA2; SavePCStation invariato 3DED2BE49C572730F018C8A5E5B2237683C5A85DBA468CEA5DC263B6C18A5FC7. Nessuno staging/commit/push, baseline storica inalterata.

**Continuità:** aggiornati stato, nota inventario/versione attiva, backlog B17/B18, architettura, procedura e registro. ConnesiOS TESTATO UTENTE per estetica; nuovo inventario/salvataggio/morte verificati tecnicamente, conferma utente aperta. **Ripresa:** F6 → PC/E/Salva → Esc → F8/C, F8/N, pausa/Carica; chiusura/riapertura F6/Carica. Poi integrazione SAFE con i nodi reali della mappa.

## 2026-10-10 — conferma utente e consolidamento MD

**Riscontro:** «funziona tutto. hai aggiornato gli md?», riferito alla consegna inventario blob, Carica nei menu, C/N e prova con slot separato.

**Attività:** registrata la conferma come TESTATO UTENTE della versione nella scena autonoma; aggiornati CURRENT_STATE, nota inventario e backlog B17/B18. Voci precedenti conservate come storia. Nessuna modifica a script, scene o salvataggi; nessun nuovo test runtime necessario per questo aggiornamento documentale.

**Limiti:** conferma generale, senza elenco dei singoli scenari; non dedurre una prova specifica del riavvio dell'app o della mappa principale. **Ripresa:** integrazione SAFE nei nodi reali della mappa, poi playtest nella mappa; HUD inferiore rinviata. Nessuno staging/commit/push.

## 2026-10-10 — prova bocca Bruno e correzione taglio labiale

**Obiettivo:** semplice apertura/chiusura discreta mentre parla, implementazione autorizzata. Branch `dev/prototype-0.1`, HEAD `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c`, molte differenze locali preesistenti; staging vuoto. Consultati documenti di continuità e file pertinenti. Originali confrontati e preservati.

**File nuovi:** generatore Blender `tools/blender/build_bruno_mouth_preview.py`; `.blend/.glb` head-only in `assets/models/enemies/bruno_buozzi/mouth_preview/`; controller `scripts/characters/bruno_mouth_motion.gd`; preview `scripts/debug/bruno_mouth_preview.gd`; scena `scenes/levels/bruno_mouth_test.tscn`; test `scripts/tests/bruno_mouth_test.gd`. Nessuna patch a boss/intro/mappa. Anatomia originale priva di jaw/morph: taglio delle labbra e cavità nella variante, UV/materiale originale mantenuti.

**Verifiche:** Blender 5.2.1 esporta e rende frontale/tre quarti; Godot 4.7.2 headless e Forward+ D3D12 RTX4060: test 0 errori, voce reale 12 s, apertura entro 0.45, silenzi, stop/fine/pausa, manuale, animazione e rimozione bus. RMS max 0.3354, apertura GPU circa 0.401. Cache screenshot/log in `.godot`. Warning ambientali headless/Blender separati. SHA256 di modello originale, scena/script boss, intro e mappa identici alla lettura iniziale; mappa `7CDA6E5602A5AB72D72BA445BA15595C5F0699B7A6DD2A803DC4FB4E15FB7EA2`.

**Riscontro e correzione:** utente approva il resto ma segnala taglio non precisamente tra le due labbra. Sostituita curva generica con punti della linea di contatto rilevati nel render ortografico originale; stesso movimento/parametri. Rigenerazione Blender completata, render corretti controllati, test headless ripetuto: zero errori, apertura max 0.407. GPU precedente alla correzione. Conferma estetica della correzione ancora aperta.

**Continuità:** aggiornati indice, stato, architettura, procedura, backlog B19 e nota dedicata. Nessun commit/staging/push. `.blend` ignorato, backup esplicito necessario al consolidamento. Prossimo passo F6, M/O e frontale/tre quarti per confermare il taglio; integrazione reale della bocca da concordare dopo questa prova.

## 2026-10-10 — conferma prova bocca e passaggio alla prossima sessione

**Richiesta/riscontro:** «ok bellino», poi richiesta di continuare domani con movimenti più ampi durante il parlato e valutare altre forme, per esempio “O”, per maggiore realismo. Se non si può ottenere un buon risultato, l'apri/chiudi attuale è accettato.

**Attività:** aggiornati `BRUNO_MOUTH_PREVIEW.md`, `CURRENT_STATE.md`, backlog B19 e questo registro. Registrata conferma TESTATO UTENTE come gradimento generale del prototipo dopo le istruzioni F6; nessuna attestazione specifica dei singoli controlli. Nessuna modifica a codice, asset, scene o parametri.

**Verifiche/Git:** branch `dev/prototype-0.1`, HEAD `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c`, staging vuoto. Riletti i documenti coinvolti; aggiornamento solo documentale, nessun nuovo test runtime. Nessun commit/push.

**Ripresa:** leggere la nota bocca e aprire `scenes/levels/bruno_mouth_test.tscn` con F6. Prima aumentare/calibrare il movimento in risposta alla voce (max 0.45, guadagno 6 attuali); poi valutare nuova shape arrotondata e metodo per pilotarla. RMS misura volume, non fonemi. Preservare il prototipo approvato, far provare le modifiche all'utente senza anteprime fugaci. Integrazione nella cinematica/mappa ancora successiva e da concordare.

## 2026-10-10 — integrazione mappa aggiunta agli obiettivi di ripresa

**Richiesta:** oltre a terminare la bocca di Bruno, implementare nella scena principale i sistemi del PC/salvataggio e della chiave già provati nella demo.

**Continuità:** aggiornati CURRENT_STATE, INVENTORY_SAVES_CONNESIOS e DECISIONS_AND_BACKLOG (B15/B16/B18 insieme a B19). Ripresa: verifica dei nodi reali di PC/porta e stato della mappa reimportata; integrazione inventario, drop finale chiave, porta scorrevole, PC e adattatori persistenti necessari. Prova nella mappa di raccolta/apertura, salvataggio/caricamento, C/N, pausa e riavvio, senza duplicazione loot. Rifinitura bocca resta nello stesso elenco di lavoro.

**Limiti/verifiche:** solo documentazione riletta e aggiornata, nessuna modifica tecnica né nuovo test runtime; nessuna integrazione già effettuata, nessun commit/staging/push. Questa voce integra il passaggio di consegne precedente.

## 2026-10-10 — parlato espressivo e risata Bruno

**Richiesta:** completare la bocca con parlato più realistico, risata più ampia e altri movimenti. Intervento nella preview già concordata; nessuna integrazione nella mappa in questo passo.

**Diagnosi/intervento:** precedente RMS+open non cambiava la forma delle labbra. Generatore Blender esteso con `mouth_round` e `mouth_smile`, localizzate intorno alla bocca, nuova directory `mouth_preview_v2` per conservare la precedente approvata. Controller apertura max 0.72, rilascio 0.09 s, curva risposta esponente 0.72; risata max 0.972 e sorriso 0.85, mantenuto tra impulsi vocali. Round/smile nel parlato variano dal tempo audio senza riconoscimento fonetico. Preview estesa a 16 s e L per la risata, M+3/4 per osservare forme. Tempo risata 11.55 verificato nel controller intro originale. Modificati solo generatore, controller bocca, preview e relativo test; boss/intro/mappa preservati.

**Verifiche/limiti:** Blender 5.2.1 genera GLB con tre morph. Primo test avviato prematuramente prima dell'export fallito per asset assente, fermato e ripetuto dopo generazione. Headless: zero errori, max apertura circa 0.798, round 0.403; primo GPU rileva sorriso troppo breve tra impulsi (0.493), corretto mantenendo il sorriso nei silenzi della risata. Nuova verifica grafica finale e conferma estetica documentate nel seguito. Asset originali e variante precedente conservati. Nessun staging/commit/push; documenti stato/backlog/architettura/nota aggiornati. Prossimo passo prova F6 utente senza chiusura automatica, poi integrazione concordata nella vera scena e sistemi PC/chiave/salvataggio.

**Esito finale della revisione espressiva:** test GPU ripetuto dopo mantenimento sorriso: zero errori, max open 0.7801, round 0.3889, smile 0.8500. Screenshot round/smile controllati; cinque originali SHA256 invariati, staging vuoto. Conferma utente V2 ancora aperta. La prova iniziale interrotta non costituisce validazione, quella finale sì.

## 2026-10-10 — bocca collegata a cinematica e voci reali Bruno

**Richiesta:** V2 approvata «ok ci siamo»; integrare dialoghi della cinematica, combattimento, ferite e sconfitta, poi provare nella mappa prima di porta/chiave/PC.

**Baseline/intervento:** branch dev/prototype-0.1, HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c, differenze locali scene boss/mappa e script boss confrontate prima dell'intervento (preservate). Letti script boss/intro, ambiente audio e scena boss/riferimenti mappa. Nuovo `scripts/characters/bruno_mouth_integration.gd`, singolo child/ext_resource in scena boss; `bruno_mouth_motion.gd` esteso a player 3D e cambio sorgente, espressioni disattivate per dolore/caduta/morte. Nessuna patch a boss.gd/intro/ambiente/map_test. Nuovo test `scripts/tests/bruno_mouth_integration_test.gd`.

**Diagnosi:** voci boss e morte spaziali, dialogo 2D, sorgenti separate; non collegare musica o effetti. Cambio bus conserva routing e non duplica audio; sorriso risata segue animazione reale, apertura segue capture della voce selezionata. Avvio reale map_test headless terminato exit 0 con marker integrato; warning lampione SparksElectric mancante e certificate store preesistenti distinti dal nuovo componente.

**Continuità:** nota bocca/stato/architettura/backlog aggiornati. Test mappa delle singole sorgenti e risultato riportati a seguito; playtest completo utente ancora aperto. Nessun staging/commit/push. Prossimo passo F6 mappa, intro/combattimento/ferite/morte e pausa, poi sistemi chiave/porta/PC concordati.

**Esito test mappa dell'integrazione:** headless exit 0, failures=0; picchi dialoghi 0.633/0.635, attacco 0.612, dolore 0.636, caduta 0.623, sconfitta 0.637. Chiusura stop, priorità voce morte e ripristino/rimozione bus verificati. Test esercita metodi audio reali, non l'intera partita/timeline. Alla chiusura 2 ObjectDB/1 risorsa ancora in uso, limite registrato. Hash boss.gd/intro.gd/GLB originale/mappa invariati; cambiamento effettivo scena boss soltanto nuovo ext_resource/child oltre alle differenze preesistenti. Playtest utente mappa resta aperto.

**Regressione preview:** ripetuta suite V2 headless dopo collegamento della scena boss: failures=0, apertura max 0.797, round 0.403, smile 0.850. Confermato che la preview continua a escludere l'integrazione automatica. Anche questa chiusura segnala 2 ObjectDB/1 risorsa in uso; limite registrato, nessun blocco nel test funzionale.

## 2026-10-10 — diagnosi e correzione collider nel passaggio Bruno

**Segnalazione:** bocca funziona nella mappa; Bruno ora si blocca camminando tra tavolo e scrivania dopo intro. Obiettivo ripristinare passaggio preservando bocca. Branch/HEAD precedenti, nessun staging. Script boss invariato rispetto all'integrazione; mappa risalvata 10:41:42, hash iniziale intervento `B0902E77D75DEE11CC1DCE14DD877636FF7C7A641402223072CB6E64DC1B1AEE`; differenze confrontate prima della patch.

**Diagnosi:** A/B della mappa con/senza componente bocca mostra praticamente le stesse posizioni/blocco a Z=9.52. Collider urtato Parete_013/StaticBody3D a Z=9.46621, normale -Z. Mesh corrente AABB 0.414×12.319×12.119, collisione precedente 5.52×5.356×1.708; trasformazione relativa identità. Collider obsoleto rispetto al modello corrente. Prove riduzione raggio boss e waypoint non risolvono, non consolidate. Rigenerazione temporanea della sola parete consente Z=15.07.

**Modifica:** nuova risorsa `resources/collision/parete_013_current.tres` (192 vertici); mappa soltanto nuovo ext_resource e assegnazione shape al nodo specifico. Nuovo generatore `scripts/tools/build_bruno_passage_collision.gd`, diagnostica `scripts/tests/bruno_movement_diagnostic.gd`, regressione `scripts/tests/bruno_passage_test.gd`. Mesh visive, materiali, gruppi, metadati, transforms, navmesh, boss script/collider e bocca conservati.

**Verifica finale:** test mappa salvata exit 0, failures=0, triangoli collider uguali a mesh, raggio boss 0.18, bocca integrata presente, root (6.45443, 0.08938, 14.60089) dopo 10 s. Parte dal marker finale intro, non certifica l'intera sequenza cinematica. Warning certificati/lampione e risorse di altri test registrati separatamente; nessuna riscrittura generale per tali warning.

**Continuità:** nuova BRUNO_PASSAGE_COLLISION, indice/stato/architettura/backlog aggiornati. Richiesta di chiarimento sul momento del blocco inviata durante diagnosi, non necessaria alla correzione dimostrata. Bocca TESTATO UTENTE nella mappa; correzione cammino attende F6 intro completa utente. Poi PC/porta/chiave come concordato. Nessun commit/staging/push.

## 2026-10-10 — conferma passaggio e identificazione porte/PC regia

**Riscontro/obiettivo:** «ok ci siamo» per il passaggio Bruno; conferma TESTATO UTENTE. Avviata richiesta integrazione chiave, porta scorrevole bloccata, PC; aggiunte scorrevole libera bagno regia e porta normale regia. L'utente può indicare mesh con pivot già predisposto.

**Sopralluogo:** branch/HEAD invariati, differenze locali presenti. Letti documenti continuità, script SlidingKeyDoor/SavePCStation/porta/loot/persistence/demo e riferimenti reali mappa. Ispezione metadata JSON del GLB senza caricare binario 2 GB: presenti PCRegia, Porta Bagno Regia, Porta Regia, Porta Regia.001. Nomi modello non sostituiscono verifica path Godot; ruoli delle due regia da indicare. Richiesta asincrona dei path delle tre porte/monitor e parti mobili/telaio. Nessuna patch tecnica o test runtime; solo aggiornamenti MD.

**Ripresa:** ricevere identificazione utente, verificare pivot/asse/corsa, integrare componenti senza sostituire visiva e provare drop/raccolta/sblocco/porte libere/PC e persistenza. Scorrevole libera richiede supporto required_key vuoto (default attuale bruno_key da preservare). UI/salvataggi demo approvati, conferma mappa da ottenere. Nessun staging/commit/push.

## 2026-10-10 — chiave, tre porte e PC collegati nella mappa

**Richiesta/path:** laboratorio Porta Lab/Porta_011 DX→SX con chiave; bagno Porta Bagno Regia libera; battente Porta Regia con maniglie da correggere; monitor PCRegia/Collada visual scene group_003/Computer_Low. Autorizzazione esplicita all'integrazione, senza ulteriori conferme. Branch dev/prototype-0.1 / HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c, staging vuoto. Mappa nuovamente modificata dall'utente prima della lettura: SHA256 iniziale `2403F35635223F1B0B4FB2DFEFAEB1F5262925E4AAC1D70129EFC04E93FDB317`; scene/script/override pertinenti confrontati prima delle patch.

**Diagnosi/intervento:** GLB metadata e runtime confermano pannelli senza skin/top_level, sei maniglie regia fratelli del pannello; sei override verso vecchi path scomparsi e pannello localmente ruotato. Pulizia mirata di quegli override e orientazione chiusa ripristinata, pivot vero nell'origine Porta_009. Nuovo `scripts/systems/regia_map_integration.gd` e child/script in map_test creano wrapper mobili/persistenti usando le mesh originali; supporto chiave vuota in sliding_door.gd. PC allineato al piano frontale monitor ricavato dai triangoli. Loot finale e adattatori reali per pickup/porte/meteorite/energia/TV/ambiente; adattatori pickup figli del target per queue_free. Nessuna patch a boss.gd/intro/SaveManager/scena boss/GLB, collider Parete_013 e bocca conservati.

**Verifiche:** `regia_map_test.gd` finale failures=0 (19 partecipanti dopo raccolta pistola), salvataggio/ricostruzione porte/boss/chiave/ambiente/pickup senza duplicati. Prima fixture attendeva troppo poco dopo equipaggiamento pistola: can_save rifiuta correttamente, test corretto per attendere fine azione e non caricare file residuo. `regia_render_test.gd` Forward+ D3D12 failures=0, clic reale sul monitor salva, foto PC e battente aperto/chiuso controllate; luce foto solo test. Demo suite INVENTORY_SAVE_TESTS_OK; passaggio Bruno failures=0, root Z=17.61. Tutti gli slot automatici in `.godot`; salvataggi utente non toccati. Warning headless certificati/lampione storici distinti dagli esiti.

**Continuità:** nuova REGIA_MAP_INTEGRATION e aggiornamenti indice/stato/architettura/backlog/procedura/nota inventario. Prova processo separato riportata di seguito; playtest completo utente mappa aperto. Direzione bagno default verso sinistra da confermare; scorrevoli senza nuovo audio assegnato, battente suoni metallici esistenti. Nessun commit/staging/push. Prossimo passo F6, giocare intro/boss, E chiave/porte/PC, Salva, pausa/Carica, C/N e riapertura; correggere solo riscontri concreti.

**Consolidamento finale integrazione regia:** processo nuovo `--continue-test` exit 0, REGIA_CONTINUE_TEST failures=0; snapshot del processo precedente ripristina porte/boss/chiave e non respawna pistola/drop raccolti. Mappa finale SHA256 `F012A46A060A022B0F686FADCA3F65F62C8E85EE00E25DF9EC132B727E173D4E`. SaveManager/boss.gd/intro e scena boss invariati rispetto all'inizio dell'integrazione; staging vuoto. Foto porta con luce temporanea mostrano pannello e maniglie solidali; nessuna luce aggiunta alla mappa. Backlog B15/B16/B18 aggiornato a integrato/testato tecnicamente, conferma utente mappa aperta.

## 2026-10-10 — attraversamento scorrevole con collider player reale

**Segnalazione:** porta aperta ma player non passa. Obiettivo correggere l'ostacolo reale, senza cambiare geometria. Riletti integrazione, note, collider/controller player e stato Git; staging vuoto, branch dev/prototype-0.1. Mappa risalvata dall'utente prima dell'intervento: hash iniziale `10F8FD1EE45FED9C8CF7826CAC423219923FCA9F964FF467D2E3CC9EE54A6262`.

**Diagnosi:** nuovo test sweep PhysicsServer3D.body_test_motion sul player vero: laboratorio urta Parete Lab sugli stipiti in entrambe le direzioni; bagno Parete_015. Capsula raggio 0.40, diametro 0.80 contro vano circa 0.795. Pannello già traslato, vecchi collider pannello disabilitati come previsto. Copertura precedente apertura/restore insufficiente a dimostrare attraversamento, ora aggiunta.

**Modifica:** `regia_map_integration.gd` duplica shape del solo player di questa mappa, export player_passage_radius=0.35; altezza/crouch/camera/input/velocità preservati. Nessuna patch a player.gd/player.tscn/mappa/porte visive. Nuovo `scripts/tests/sliding_passage_test.gd`. Prima prova corretta libera laboratorio in entrambe le direzioni; traiettoria lunga del bagno urta il mobile Duravit oltre il vano, test limitato al solo attraversamento (±0.55 m) senza alterare il mobile.

**Continuità:** nota regia, stato, architettura, procedura e backlog aggiornati; esito finale seguito sotto. Conferma utente aperta, serve fermare con F8 e riavviare F6 per applicare shape nella setup, poi provare il passaggio. Nessun commit/staging/push.

**Esito finale attraversamento:** SLIDING_PASSAGE_TEST failures=0, exit 0, quattro sweep aperti liberi (lab/bagno, entrambi i lati); porte chiuse bloccanti. Mappa/player scena/script invariati rispetto alla lettura iniziale di questa correzione; solo integrazione e test modificati. Warning ambientali separati dai risultati, staging vuoto. Playtest utente F8/F6 ancora aperto.

## 2026-10-10 — conferma passaggio e nuovi asset Carica salvataggio

**Riscontro/richiesta:** «perfetto ora funziona», dopo riparazione attraversamento scorrevole; l'utente fornisce immagini del pulsante Carica salvataggio nello stile degli altri e chiede di salvare gli MD per un'altra sessione.

**Stato confermato:** attraversamento TESTATO UTENTE. Bocca Bruno e passaggi precedenti già confermati. Regia integrata (chiave/drop, tre porte, PC e partecipanti persistenti), test automatici mappa/GPU/processo separato passati; nessuna conferma specifica nuova su salvataggio/C/N/riavvio manuale. Raggio player 0.35 locale alla mappa, altezza/controller/camera conservati.

**Asset verificati:** `assets/ui/caricasalvataggio.png`, 973123 byte; `assets/ui/caricasalvataggio_blob.png`, 2281761 byte. Ricevuti dall'utente e presenti nel workspace. Il menu iniziale genera `Continue`/CARICA SALVATAGGIO in main_menu.gd con menu_button.gd; pausa usa pause_menu.gd. Nuove immagini ancora da collegare: questa chiusura modifica solo documentazione.

**Git/verifiche:** dev/prototype-0.1, HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c, staging vuoto. Verificata presenza asset e riferimenti UI, riletti MD interessati; nessun nuovo runtime necessario per aggiornamento documentale. Nessun commit/push o salvataggio utente modificato. Aggiornati stato/indice/backlog/nota regia/inventario e registro.

**Ripresa concreta:** leggere indice, stato e questa voce, poi integrare normale/blob nei menu iniziale e pausa secondo grafica degli altri pulsanti. Prima leggere scene e script UI completi, verificare Git/locali, alpha/margini e proporzioni delle immagini, comportamento hover/focus/disabilitato. Conservare logica has_disk_save/has_scene_save e caricamento/slot. Prova successiva mappa: E chiave/porte/PC, Salva, pausa/Carica, morte C/N e riavvio. I test e gli slot fixture restano in `.godot`, quelli reali principale/demo distinti. Non rifare bocca/porte già approvate senza riscontro concreto.

## 2026-10-10 — immagini Carica salvataggio e ordine menu

**Richiesta:** collegare subito le due immagini ai menu per provarle; Nuova partita deve stare sopra Carica salvataggio.

**Intervento:** letto menu_button.gd completo e main_menu.gd completo, confrontate modifiche locali con Git e verificato VBox scene. Aggiunto mapping CARICA SALVATAGGIO → `caricasalvataggio.png` / `caricasalvataggio_blob.png` al controller condiviso; move_child Continue da indice 0 a 1. Nessuna patch pausa necessaria: entrambi i pulsanti già usano menu_button.gd. Crop alpha, scala 34 px di altezza visibile, hover/focus e audio riusati. Logica caricamento/slot/disabled conservata.

**Verifica:** script temporaneo `.godot/menu_asset_check.gd`, Godot headless, exit 0, LOAD_MENU_ASSETS_OK=true; normali/blob caricati su Continue e PauseMenu/LoadSave, dimensione normale (241.8719,34), NewGame primo e Continue secondo. Warning ambientale certificati separato. Non è un controllo visivo GPU né conferma utente della resa.

**Continuità:** aggiornati stato/backlog/indice/nota regia e registro. Il precedente prossimo passo di collegamento è completato; ora F6 main_menu o F5, poi pausa in gioco per confronto grafico. Nessun commit/staging/push; prova salvataggio nella mappa rimane aperta.

## 2026-10-10 — caricamento condiviso e grafica blob

**Richiesta:** Carica partita deve mostrare caricamento come Nuova partita; schermata e animazione coerenti con menu/HUD. Utente conferma funzionamento immagini menu.

**Baseline:** dev/prototype-0.1, HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c. SceneTransition senza differenze Git preesistenti; SaveManager locale non tracciato letto integralmente. Working directory contiene altri cambiamenti conservati; nessuno staging/commit/push.

**Diagnosi/intervento:** SaveManager caricava sincronicamente prima di cover_black, nascondendo il pannello. Ora usa load_scene threaded condiviso; copertura resta durante inizializzazione e ripristino, con process ALWAYS durante pausa. scene_transition.gd aggiunge stage, progressione interpolata e recupero errori B07; scripts/ui/loading_blob.gd disegna blob deformabile e bolle orbitanti. Cornice/tema inventario e menu riusati, responsive, dissolvenze e durata minima leggibile. Persistenza e priorità restore conservate.

**Verifiche:** loading_transition_test.gd passato Forward+ D3D12 RTX4060, screenshot .godot/loading_screen.png ispezionato. Test provoca intenzionalmente errore risorsa non PackedScene e verifica overlay liberato, poi transizione valida. Prima prova rilevava triangolazione contorno duplicato: corretto fill senza vertice finale duplicato; GPU finale senza errori grafici. Regressione inventario/save e restore mappa: risultati nella chiusura seguente. Warning certificati e risorse/ObjectDB headless distinti dalle verifiche funzionali. Nessun salvataggio utente sovrascritto.

**Regressione finale:** inventory_save_test.gd dopo correzione grafica: INVENTORY_SAVE_TESTS_OK, exit 0. Nessun errore di triangolazione; restano warning headless certificati, 2 ObjectDB e 1 risorsa a uscita.

**Mappa processo separato:** regia_map_test.gd -- --continue-test: REGIA_CONTINUE_TEST failures=0, exit 0; porte aperte, boss sconfitto, chiave inventario e pickup non duplicati ripristinati con nuovo loader. Restano warning SparksElectric opzionale mancante e 44 ObjectDB a uscita. Slot fixture .godot conservato, nessun file utente modificato. git diff --check passato (avvisi conversione CRLF).

**Documenti:** stato, architettura, backlog B07, procedura e registro aggiornati. Prossimo passo: provare F5 Nuova partita e Carica iniziale/pausa, poi C dopo morte nella mappa. Conferma estetica utente della nuova schermata ancora aperta.

## 2026-10-10 — semplificazione cornice caricamento

Utente approva animazione centrale e chiede il senso della barra sinistra/superiore: erano decorazioni ereditate dalla cornice inventario. Aggiunto show_decorations con default true in blob_inventory_panel.gd, false nel solo scene_transition.gd; disattiva striscia superiore e accenti disegnati, conserva bordo e glow. Inventario invariato. Letti integralmente entrambi gli script e confrontato diff locale del loader con Git: differenze della precedente sessione conservate. Nessun commit/staging/push. Verifica GPU con loading_transition_test.gd e screenshot; conferma utente della pulizia da ricevere.

## 2026-10-10 — chiusura e continuità nuova sessione

**Richiesta/conferma:** «ok ci siamo, aggiorna gli md, cosi posso fare una nuova sessione»; registrata approvazione utente della schermata caricamento finale senza decorazioni laterali/superiori. Animazione centrale approvata. Menu Carica e ordine pulsanti già confermati.

**Stato consolidato:** bocca Bruno, attraversamenti, chiave/drop, porte regia e PC integrati. Loader condiviso per nuova partita/salvataggio, schermata grafica approvata. Test della precedente implementazione: INVENTORY_SAVE_TESTS_OK; REGIA_CONTINUE_TEST failures=0; LOADING_TRANSITION_TEST_OK in Forward+ D3D12 dopo pulizia cornice, screenshot ispezionato. Errore risorsa non PackedScene intenzionale nel test recupero; warning ambientali/uscita già documentati. Conferma UI non estesa a C/N e riavvio manuale nella mappa.

**Intervento documentale:** aggiornati README, CURRENT_STATE, DECISIONS_AND_BACKLOG e SESSION_LOG con punto di ripresa prevalente sulle note storiche superate. Nessuna modifica gameplay o nuovi test runtime necessari in questa chiusura.

**Git:** branch dev/prototype-0.1, HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c verificati; staging vuoto. Nessun commit/push. Documenti e molti asset restano nella working directory locale.

**Ripresa:** leggere AGENTS, indice, baseline, standard, stato, backlog, ultima sessione e architettura/procedura pertinenti; verificare Git/file reali. Non rifare bocca, porte, immagini menu o caricamento approvati. Eventuale prossimo passo: accompagnare playtest completo salvataggio nella mappa (PC, pausa/menu Carica, morte C/N, riavvio); avviarlo solo su richiesta della nuova sessione. Altri cambiamenti da scegliere con l'utente.

## 2026-10-10 — commit locale delle risorse di sviluppo

**Autorizzazione:** utente richiede commit Git, escludendo binari e modelli. Selezione: script .gd/.uid, scene .tscn, shader .gdshader/.uid, risorse testuali .tres, project.godot e Markdown/AGENTS. Esclusi audio, immagini, modelli, animazioni .res, PDF, cache, salvataggi, pacchetti e cancellazioni SilverDelivery. Nessun push.

**Baseline/limiti:** partenza dev/prototype-0.1 / e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c, index inizialmente vuoto. Scene mappa/boss mantengono riferimenti agli asset locali esclusi: commit di sviluppo, non backup completo. File fuori selezione conservati senza reset/clean. Controllare elenco e diff cached prima del commit; identificativo finale dal git log. Test funzionali della sessione precedente documentati; consolidamento Git non modifica gameplay.

**Risultato:** commit 5b3267e creato con 107 file, 10922 inserimenti e 2150 rimozioni testuali. Controllati cached stat/numstat/diff dei collegamenti principali; nessun binario o cancellazione staged. diff --cached --check segnala solo blank-at-eof in tre MD; controllo con esclusione di quella regola passato. Registrazione del risultato in stato/registro con commit documentale successivo. Nessun push effettuato.

## 2026-10-10 — ripresa salvataggi e diagnosi uscita laboratorio Bruno

**Richiesta:** rileggere continuità, verificare Git/locali, preservare bocca/porte/menu/caricamento approvati; accompagnare ciclo PC, Carica pausa/menu, morte C/N e riavvio. Nuova segnalazione Bruno incastrato nel muro della porta durante combattimento.

**Baseline:** dev/prototype-0.1, HEAD `2ac4a5fb0953e633915ed862b7942ec3d86771c5`, staging vuoto. Nessuna differenza iniziale di codice/scene rispetto a HEAD. Sei audio modificati, cancellazioni SilverDelivery e asset locali esclusi preservati. Mappa 26.931.837 byte, SHA256 `B18A6DDD4A7F222C431C04F257403BE6309C85183F7B37DB4E0A90E0E9D7D1C4`; controller Bruno SHA256 `F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA`.

**Fonti:** AGENTS, indice, baseline, standard, stato/backlog/ultima sessione, architettura/procedura, note collisione/regia/inventario; letti integralmente integrazione regia, porta battente/scorrevole, SaveManager, PersistentObject e diagnostiche pertinenti, override reali porte/parete nella mappa e logica movimento pertinente Bruno.

**Diagnosi/verifiche:** nuova `scripts/tests/bruno_lab_exit_diagnostic.gd` registra per 20 s movimento, apertura forzata e collisioni di Bruno reale dal marker finale intro. Eseguita headless Godot 4.7.2/audio Dummy prima con player spawn, poi (6.8, 0.9, 26). Entrambi exit 0; Bruno supera porta esterna, Z finale 19.16057 e 18.25315. Soste accompagnate da attacchi pallina; urti registrati pavimento con normale +Y, nessun muro porta. Log `.godot/bruno_lab_exit.log` e `.godot/bruno_lab_exit_far.log`. Warning certificati/SparksElectric già noti. Sono tracce diagnostiche, non suite con asserzioni né playtest completo intro/fasi. Segnalazione **aperta/non riprodotta**, richiesta asincrona per identificare porta e stato aperto/chiuso.

**File/stato:** solo nuova diagnostica e note CURRENT_STATE/BRUNO_PASSAGE_COLLISION/SESSION_LOG; nessuna patch gameplay o salvataggio utente. Diagnostica rinominata da bruno_lab_exit_test dopo esecuzione per evitare di presentare la traccia come test con asserzioni; variante player lontano selezionabile con --far-player. Preparata procedura manuale PC → alterazione stato → Carica pausa/menu → morte C → morte N → riavvio/Carica. Il checkpoint è manuale e N conserva il file. Conferma utente del ciclo mappa ancora aperta.

**Git/prossimo passo:** nessun staging/commit/push. Precisare porta, posizione player e fase del blocco, riprodurre prima della correzione; completare playtest salvataggi con riscontri utente.

## 2026-10-10 — implementazione puzzle rete regia, racchetta e uscita aliena

**Autorizzazione/decisioni:** utente approva piano e richiede implementazione. Desktop Windows 10, login Fritz admin/admin2026, PPPoE narcisolo/ottavonano con switch alimentato/cablato per Online, WiFi aperto, due cavi recuperabili totali, alimentazione Connesi per PC/caricatore/router/switch; chiusura autonoma. Libro lasciato in regia. Successiva correzione esplicita: la chiusura aliena NON scompare, resta agganciata al battente che riapre senza password. Conferma versione precedente «funziona tutto», Bruno non bloccato; archiviare il riscontro sporadico fino a ricorrenza.

**Baseline/fonti:** dev/prototype-0.1 / 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. Mappa aggiornata dall'utente 21:32:10, 26.938.925 byte: addon, override player e override verso vecchio Portatile. Confrontato diff prima degli interventi. Letti integralmente script comuni modificati e componenti pertinenti, note regia/collisioni/salvataggi. Ispezionati GLB JSON e scene importate, rendering isolato delle mesh e triangoli/cerniera; path runtime uscita verificato Porta Regia_001. Quattro nuove immagini utente docs/FritzHome.png, FritzLogin.png, FritzPPPoE.png, FritzWiFi.png lette come riferimento grafico e conservate; dati domestici non incorporati nel gioco.

**Implementazione:** nuovi controller regia_network_state/puzzle, wrapper interagibili/porta aliena, terminale Windows/browser/Fritz/alieno, pannello documenti/scelte, esame racchetta 3D, glifi Wingdings e icone native WiFi/Chrome. Nuovi item portatile/cavo/racchetta registrati prima del restore. Setup in regia_map_integration; GameplayUI estesa con pannelli/ritorno inventario e contratto opzionale requires_save_eligibility, default ConnesiOS invariato. Collegamenti fisici visivi e LED; due interruttori operativi; drop unico finale dalla mano e texture manico variante applicata solo a copie/materiali runtime. Stato main.regia.network priority 30, porta main.door.regia_exit; salvataggi vecchi recuperano racchetta dopo restore di boss sconfitto. SaveManager/schema/loader/controller boss/intro/scena boss invariati.

**File:** 14 nuovi .gd (+UID) sotto scripts/interactables/systems/ui/tests/tools con prefisso regia_ e build_regia_racket_texture.gd; tre item resources/items/{regia_laptop,network_cable,bruno_racket}.tres; assets/textures/regia_racket_handle.png e .res (95.241 byte compressi, pre-caricato anche per export). Modificati inventory_manager.gd, regia_map_integration.gd, gameplay_ui.gd. Mappa: tolte solo tre righe dell'override su Portatile realmente scomparso; 81 righe di aggiunte utente restano rispetto a HEAD. Nessuna riscrittura/reimportazione GLB originale. Wingdings 3 locale, cmap convertita in memoria; font commerciale non copiato nel repo.

**Test/esiti:** REGIA_NETWORK_STATE_TEST failures=0 (mancanze, limiti cavi, ordini, errori credenziali, WLAN protetta/aperta, latched unlock e snapshot/glifi). GPU Forward+ D3D12 RTX4060 REGIA_NETWORK_MAP_TEST failures=0: documenti, PC scarico/boot/vero zoom/Esc, clic proiettati Chrome/login/PPPoE/WiFi, luci, drop/raccolta/esame, password fisica, sweep player chiuso/aperto e chiusura solidale a battente riaperto, salvataggio/restore. REGIA_TERMINAL_RENDER_TEST failures=0 per UI finale dai riferimenti (corretti contrasto checkbox attiva e feedback dentro finestra). PNG network_*/network_ui_* e racket_pose_0–3 in .godot ispezionati, manico leggibile ruotando. Processo nuovo REGIA_NETWORK_CONTINUE_TEST failures=0; variante intermedia REGIA_NETWORK_PARTIAL_TEST failures=0, puzzle riprendibile con un cavo disponibile e router ancora non configurato. INVENTORY_SAVE_TESTS_OK; SLIDING_PASSAGE_TEST failures=0 (quattro attraversamenti); BRUNO_PASSAGE_TEST failures=0, root Z=14.60089. Nessuno slot utente scritto.

**Correzioni/limiti:** prima fixture documenti disabilitava fisica player e UI rifiutava correttamente; test corretto. Ispezione GPU ha richiesto ricalibrazione tasti e coperchio/schermo PC. Lettura PNG grezzo sostituita da risorsa Godot compressa per evitare warning/export incompatibile. Due prove headless concorrenti esaurivano memoria e causavano errori allocazione/crash in caricamento bocca/laptop; ripetizioni sequenziali passate, asset originali conservati. Da ora una suite mappa alla volta. Warning certificati/SparksElectric storici e 45 ObjectDB a uscita del restore headless distinti dalle asserzioni. Nessuna build/export effettuata; font locale necessario. Nuovo puzzle non ancora TESTATO UTENTE e test non certificano tutta la cinematica/fasi giocate normalmente.

**Consolidamento:** mappa SHA256 C135B2224F834A7C471B2C67428D327B7DBF664E93204F7A22D8032747EB29DB. Bruno.gd SHA256 F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA invariato; intro/SaveManager/scena boss senza diff Git. git diff --check passato (avvisi LF→CRLF), staging vuoto, nessun commit/push. Aggiornati README/CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG B20/WORKFLOW_AND_TESTING e nuova REGIA_NETWORK_PUZZLE.

**Ripresa:** F8/F6 map_test; playtest utente dal drop Bruno a portatile/appunti/caricatore/cavi/configurazione/WiFi/password/uscita, poi save/Carica/C/N/riavvio. I sistemi approvati restano preservati; intervenire sui riscontri concreti.

## 2026-10-10 — chiusura documentale dopo crash della finestra

**Richiesta utente:** salvare tutto negli MD per aprire un'altra sessione, comprese le istruzioni finali che non ha letto. Nessuna nuova modifica gameplay richiesta durante questa chiusura.

**Stato e limiti:** puzzle rete regia implementato e test tecnici descritti nella voce precedente; playtest utente ancora aperto. La chiusura aliena resta agganciata al battente dopo lo sblocco permanente, con aperture successive senza password. Bocca Bruno, porte, menu e caricamento approvati da preservare. Crash della finestra segnalato dall'utente, senza identificazione della finestra o diagnosi della causa: non confonderlo con i precedenti test concorrenti esauriti per memoria.

**File aggiornati:** CURRENT_STATE.md e README.md riportano la chiusura prevalente; REGIA_NETWORK_PUZZLE.md conserva esplicitamente le istruzioni non lette: F8/F6 map_test, E/I/Esc, esame racchetta e guida completa, poi salvataggio al PC ConnesiOS, Carica pausa/menu, morte C/N e riavvio F5/Carica. SESSION_LOG.md conserva questa richiesta e il punto di ripresa. Implementazione, decisioni, architettura, file e verifiche sono già documentati nella voce precedente e nei documenti collegati.

**Verifiche/Git:** riletti documenti e stato locale; branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. Working directory e asset locali restano da conservare. Controllo diff documentale; nessun nuovo test runtime per questa sola chiusura. Nessun commit, staging o push.

**Prossima sessione:** leggere AGENTS, indice, CURRENT_STATE, questa ultima voce e REGIA_NETWORK_PUZZLE; verificare Git e file reali. Ripresentare all'utente le istruzioni salvate, accompagnare il playtest e intervenire solo sui riscontri concreti. Non ripetere l'implementazione già completata e non assumere approvazione del nuovo puzzle.

## 2026-10-10 — revisione visiva puzzle regia dopo playtest utente

**Richiesta/conferma:** utente «funziona la logica», chiede portatile sulla scrivania sinistra vicino al Fritz, LED reali senza legenda aggiunta e zoom E sul router collegato, rimozione suggerimenti espliciti dagli oggetti, desktop nitido, alfabeto alieno distinguibile condiviso anche dai messaggi, cavi meno tesi e chiave key_with_tag più visibile. Conferma della logica registrata senza dedurre una prova manuale completa di salvataggio o approvazione della nuova resa.

**Baseline/fonti:** letti AGENTS e documenti di continuità, script integrali modificati, diff tracciati e asset reali. Branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. Differenze locali precedenti conservate, inclusi audio Bruno, cancellazioni SilverDelivery, addon e impostazioni locali delle luci. Mappa SHA256 48CA197F9BCB4817D89D25F1AA1AF904ADFB30D543C28D44ADD8B18BA96705F8, nessuna patch alla scena in questa revisione. Ispezionati quattro PNG Fritz in docs, preview reale del router, atlante diffuse e bounding box scrivanie/portatile. Licenza locale key_with_tag CC-BY-4.0 letta, attribuzione salvata.

**Interventi:** deposito portatile (8.73, 1.005, 4.65) su ScrivaniaRegia, quota piano 0.944448; posizione ricostruita anche al restore. LED aderenti alle finestrelle originali via UV: Power/Internet alimentazione, WLAN radio, Info connessione; Fon/DECT e Connect/WPS preservati spenti, nessuna scritta nuova. RegiaRouterView riusa zoom/pausa/Esc del terminale, pulsante Collegamenti ritorna al menu cavi; clic inoltrato esplicitamente prima della GUI consumata da GameplayUI. Desktop 1920×1080 da coordinate logiche 1024×576, Segoe UI MSDF, sfondo e icone nativi, browser chiaro e stile Fritz dai riferimenti; proiezione mouse aggiornata nei test. Dodici lettere armene Sylfaen sostituiscono Wingdings; didascalie, cancellazione e feedback alieni nello stesso alfabeto, tastiera riallineata, texture racchetta rigenerata con identici indici password. Rimossi indizio sul manico e ubicazione dello spazio/caricatore dalle descrizioni. Cavi campionati Curve3D, gioco sul tavolo/pavimento, innesti sul fianco reale del laptop; rettificato percorso lontano dalle ciabatte dopo ispezione. KeyWithTag reale 0.34 m nel pickup, raccolta/ID/persistenza invariati.

**File:** regia_network_puzzle.gd, regia_network_terminal.gd, regia_alien_glyphs.gd, regia_racket_inspection.gd, inventory_item_pickup.gd; descrizioni regia_laptop.tres/bruno_racket.tres; texture manico PNG/.res (risorsa 99.826 byte). Nuovi regia_router_view.gd, regia_windows_wallpaper.gd, regia_desktop_icon.gd e UID. Aggiornati tre test regia. Documenti CURRENT_STATE/README/ARCHITECTURE/DECISIONS_AND_BACKLOG/WORKFLOW_AND_TESTING/REGIA_NETWORK_PUZZLE/SESSION_LOG e nuovo ASSET_CREDITS.md. Diagnostiche e screenshot temporanei sotto .godot.

**Verifiche:** REGIA_NETWORK_STATE_TEST failures=0, dodici glifi presenti; generatore manico result=0. REGIA_TERMINAL_RENDER_TEST finale failures=0 GPU D3D12: desktop Full HD, clic Chrome/login/PPPoE/WiFi, assenza testo latino/italiano su display alieno e feedback errato. REGIA_NETWORK_MAP_TEST finale failures=0 GPU: deposito vicino Fritz, zoom E e clic Collegamenti/Esc, PC, cavi, configurazione, chiave reale, drop/esame, tastiera, sblocco permanente con chiusura solidale, save/restore. INVENTORY_SAVE_TESTS_OK (compresi C/N), SLIDING_PASSAGE_TEST failures=0 nelle quattro direzioni; BRUNO_PASSAGE_TEST end=(6.45443, 0.08938, 14.60089) failures=0. Log revision_state/ui/inventory/sliding/bruno e regia_network_map_test in .godot. Immagini network_ui_* e network_fritz_zoom/desk_cables/power_cable/key_with_tag/alien_initial ispezionate; foto sottopiano finale non inquadra tutto il percorso dell'alimentatore, verificare anche girando nella mappa. Nessuno slot utente scritto. git diff --check passato.

**Correzioni e limiti:** primo render UI aveva inferenza non valida nell'array Vector2 del nuovo wallpaper; corretto e ripetuto con esito zero. Chiusi solo i processi di quel test rimasti aperti, editor utente conservato. Test mappa sequenziali; warning certificati/risorse a uscita storici separati dai risultati. Font Sylfaen locale non redistribuito, export non provato. Nuova resa richiede conferma utente; nessuna modifica ai controller Bruno, intro, SaveManager, loader o HUD. Bruno.gd SHA256 F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA invariato. Nessun staging/commit/push.

**Ripresa:** F8, aprire scenes/maps/map_test.tscn, F6. Provare deposito sulla scrivania sinistra, E sul Fritz cablato → zoom e Collegamenti/Esc, desktop/glifi/racchetta, cavi dalla vista player e chiave. La chiusura aliena resta agganciata e apre successivamente senza puzzle; logica approvata da conservare. Ricevere riscontri estetici concreti, poi proseguire con le altre modifiche scelte dall'utente.

## 2026-10-10 — kit portatile riutilizzabile, icone/esame e libri 3D

**Richiesta/conferma:** utente «molto meglio», cavi approvati una volta ruotato il PC. Richiesti display grande quanto monitor, orientamento sedia rossa, Ethernet SX/corrente DX, descrizioni prive di suggerimenti, caricatore raccoglibile/installabile alla ciabatta, arresto consentito solo dopo enigma e raccolta congiunta PC/caricatore per i prossimi enigmi. Richieste icone per tutti gli item, esame key/cavi e lettura realistica di notebook/libro con texture delle pagine; nel libro solo glifi e WiFi dopo sfogliatura, senza storia del cerchio.

**Baseline/fonti:** AGENTS, indice/stato/ultima sessione, standard/backlog/architettura/test e guida letti; script integrali e diff locali confrontati. Branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. Conservati audio, asset, cancellazioni e scene locali precedenti. GLB JSON e probe GPU dell'addon: Notebook chiuso con texture Image_0_14.jpg, LibroRegia aperto con Book_Base_Color.png; atlanti ispezionati. Ciabatta tabletop reale importata come connesi_building_test2/root, presa ricavata dalla sua posizione; extention_cord e monitor/torre ispezionati in GLB per evitare sovrapposizioni. Nessuna modifica alla scena mappa, SHA256 48CA197F9BCB4817D89D25F1AA1AF904ADFB30D543C28D44ADD8B18BA96705F8.

**Interventi:** PC runtime 2.5× anche prima del pickup, display circa 0.7125×0.4425 m. Deposito (8.75, 1.088, 4.90), Y=PI, fronte alla sedia; spostato davanti al monitor fisso per non attraversarlo, base circa 3 cm oltre il bordo. Innesti ai due fianchi da transform/coordinate originali: rete SX, DC DX. Caricatore originale E → item regia_charger; E PC con item lo consuma e crea scatolina nera sul tavolo, due cavi curvi verso DX PC/ciabatta. Primo E senza caricatore apre e mostra PC scarico; ordine caricatore-prima o dopo supportato. Start/Arresta: prima «Ancora mi serve, non posso spegnerlo.»; dopo soluzione chiude PC e restituisce FPS, E raccoglie kit e recupera il solo cavo PC. Uplink, configurazione e porta sbloccata conservati; ri-deposito «Non c'è più bisogno ora.». Nuovi bool charger_collected/laptop_shutdown/laptop_recovered persistiti; vecchio connected implica raccolta, schema SaveManager invariato. Recupero con verifica di tutte le capienze prima delle mutazioni.

**Inventario/documenti:** cinque item con icone SVG native, incluse notifiche, e descrizioni brevi neutre; key/cavo/caricatore/PC/racchetta esaminabili in viewport 3D privato, rotazione/pan/zoom e ritorno all'inventario. Chiave usa modello reale, cavo e caricatore geometria nativa, PC copia delle sole mesh, racchetta variante esistente. RegiaBookReader costruisce libro aperto 3D con fogli curvi, spessore e copertine: texture delle pagine reali del libro e copertina del notebook riusate, fogli del quaderno ricostruiti a righe con Segoe Print e annotazioni blu. Tre aperture aliene, pagina animata avanti/indietro e rotella/frecce; WiFi solo all'ultima. Nessuna spiegazione della protezione/password e nessuna patch agli oggetti originali in mappa.

**File:** regia_network_state.gd, regia_network_puzzle.gd, regia_network_terminal.gd, inventory_manager.gd, gameplay_ui.gd, regia_racket_inspection.gd; descrizioni dei quattro item precedenti e nuovo resources/items/regia_charger.tres. Nuovi scripts/ui/regia_item_icons.gd, regia_item_visuals.gd, regia_book_reader.gd e UID. Ampliati regia_network_state_test/map_test; nuovo regia_book_reader_test.gd/UID. Aggiornati README/CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG/WORKFLOW_AND_TESTING/REGIA_NETWORK_PUZZLE/SESSION_LOG. Probe e immagini in .godot.

**Verifiche finali:** REGIA_NETWORK_STATE_TEST failures=0 per ordini/mancanze/consumo/recupero, arresto vietato/consentito, duplica/ri-deposito, icone e snapshot legacy/kit. REGIA_NETWORK_MAP_TEST failures=0 GPU Forward+ D3D12: orientamento/scala/innesti, caricatore in inventario/installazione E, clic Start/Arresta prima e dopo, chiusura/uscita, raccolta kit/cavo, lettore, ispezione dei cinque item, puzzle/porta solidale e salvataggio/ripristino. REGIA_BOOK_READER_TEST failures=0 GPU: avanti/indietro, WiFi nell'ultima apertura e presenza credenziali; immagini native book_reader_* finali ispezionate. REGIA_NETWORK_PACKED_TEST failures=0 in nuovo processo headless: kit/inventario/cavi/visibilità/sblocco ripristinati. INVENTORY_SAVE_TESTS_OK compresi C/N, SLIDING_PASSAGE_TEST failures=0 quattro direzioni, BRUNO_PASSAGE_TEST end=(6.522174, 0.048755, 16.78725) failures=0. Slot test originale pre-raccolta conservato, nuovo .godot/regia_network_packed_slot.cfg; nessuno slot utente scritto. Log portability_state/packed/inventory/sliding/bruno, regia_network_map_test e regia_book_reader_test.

**Correzioni/limiti:** primo controllo direzione test eseguito col coperchio ancora chiuso, spostato dopo apertura; non era prova dell'orientamento in uso. Rendering iniziale mostrava pagina sinistra nera per winding: corretto, camera/volume ingranditi e testi impaginati per leggibilità. camera_target ora usa up del display, valido anche chiuso nelle foto di test. Dopo ispezione spostato PC davanti al monitor fisso, esame oggetti orientato dal lato superiore. Warning certificati/SparksElectric e ObjectDB a uscita persistono; restore kit segnala 47 ObjectDB/1 risorsa, distinto dai risultati delle asserzioni. Font locali Windows non redistribuiti; nessuna build/export o nuovo playtest utente effettuati. Controller Bruno/intro, SaveManager, loader, HUD inferiore e asset approvati conservati; Bruno.gd hash F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA invariato. git diff --check passato; nessun staging/commit/push.

**Ripresa/manuale:** F8, map_test, F6. Provare grandezza/fronte sedia/innesti SX-DX; prendere caricatore e PC in entrambi gli ordini, depositare e usare E; leggere quaderno e sfogliare libro (frecce/rotella), I/Esamina su tutti gli item. Prima soluzione provare Start/Arresta rifiutato; dopo password corretta tornare al PC, Start/Arresta → uscita/coperchio chiuso → E kit in inventario → ri-deposito rifiutato. Confermare nuova resa e ciclo completo manuale salvataggi; conservare sblocco definitivo con chiusura solidale.

## 2026-10-11 — alimentatore Fritz, portatile ridotto e uscita regia sicura

**Richiesta/conferma:** «tutto perfetto» per la revisione kit/documenti precedente. Nuova richiesta: alimentatore Fritz già collegato alla ciabatta come solo prop, cavo bianco/grigio; PC un po' più piccolo; uscita verso l'interno della regia su cardine DX e arretramento automatico solo da quel lato; niente spoiler sulla chiave Bruno prima della comparsa. Domanda sulla possibilità di ridimensionare la chiusura aliena.

**Baseline/fonti:** AGENTS, indice, baseline SAFE, standard, stato, backlog, architettura, procedura, guida e ultima sessione; script integrali e riferimenti reali letti. Git dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. sliding_door.gd uguale a HEAD prima del singolo cambio notifica; nuovi script puzzle non tracciati già presenti. Mappa e Bruno conservati, SHA256 rispettivamente 48CA197F9BCB4817D89D25F1AA1AF904ADFB30D543C28D44ADD8B18BA96705F8 e F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA. Asset/audio/cancellazioni locali precedenti preservati. JSON del GLB letto senza modifiche, atlante Fritz e screenshot ispezionati.

**Interventi:** NetworkPuzzle genera FritzPowerAdapter sulla presa centrale della ciabatta originale building/root, scatolina bianca/grigia e cavo curvo grigio da 3 mm al DC originale, individuato tramite UV (1350,1533)/1600. Prop privo di collider/interazione, sempre presente anche dopo recupero kit. PC scala 2.5→2.1 (−16%), display circa 59.85×37.17 cm; deposito Y 1.0657 mantiene la base sul tavolo. Orientamento sedia e innesti rete SX/DC DX conservati; cavi ricalcolati dal medesimo transform. Uscita aliena: pivot su world X massimo, destro guardando verso l'uscita dalla regia, angolo +90 porta il battente verso +Z/interno. RegiaAlienExitDoor verifica player vicino dal lato +Z, spazio dietro con body_test_motion e arretra con move_and_collide prima di aprire. Controller fisico ripristinato al valore precedente, pausa ferma movimento, morte/cambio scena interrompono; salvataggio bloccato durante arretramento. Dall'altro lato o già lontano nessun movimento del player. Percorso ostruito: notifica e porta ferma. Chiusura sempre solidale al battente, sblocco permanente conservato. Notifica della scorrevole ora «Serve una chiave.» anche dopo la comparsa: nessuno spoiler, logica/chiave invariata.

**Scala chiusura:** camera_target alieno usa gli assi scalati dello schermo, così zoom e spostamento del centro seguono la scala uniforme. Monitor/LED/etichette già figli della mesh; hit-test già in spazio locale con trasformazione inversa. Modificare Scale del nodo prima di F8/F6 è supportato; applicare scala ai vertici/cambiare origine/re-esportare mesh può richiedere riallineamento delle coordinate locali. Non è stata ridimensionata la chiusura della mappa: scala 0.75 usata solo nella fixture.

**File:** scripts/systems/regia_network_puzzle.gd, scripts/interactables/regia_alien_exit_door.gd, scripts/interactables/sliding_door.gd, scripts/ui/regia_network_terminal.gd, scripts/tests/regia_network_map_test.gd. Aggiornati CURRENT_STATE/README/DECISIONS_AND_BACKLOG/ARCHITECTURE/WORKFLOW_AND_TESTING/REGIA_NETWORK_PUZZLE/SESSION_LOG. Nessuna nuova modifica a scene, player, Bruno, door.gd, SaveManager, loader o asset approvati.

**Verifiche finali:** REGIA_NETWORK_STATE_TEST failures=0 (.godot/refinement_state.log). REGIA_NETWORK_MAP_TEST failures=0 GPU Forward+ D3D12 RTX4060 (.godot/regia_network_map_test.log): dimensioni/fronte/innesti PC, prop Fritz, scala 0.75 e clic di tutti i dodici tasti, zoom, ciclo documenti/rete/drop/puzzle, arretramento iniziale e successive aperture, pausa, ripristino controller attivo/disattivo, lato opposto immobile, ostacolo che impedisce apertura, pivot destro/angolo interno, passaggio reale nelle due direzioni anche dopo save/restore, arresto/raccolta/ispezione kit. Render finale mostra battente sul lato destro della visuale dall'interno e caricatore sulla presa centrale. Ripristino kit in processo nuovo headless REGIA_NETWORK_PACKED_TEST failures=0 (.godot/refinement_packed.log); warning storici certificati/SparksElectric e 45 ObjectDB a uscita. Slot test .godot, nessuno slot utente scritto. Immagini network_fritz_power/desk_cables/alien_initial/exit_open ispezionate. git diff --check finale passato; hash mappa/Bruno e HEAD conservati, staging vuoto. Nuova conferma manuale ancora aperta; nessun export o test nuovo del combattimento richiesto da queste rifiniture isolate.

**Correzioni durante prova:** prima fixture GPU lasciava il controller disattivato dopo la prova lato opposto: salvataggio correttamente rifiutato, fixture corretta e ripetizione passata. Controllo visivo ha rilevato che il primo pivot era sul lato sinistro: spostato sul bordo destro effettivo, aggiunta verifica del lato del pivot e restore. Alimentatore inizialmente sopra l'estremità con interruttore: riposizionato sulla presa centrale e render ricontrollato. Nessuna conclusione basata solo sul valore dell'angolo.

**Ripresa/manuale:** F8, map_test, F6. Controllare alimentatore Fritz/curva cavo e PC più piccolo con innesti SX/DX. Risolvere il puzzle e provare E vicino alla porta dall'interno: arretramento e cardine destro; dal corridoio nessun arretramento. Provare pausa durante movimento e ritorno ai comandi; porta continua senza password, chiusura agganciata. Eventuale nuova scala uniforme della chiusura dall'editor → F8/F6 → verificare zoom/tutti i tasti. Conferma manuale della nuova rifinitura e ciclo esplicito salvataggi mappa ancora aperti. Nessun staging, commit o push.

## 2026-10-11 — conferma playtest ultime rifiniture

**Conferma utente:** «ok funziona tutto». La conferma segue l'implementazione delle rifiniture B20 della voce immediatamente precedente; registrata come prova manuale riuscita in mappa di alimentatore Fritz, portatile ridotto, apertura interna/cardine destro, arretramento automatico dal lato della regia e messaggio generico della scorrevole. Scala uniforme della chiusura verificata dall'utente nella resa finale del puzzle.

**Punto di ripresa:** il lavoro richiesto è completato. Non ripetere le rifiniture e preservare mappa locale, bocca Bruno, porte approvate e schermate/menu/caricamento. Alla prossima sessione rileggere AGENTS, CURRENT_STATE, questa voce e la guida regia; verificare Git e file reali, poi procedere sul nuovo obiettivo che indicherà l'utente. Il ciclo completo salvataggio nella mappa (PC, Carica da pausa/menu, morte C/N e riavvio) resta una prova distinta ancora da confermare: «funziona tutto» qui non è stato specificato come prova di ciascuna di quelle tappe. Nessun commit, push o staging.

## 2026-10-11 — approvazione finale denti Bruno

**Conferma utente:** «perfetto» dopo consegna V6. Arcate continue con texture e correzione bordo destro approvate; attività conclusa. Conferma della resa, senza dedurre nuove prove complete di combattimento o salvataggi. Aggiornati CURRENT_STATE/BRUNO_MOUTH_PREVIEW/DECISIONS_AND_BACKLOG e registro. Nessuna nuova modifica tecnica, staging, commit o push. Preservare V6 e riprendere dal prossimo obiettivo scelto dall'utente.

## 2026-10-11 — bordo destro nascosto e texture denti

**Richiesta:** utente «ci siamo quasi», bianco a DX visibile anche a bocca chiusa, chiede riduzione e texture. Implementata V6: estremo X 0.245→0.225, profondità aumentata gradualmente fino a 0.012 da X 0.17. Altezze/separazione approvate come direzione conservate. Texture nuova 512×64 `mouth_preview_v6/bruno_teeth_soft_divisions.png`, sei separazioni grigie sfumate, avorio e lieve gradiente verticale; generata tramite API immagini Blender e incorporata nel GLB/terza superficie. Geometria continua, nessuna fuga trasparente.

**Baseline/fonti/file:** stesso branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; diff dei due script confrontati con HEAD e lavoro locale delle voci precedenti. Generatore integralmente riletto, aggiornato via apply_patch; API Blender producono nuovi asset V6 senza patch automatiche ai file precedenti. HEAD_FILE dei due script completi preview/integrazione aggiornato. Varianti precedenti conservate. Mappa SHA256 BFC63E1AF1ED572D82BD2DDD25746ABE8DC74832294A413D46ADF974A3BE3CA9, controller boss F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA invariati.

**Verifiche:** Blender 5.2.1 export/render riuscito; Godot 4.7.2 Forward+ D3D12 RTX4060 `BRUNO_MOUTH_TEST failures=0`, max 0.780145, round 0.389733, smile 0.849991. Log `.godot/bruno_teeth_v6_test.log`. Probe grafico temporaneo `.godot/bruno_teeth_closed_probe.gd` produce render chiuso frontale/tre quarti, `BRUNO_TEETH_CLOSED_RENDER_OK`; immagine tre quarti ispezionata senza bianco sporgente e smile con texture visibile. Errore storico certificati distinto dalle asserzioni. Test completo mappa non ripetuto per geometria/texture, conferma utente finale aperta. Nessun staging/commit/push, asset locali/generatore/blend non sono backup Git. Documenti stato/backlog/architettura/guida e registro aggiornati.

## 2026-10-11 — arcate estese e più separate

**Richiesta:** utente «ci siamo quasi», segnala vuoto nero all'angolo destro e propone arcate un po' più separate. Nuova variante V5 conserva V4; fasce continue estese da [-0.106,0.171] a [-0.135,0.245] lungo X. Altezza visibile superiore 0.022→0.017 e inferiore 0.015→0.011 unità locali: aumenta separazione senza cambiare apertura bocca o audio.

**Baseline/file:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; differenze della sessione precedente conservate e script integrali riletti. Generatore Blender aggiornato via apply_patch, nuova cartella mouth_preview_v5 GLB/texture/blend; HEAD_FILE nei due script completi preview/integrazione aggiornato. Nessuna modifica a mappa, controller voce/boss o animazioni. UV e materiale precedenti conservati, nessuna nuova texture.

**Verifiche:** Blender 5.2.1 export/render riuscito. Frontale chiuso/aperto e screenshot Godot smile/round ispezionati, arcate prolungate fino al lato destro e maggiore spazio centrale, denti nascosti a riposo. Godot 4.7.2 Forward+ D3D12 RTX4060 `BRUNO_MOUTH_TEST failures=0`, max 0.780188, round 0.388877, smile 0.849993; `.godot/bruno_teeth_v5_test.log`. Warning storico certificati distinto dagli esiti. Test mappa non ripetuto per questa rifinitura geometrica; gradimento finale utente aperto. F8 → map_test → F6, osservare dialoghi/risata.

**Consolidamento:** aggiornati CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG/BRUNO_MOUTH_PREVIEW/SESSION_LOG. Varianti precedenti conservate; asset/generatore locali non sono backup Git. Nessun staging/commit/push.

## 2026-10-11 — arcate continue al posto dei denti separati

**Riscontro/richiesta:** utente respinge V3: denti singoli staccati e storti; preferisce mesh bianca unica, eventualmente denti differenziati con texture futura. Sostituiti i quadratini con due fasce continue V4, bianco avorio chiaro, profilo curvo regolare senza fughe. UV continue 0–1 predisposte per ciascuna arcata, nessuna texture nuova applicata.

**Baseline e file:** stesso branch dev/prototype-0.1 e HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; differenze della sessione precedente confrontate e conservate. Generatore Blender integralmente letto e modificato via apply_patch; nuova cartella `mouth_preview_v4` con GLB/texture e sorgente blend, V3 conservata. Profili interpolati su tre ancore del taglio reale anziché coordinate diverse per singolo dente; 16 segmenti contigui per fascia. HEAD_FILE dei due script completi preview/integrazione ora V4, loro uniche modifiche dal Git. Nessuna modifica a mappa, controller voce o gameplay.

**Verifiche:** export/render Blender 5.2.1 completato. Render aperto/chiuso e screenshot Godot smile/round ispezionati: bande continue visibili, senza quadratini. Godot 4.7.2 GPU Forward+ D3D12 RTX4060 `BRUNO_MOUTH_TEST failures=0`, max 0.780144, round 0.396315, smile 0.849992; log `.godot/bruno_teeth_ribbon_test.log`. Errore storico certificati distinto dalle asserzioni. Integrazione mappa della V3 verificata nella voce precedente; non ripetuto il test mappa per questo cambio solo geometrico/path. Test preview carica lo stesso GLB V4 e verifica tre shape, audio, stop/pausa e bus. Conferma artistica utente ancora aperta: F8/map_test/F6, dialoghi e risata.

**Consolidamento:** aggiornati BRUNO_MOUTH_PREVIEW/CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG e registro. Nessun staging/commit/push. Generatore/blend ignorati e asset locali non tracciati come prima. Texture di separazione è possibilità successiva, non attività eseguita.

## 2026-10-11 — denti semplici Bruno

**Richiesta:** aggiungere denti solo accennati alla bocca già approvata. Letti documenti di continuità, standard, architettura/procedura bocca, generatore Blender e script integrali preview/integrazione/test; confronto Git dei due script senza differenze iniziali. Branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. Differenze locali pregresse preservate. Mappa reale BFC63E1AF1ED572D82BD2DDD25746ABE8DC74832294A413D46ADF974A3BE3CA9, diversa dalla precedente fotografia documentale, non modificata qui.

**Intervento:** generatore `tools/blender/build_bruno_mouth_preview.py` produce nuova `assets/models/enemies/bruno_buozzi/mouth_preview_v3/bruno_head_mouth_preview.glb` e `.blend`. Due arcate da sei piccole corone, avorio opaco, spazio tra denti e profondità ricavata dal taglio labiale reale; inferiori seguono jaw_open, tutte conservano deformazioni round/smile. Terza superficie, 24 triangoli aggiunti, tre shape invariate. Generazione tramite API Blender, nessuna patch automatica Python/PowerShell. Originale/V1/V2 conservati; solo HEAD_FILE modificato nei file completi `scripts/characters/bruno_mouth_integration.gd` e `scripts/debug/bruno_mouth_preview.gd`. Controller voce e boss/intro invariati.

**Verifiche:** Blender 5.2.1 export/render concluso; immagini frontale/tre quarti chiuso/aperto e Godot round/smile ispezionate. Correzione iniziale delle corone troppo nascoste dietro le labbra, rigenerazione prima dei test finali. Godot 4.7.2 Forward+ D3D12 RTX4060 `BRUNO_MOUTH_TEST failures=0`, max apertura 0.780144, round 0.406053, smile 0.849992. Mappa reale headless `BRUNO_MOUTH_INTEGRATION_TEST failures=0`: entrambe le voci intro, frase combattimento, dolore, caduta e sconfitta, stop e bus ripristinati. Log `.godot/bruno_teeth_test.log` e `bruno_teeth_integration.log`; warning storico certificati e SparksElectric separati dagli esiti. git diff --check passato. Hash controller boss F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA e mappa conservati.

**Consegna/limiti:** gradimento utente ancora da ricevere. F8 → map_test → F6, osservare denti durante dialoghi/risata; preview isolata per M/3/4 e 1/2. Documenti CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG/BRUNO_MOUTH_PREVIEW aggiornati. Generatore e `.blend` ignorati, GLB/texture locali non tracciati: nessun backup Git implicito. Nessun staging/commit/push. Nessun nuovo test completo combattimento o salvataggio manuale.


## 2026-10-11 — audio puzzle regia sincronizzato

**Richiesta:** utente inserisce otto effetti in assets/audio/edificio e autorizza ascolto/collegamento sincronizzato. L'agente non dispone di ascolto diretto, limite dichiarato durante lavoro: eseguite analisi segnale/durata/silenzi/volume e verifica decodifica/PCM nel motore, non valutazione uditiva del timbro. Nomi associati a bip/sblocco/battente/mouse/tastiera/cavi/sfoglio; prove sonore finali da ricevere.

**Baseline/fonti:** documenti continuità e guida regia/test, script integrali puzzle/terminale/lettore/uscita e door.gd, stato e riferimenti reali. Nuovi script puzzle già non tracciati dalle sessioni precedenti, lavoro locale preservato. Branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. Mappa SHA256 BFC63E1AF1ED572D82BD2DDD25746ABE8DC74832294A413D46ADF974A3BE3CA9 e Bruno F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA invariati. Otto MP3 originali preservati, sette estratti nuovi in assets/audio/edificio/gameplay tramite FFmpeg; nessuna patch automatica PowerShell/Python al codice.

**File/intervento:** nuovo scripts/systems/regia_audio.gd/UID, cache MP3 e pool di quattro player per tipo, SFX, sorgenti 3D per bip/sblocco/cavi e 2D per interazione PC/libro. regia_network_terminal.gd emette mouse solo alla pressione sullo schermo attivo, tastiera tramite gui_input dei campi reali (nessun suono per modifiche programmatiche), beep fisico/reset anche senza WiFi. regia_network_puzzle.gd emette cavo al termine del tween 0.6 s se ancora collegato, caricatore solo dopo interazione che lo collega, sblocco una volta al LED verde. Assegna nuovi open/close_sound solo all'uscita aliena. regia_alien_exit_door.gd sospende audio e movimento nella pausa normale; apertura sonora dopo arretramento e chiusura al contatto tramite base esistente. regia_book_reader.gd avvia lo sfoglio insieme al tween di 0.6 s. Nessun nuovo stato persistente; restore silenzioso, pool liberato con proprietario. Parent door.gd, AudioManager, SaveManager, HUD/player, boss/intro e altre porte invariati.

**Estratti:** button_digital originale 0.096 s; electric originale 11.832 s con picco −22.6 dB, scelto 8.30–9.10 s e +16 dB/fade 0.12. Apri 1.30 s −9 dB; chiudi da 0.44 per 0.56 s −9 dB; mouse da 0.14 per 0.16 s +2 dB; tastiera da 0.05 per 0.23 s −12 dB; cavo da 0.045 per 0.22 s +2 dB; pagina da 0.10, atempo 1.2, durata uscita 0.60 s +2 dB. Dettagli riproducibili e limiti in REGIA_AUDIO.md. Estratto electric scelto dal segnale, gradimento timbro non verificato.

**Verifiche finali:** nuovo scripts/tests/regia_audio_test.gd/UID, `REGIA_AUDIO_TEST failures=0` headless Audio Dummy: input realmente focalizzato, clic fuori/rilascio/inattivo, bip invalidi/sbloccato, limiti sfoglio e doppio input durante tween, restore, pool, pausa/ripresa. Capture SFX temporaneo poi rimosso: 4096 frame PCM, picco 0.549139. `REGIA_NETWORK_MAP_TEST failures=0` prima headless, poi GPU Forward+ D3D12 RTX4060 con asserzioni aggiunte su dodici bip, caricatore, cavo alla fine, sblocco unico, battuta chiusura, nessun apri prima del retreat, restore senza suoni. Suite mappa in sequenza; ciclo kit/puzzle/porta/passaggi/save/restore conservato. Log .godot/regia_audio_test.log, regia_audio_map_test.log, regia_audio_gpu_map.log; nessuno slot utente scritto. git diff --check passato, staging vuoto.

**Correzioni intermedie/limiti:** preload del test prima autoload non risolveva SaveManager: helper usa nodi root verificati. Creazione/liberazione istantanea in raffica interferiva con routing differito AudioManager; sostituita con pool riutilizzabile, errori assenti nella prova finale. Test pausa corretto attendendo il frame di elaborazione; capture iniziale saturo di silenzio prima della prova, svuotato prima dei suoni. Sfoglio durata corretta a 0.60 s in uscita FFmpeg. Restano errori storici certificati/SparksElectric; test dedicato segnala a uscita 7 ObjectDB/2 risorse, separati dagli esiti. Nessuna build/export o ascolto diretto effettuati. Nessun staging/commit/push.

**Consolidamento/ripresa:** aggiornati README/CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG/WORKFLOW_AND_TESTING/REGIA_NETWORK_PUZZLE/SESSION_LOG e nuova REGIA_AUDIO.md. F8 → map_test → F6 con audio attivo: provare bip/reset, codice corretto/sblocco, battente vicino/lontano e chiusura, Ethernet/caricatore, mouse/campi, sfoglio; verificare pausa/ripresa e restore silenzioso. Ricevere riscontro su timbro e livelli, soprattutto estratto elettrico. Denti Bruno V6 approvati da preservare.

## 2026-10-11 — sliding_door e «allo switch»

**Richiesta/conferma:** «perfetto» sugli audio regia precedenti; aggiungere sliding_door alle scorrevoli e correggere «al switch» in «allo switch». Originale reale assets/audio/edificio/sliding_door.mp3, durata 2.472 s, silenzio iniziale 0.173 s e finale 0.163 s. Estratto nuovo gameplay/sliding_motion.mp3 da 0.15 s per 2.18 s, +3 dB; originale preservato.

**Baseline/fonti:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; script integrali sliding_door/regia_map_integration e parent letti, differenze con Git confrontate (notifica generica e puzzle locale preservati). Puzzle/menu e helper audio della sessione precedente conservati. Nessuna modifica alla scena mappa, hash BFC63E1AF1ED572D82BD2DDD25746ABE8DC74832294A413D46ADF974A3BE3CA9.

**File/intervento:** regia_audio.gd registra cue sliding; regia_map_integration.gd assegna stesso stream ad apertura/chiusura delle scorrevoli laboratorio/bagno. sliding_door.gd riusa player SFX 3D, distanza massima 12 m; ferma audio quando termina movimento e al restore, senza cambiare velocità/offset/collider/chiave. regia_network_puzzle.gd mostra «Collega allo switch» e «Scollega dallo switch»; PC mantiene «al/dal PC». File .gd completi modificati via apply_patch, nessuna patch automatica PowerShell/Python.

**Verifiche:** regia_audio_test ampliato per durata clip sliding 2.18 s, `REGIA_AUDIO_TEST failures=0`, capture 4096 frame PCM picco 0.412022 (.godot/regia_audio_sliding_test.log). sliding_passage_test ampliato con audio avvio/stop in entrambe le direzioni e restore silenzioso; mappa headless `SLIDING_PASSAGE_TEST failures=0`, quattro sweep reali liberi con porte aperte e chiuso bloccante (.godot/sliding_audio_test.log). Test non scrivono slot utente. Warning storici certificati/SparksElectric e 2 ObjectDB/1 risorsa a uscita test audio distinti dagli esiti. git diff --check passato. Correzione testo verificata nei file; nuovo ascolto/playtest utente aperto.

**Documenti/ripresa:** aggiornati REGIA_AUDIO/CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG e registro. F8 → map_test → F6: provare apertura/chiusura delle due scorrevoli e menu Fritz «Collega allo switch». Audio regia precedente approvato; nessun staging/commit/push.

## 2026-10-11 — bocca e denti Angelastri

**Richiesta/conferma:** utente approva scorrevoli/testo/audio («ok ci siamo») e introduce nuovo nemico Angelastri: modello ufficiale sgt_angelastri.glb, scena citata sngelastri.tscn, prima attività bocca/denti come Bruno. File reali verificati `assets/models/enemies/Angelastri/sgt_Angelastri.glb` e `scenes/enemies/angelastri.tscn`; non rinominati. Conferma estetica Angelastri ancora aperta.

**Baseline/fonti:** documenti continuità letti nella sessione, nuovo indice/stato/ultima voce, scena integrale e import, controller voce Bruno e generatore, Godot/Blender inspection reali. Branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto; modifiche/audio/asset locali precedenti conservati. GLB ufficiale SHA256 C07CED1702FFC506D69048954EE5AA30D0D6255884A1AEA6F98CBCA706994B69 preservato. Mappa BFC63E1AF1ED572D82BD2DDD25746ABE8DC74832294A413D46ADF974A3BE3CA9 e controller Bruno F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA invariati. Copia della scena precedente in .godot/angelastri_before_mouth.tscn, confronto: aggiunti solo ext_resource script e MouthPresentation.

**Diagnosi:** testa rigida Testa sotto mixamorig_Neck, senza shape/skin/jaw; corpo skinnato separato. Testa 1.076.121 vertici / 2.016.606 triangoli; 24 clip mie e 2 importate. Calibrazione della linea labiale sul render ortografico originale e campioni dei vertici frontali. Nessuna decimazione o riscrittura del rig.

**Intervento/file:** nuovi tools/blender/inspect_angelastri.py e build_angelastri_mouth.py (API modellazione, nessuna patch automatica ai file esistenti). Conservati array geometria/UV/normali, tagliati 444 triangoli attraversati dal labbro; nuova testa 1.085.631 vertici / 2.019.332 triangoli, tre shape open/round/smile, cavità scura e arcate continue con texture approvata Bruno V6 incorporata. Delta massimo apertura completa 13.0845 mm. Asset nuovo mouth_preview/angelastri_head_mouth.glb e .blend, GLB SHA256 314142C2BC3EA360CFD6B21959E60A67864A7A5247F4F944F58664F7536BC2D0, texture estratte dall'editor nella nuova cartella. Originali corpo/mesh/animazioni conservati.

**Runtime/prova:** nuovi scripts/characters/angelastri_mouth.gd, scripts/debug/angelastri_mouth_preview.gd, scripts/tests/angelastri_mouth_test.gd e UID, scena scenes/levels/angelastri_mouth_test.tscn. Componente aggiunto alla scena ufficiale, sostituisce solo mesh Testa preservando parent/transform/materiale. Voce opzionale tramite export/bind_voice, riuso BrunoMouthMotion senza modificarlo; senza voce resta fermo e non crea bus. Preview confronto O, manuale M/slider, 3/4 espressioni, 1/2 vista e menu di tutte le clip mie. Spazio usa dialogoBruno2_p1.mp3 umano, esplicitamente provvisorio e solo preview. Nessuna nuova voce ufficiale, AI, danno, drop, cinematic o integrazione mappa.

**Verifiche/correzioni:** Blender 5.2.1 export e render originale/chiuso/aperto frontale/tre quarti riusciti. Prima iterazione aveva shape preimpostate a 1, corrette esplicitamente a zero; taglio laterale ristretto e denti arretrati agli angoli dopo immagini iniziali. Godot 4.7.2 Forward+ D3D12 RTX4060 `ANGELASTRI_MOUTH_TEST failures=0`, picco 0.603476, 26 animazioni; screenshot chiuso/aperto/round/smile ispezionati. Verificati materiale/transform, texture, manuale/confronto, audio reale provvisorio, stop/pausa voce/albero e bus ripristinato. Test headless integrativo verifica anche scena ufficiale senza voce, ferma e priva di capture; primo controllo round/smile leggeva il valore prima del frame perché photo in headless ritornava subito, fixture corretta attendendo due frame. Warning certificati e risorse a uscita distinti dagli esiti. Nessun export/build o playtest utente nuovo.

**Consolidamento/ripresa:** nuova guida ANGELASTRI_MOUTH.md; aggiornati README/CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG/WORKFLOW_AND_TESTING/SESSION_LOG. F8 → scenes/levels/angelastri_mouth_test.tscn → F6; M/slider/3/4, 1/2 e O, Spazio voce temporanea, menu clip. Ricevere riscontro visuale prima delle successive attività Angelastri. Tool/blend ignorati e asset locali non tracciati, nessun backup Git implicito. Nessun staging/commit/push.

**Esito integrativo Angelastri:** ripetizione headless finale `ANGELASTRI_MOUTH_TEST failures=0`, picco 0.618523, inclusa scena ufficiale senza voce/bocca chiusa/nessun capture. Log angelastri_mouth_headless_test; git diff --check finale passato, staging vuoto.

## 2026-10-11 — denti superiori Angelastri rialzati

**Riscontro/richiesta:** «molto carino» sulla prima versione; denti superiori troppo esposti e troppo vicini all'altra arcata, richiesto lieve rialzo. Nuova variante mouth_preview_v2, solo arcata superiore +1.2 mm in verticale locale; texture, inferiori, apertura/shape, rig e animazioni invariati. Prima variante conservata.

**File/baseline:** generatore build_angelastri_mouth.py e componente angelastri_mouth.gd integralmente riletti; HEAD_FILE ora V2, output Blender nuova cartella. Branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; lavoro locale precedente preservato. Nessuna patch automatica PowerShell/Python: generazione nuova geometria via API Blender. Scena ufficiale e GLB sorgente non modificati in questa rifinitura.

**Verifiche:** Blender export/render chiuso/aperto riuscito; immagini frontale/tre quarti controllate, superiori meno visibili e gap aumentato, nessuna sporgenza a riposo. Godot 4.7.2 Forward+ D3D12 RTX4060 `ANGELASTRI_MOUTH_TEST failures=0`, peak 0.603213, 26 clip; anche scena ufficiale senza voce e bus ripristinati. Log .godot/angelastri_upper_teeth_test.log. git diff --check passato; warning storico certificati distinto dagli esiti. Aggiornati ANGELASTRI_MOUTH/CURRENT_STATE/ARCHITECTURE/DECISIONS_AND_BACKLOG/SESSION_LOG. Conferma finale utente aperta, F8 → angelastri_mouth_test → F6. Nessun staging/commit/push.

## 2026-10-11 — passaggio di consegne Angelastri e piano per fasi

**Obiettivo:** richiesta utente di salvare tutto nei Markdown per riprendere con una nuova sessione; successivo «Implement the plan» riferito al piano di salvataggio documentale. Nessuna nuova implementazione gameplay in questo intervento.

**Conferme e decisioni:** bocca/denti V2 approvati «ok perfetta». Utente sceglie fasi modello/animazioni, poi cinematiche sincronizzate, infine combattimento. Evento alla prima connessione Fritz a PC oppure switch. Primi due blackout con soltanto quadro aperto; giocatore ripristina corrente e rientra nel lab prima del riarmo. Terza uscita con Angelastri, intro, Thriller e due balletti, idle/looking; successiva presentazione quando vede il player, poi combattimento. Combattimento solo melee, racchetta-clava equipaggiabile da inventario e poi tasto 5. Specifica completa nel nuovo documento, senza inventare parametri ancora aperti.

**Baseline e verifica:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto; status reale verificato, differenze locali precedenti preservate. Letti documenti di continuità e aggiornamenti pertinenti; confrontate differenze documentali preesistenti prima delle aggiunte. Nuova verifica statica della scena: clip risata/dodging_right/ducking/thrller_1/thrller_2 e RacketSocket presenti; quattro MP3 presenti nella cartella del modello. Ispezione runtime precedente: 27 mie + 2 importate caricabili, non prova visiva integrale. Test precedente della bocca passato sulla V2, conteggio storico 26 ormai obsoleto. Nessun test gameplay nuovo attribuito a questa chiusura documentale.

**File:** nuovo docs/ANGELASTRI_IMPLEMENTATION_PLAN.md con risorse, nomi esatti, audio, socket, fase 1 concretamente definita, comportamento futuro, integrazioni e limiti. Aggiornati docs/README.md, CURRENT_STATE.md, DECISIONS_AND_BACKLOG.md, ANGELASTRI_MOUTH.md e SESSION_LOG.md. Corrette le conferme correnti; voci storiche preservate. Nessuna scena, script o asset modificato.

**Limiti:** ascolto semantico dei dialoghi non verificato; durate delle animazioni e della risata da misurare. Tempi casuali, cue dialoghi/musica, avvistamento e bilanciamento da definire nelle rispettive fasi. Nuove cinematiche/AI/racchetta come arma non implementate. Il socket è strutturalmente corretto, impugnatura non ancora verificata visivamente. Asset locali non tracciati/ignorati non salvati automaticamente da Git.

**Verifica documentale finale:** sei documenti presenti, collegamenti al nuovo piano controllati; git diff --check passato, nessun whitespace finale nel nuovo documento, staging vuoto. Nessun playtest necessario per queste sole modifiche documentali.

**Prossimo passo:** nuova sessione legge AGENTS e continuità, poi ANGELASTRI_IMPLEMENTATION_PLAN.md; verifica nuovamente branch/HEAD/differenze e legge script completi. Realizza soltanto fase 1 nella preview esistente, conserva modello V2 e modifiche utente a scene/player. Non ripartire dai vecchi obiettivi storici o rifare bocca/audio approvati. Nessun staging/commit/push.

## 2026-10-11 — preview Angelastri, dialoghi e balletto

**Richiesta:** ripresa dagli MD, fase 1 includendo sincronizzazione discorso/animazioni e prova balletto con musica; letti Angelastri_intro.txt e Angelastri_discorso_principale.txt.

**Baseline:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto. Scene/script Angelastri non tracciati, senza versione HEAD da confrontare; letti integralmente e preservati modello/scene ufficiali e lavoro locale. Continuità, piano, bocca, architettura e procedura consultati.

**File:** scripts/debug/angelastri_mouth_preview.gd e scripts/tests/angelastri_mouth_test.gd. Figura intera/volto, camera segue bacino, orbit/zoom/reset; lista clip/durate, pausa/seek/riavvio/velocità. Copia privata libreria, originali non modificati. Audio Angelastri completi, musica separata dalla bocca. Trascrizioni leggibili da UI. Cue gesti BOZZA, tempi stimati senza ascolto verificato, modificabili solo RAM e stampati in Output. Due danze a velocità originale per 48.6667 s con clock audio comune e fade finale 1 s; Thriller originale 91 s preservato.

**Verifiche:** Godot 4.7.2 headless Audio Dummy e GPU Forward+ D3D12, ANGELASTRI_MOUTH_TEST failures=0, 29 clip totali/27 mie, picco voce circa 0.49. Bocca/materiali/transform, pausa/stop/bus, separazione musica, transizione dance/seek, cue salute verificati. Screenshot midpoint tutte 27 clip generati in .godot/angelastri_clip_*.png; campioni danze/morso/duck ispezionati. Root motion seconda danza usciva dalla camera fissa, correzione camera bacino; nessuna correzione asset. Primo test falliva perché current_animation vuoto dopo pause: ora usa assigned_animation. Warning certificati storico distinto dagli esiti. Nessun ascolto diretto o prova continua completa; sincronizzazione al beat/alle frasi NON confermata. git diff --check passato.

**Ripresa:** F8 → angelastri_mouth_test → F6; scegliere audio e avviare sequenza, valutare cue/ritmo/transizione/root motion. Annotare cue modificati prima di chiudere. Aggiornati piano/stato/backlog/architettura/registro. Nessuno staging/commit/push. Fase 1 aperta fino a riscontro e affinamento.

## 2026-10-11 — primo pezzo Angelastri automatico

**Richiesta:** utente conferma che le clip funzionano e si vedono, chiarisce che vuole effetto completo senza comandi: intro e gesti → Thriller/danza1/danza2 continuo → fade → idle/looking. Limitarsi a questo primo pezzo.

**Baseline/fonti:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; file preview/test/scene non tracciati, versioni locali complete lette, lavoro precedente preservato. Nessuna versione HEAD dei file da sovrascrivere.

**Modifica:** solo scripts/debug/angelastri_mouth_preview.gd e scripts/tests/angelastri_mouth_test.gd. Autoplay dopo setup, pannello ridotto a replay/pausa/vista. Fine intro avvia la musica una sola volta; secondo balletto sulla stessa riproduzione; fade ultimo secondo, poi idle e looking ogni 10 s con ritorno idle. Pausa copre voce/musica/rest; replay riparte dalla intro. Modalità avanzata precedente conservata via export false. Nessuna scena ufficiale/modello/mappa/player/Bruno modificata.

**Verifiche:** test headless ANGELASTRI_MOUTH_TEST failures=0 incluse transizioni complete accelerate, fade, idle/looking e pausa rest. Aggiunta opzione --presentation per prova GPU continua di 85 s con autoplay e controllo raggiungimento di tutti gli stadi; esito registrato sotto. Warning storico certificati distinto dal test. Gesti intro restano bozza senza tempi delle frasi verificati; Audio Dummy non equivale ad ascolto. Riscontro utente aperto.

**Consegna:** F8 → scenes/levels/angelastri_mouth_test.tscn → F6, osservare senza premere nulla. Rivedi ripete; Spazio pausa/riprende. Aggiornati piano/stato/backlog/architettura/registro. Nessuno staging/commit/push.

**Steering durante lavoro:** utente aggiunge thrller_3/4 e chiede medesima sequenza senza interrompere musica. Scena ufficiale riletta integralmente, nuove risorse e pose utente preservate, nessuna patch scena. Durate runtime 25.5667 e 37.0667 s; quattro danze 111.3 s totali contro 91.0513 s musica. Preview usa copia MP3 in loop, offset clock al wrap; raccordo musicale da ascoltare, nessun ascolto diretto dichiarato. Test headless failures=0 con ordine quattro clip, fade finale, rest/pausa; 31 totali, picco 0.500828. Test GPU completo ora ha durata derivata dai file (circa 148 s) e verifica tutte quattro clip e looking. Esito finale sotto. Documenti aggiornati per quattro danze; istruzioni precedenti a due superate.

**Esito continuo e nuovo audio:** ANGELASTRI_AUTOMATIC_TEST failures=0 GPU, tutta sequenza reale intro/quattro danze/rest/looking verificata con traccia precedente. Durante lavoro utente sostituisce Thriller: nuovo file 125.410249 s FFprobe, vecchio import Godot restava 91.0513 s. Preview ora crea MP3 privato dai byte reali; nuova durata copre 111.3 s senza loop. Test aggiornato per loop condizionale; verifica nuova traccia nel log angelastri_long_music_final. Nessun nuovo ascolto diretto, gradimento F6 aperto; nessun commit/push.

## 2026-10-11 — correzione corpo fermo e pointing nell'intro

**Richiesta/riscontro:** utente vede soltanto bocca in movimento nella prova automatica; vuole pointing su «questo è un muro».

**Baseline/fonti:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; preview/test/scene ufficiale non tracciati, nessuna baseline HEAD; script preview e test letti integralmente, TXT intro consultato, lavoro utente preservato.

**Diagnosi verificata:** aggiunto confronto rotazioni ossee dopo sync_sequence a 1/5 s; prima della correzione ANGELASTRI_BODY_CHANGED_BONES 0 e test failures=1. Blend 0.15 s al cambio clip non avanzava perché AnimationPlayer in pausa dopo seek: tempo/nome corretti ma posa precedente mantenuta. Test storici non verificavano le ossa, quindi conferme tecniche insufficienti per il corpo.

**Intervento:** scripts/debug/angelastri_mouth_preview.gd cambia clip audio-driven/rest senza blend pendente (0.0); rimane seek sul clock audio. Intro conserva pointing nel tratto provvisorio 11–18 s sostituendo pointing2 e ripetendo la clip se necessario. Non dichiarato timestamp frase verificato; nessun ascolto diretto disponibile. Bocca, musica continua e fade preservati; nessuna modifica modello/scena ufficiale/mappa/player/Bruno.

**Verifiche:** headless dopo correzione ANGELASTRI_BODY_CHANGED_BONES 52, ANGELASTRI_MOUTH_TEST failures=0. Test ampliato per movimento ossa su tutte quattro danze e pointing intro, screenshot due pose per danza e intro. GPU esito sotto; warning certificati storico separato. Documenti stato/backlog/architettura/piano aggiornati. Staging/commit/push assenti. Prossimo passo F6 stessa scena e riscontro continuo utente, soprattutto cue della frase.

**Esito finale correzione corpo:** GPU Forward+ D3D12 ANGELASTRI_MOUTH_TEST failures=0, tutte quattro danze variano 52 ossa tra campioni. Nuova prova --motion con autoplay reale (nessun comando utente): ANGELASTRI_LIVE_BODY_TEST changed=52 failures=0, voce avanzata a 12 s per screenshot live_pointing ispezionato: braccio alzato e gesto visibile. Confronti pose e rendering confermano movimento, non allineamento semantico del timestamp. git diff --check passato; riscontro F6 utente ancora aperto.

## 2026-10-11 — ritardo danza/pointing e idle-looking morbidi

**Richiesta/conferma:** utente «bellissima» sulla prova dopo fix corpo; richiede danza dopo introduzione musicale, primo «questo è un muro» pointing più tardi, passaggi idle/looking più dolci.

**Baseline/fonti:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, preview/test/scene non tracciati, lavoro locale preservato. Controller preview e test riletti integralmente; continuità della sessione conservata. Nessuna baseline Git disponibile dei due script.

**File/intervento:** scripts/debug/angelastri_mouth_preview.gd e scripts/tests/angelastri_mouth_test.gd. Export preview dance_start_delay 2.0 s (idle mentre musica parte), intro_pointing_time 12.0 s (+1), rest_blend_seconds 0.6 s. Offset danza incluso in loop condizionale/fade/fine: danza resta 111.3 s, fine musica a 113.3 s dall'avvio; MP3 125.41 s sufficiente, nessun loop. Rest passa a riproduzione continua con idle LOOP_LINEAR privato e crossfade reale idle/looking/danza→idle; tolti seek/pause per frame SOLO nel rest, pausa/ripresa esplicita preservata. Voce/danze conservano seek senza blend, evitando regressione corpo fermo. Scene ufficiali/modello/mappa/Bruno/player invariati.

**Verifiche:** headless ANGELASTRI_MOUTH_TEST failures=0, 52 ossa cambiano per tutte quattro danze. Nuovi controlli lead-in, pointing ancora assente a 11.5 s, ordine/seek con offset, fade fine nuova, blend idle→looking e ritorno: angolo massimo iniziale 0.0/0.0 rad, movimento dopo 0.3 s e pausa/ripresa verificati. Screenshot rest_blend_to_looking/idle; GPU esito finale sotto. Audio Dummy/pose non confermano allineamento semantico o beat: valori 2/+1/0.6 scelti come prima prova, comunicati in commentary, gradimento nuovo aperto.

**Consegna/ripresa:** F8/F6 stessa scena, autoplay invariato. Valutare ritardo danza, primo pointing e rest. Aggiornati piano/stato/backlog/architettura/registro, baseline storica invariata. Nessuno staging/commit/push.

**Esito finale GPU:** Forward+ D3D12 ANGELASTRI_MOUTH_TEST failures=0 (.godot/angelastri_timing_blends_gpu.log); continuità delle pose all'inizio dei due blend 0.0006905 rad, entrambi poi avanzano. Nessuna regressione movimento delle quattro danze (52 ossa variate ciascuna). git diff --check passato, staging vuoto.

## 2026-10-11 — ritardo danza 1 s, looking senza idle

**Richiesta:** 2 s troppi, provare 1; non usare idle perché è per combattimento.

**Baseline/fonti:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; preview/test non tracciati, script completi riletti, lavoro locale preservato. Nessuna versione Git HEAD dei file da confrontare.

**File/intervento:** scripts/debug/angelastri_mouth_preview.gd e scripts/tests/angelastri_mouth_test.gd. Ritardo default 1.0 s, init/lead-in/fine danza sostituiti con looking, loop solo copia privata looking. Eliminati alternanza idle e relativi timer; rest in riproduzione continua e crossfade ingresso 0.6 s. Idle originale/libreria ufficiale preservati per combattimento. Pointing/bocca/musica/danze conservati; nessuna scena/mappa/gameplay modificata.

**Verifiche:** headless ANGELASTRI_MOUTH_TEST failures=0, .godot/angelastri_one_second_looking.log. Fine musica dopo 112.3 s; checking lead-in/fade/ordine e 52 ossa variate per ogni danza, ingresso looking angolo iniziale 0 rad, movimento, pausa/ripresa e loop oltre la durata senza ritorno idle. rg conferma nessun mie/idle nel controller preview, staging vuoto. Nessuna nuova prova GPU necessaria per il cambio clip/offset dopo controlli dedicati; resa audiovisiva nuova F6 ancora da ricevere.

**Ripresa:** F8/F6 stessa scena; valutare attacco danza a +1 s e attesa looking. Aggiornati piano/stato/backlog/architettura/registro. Nessun staging/commit/push.

## 2026-10-11 — bocca durante canto Thriller

**Richiesta/conferma:** utente «una sola parola, PERFETTO» sulla prova precedente; richiede bocca quando inizia canto. Agente dichiara assenza ascolto diretto e chiede timestamp, continuando predisposizione indipendente; utente risponde «1 minuto e 13.5 secondi». Cue 73.5 s relativo all'MP3 musicale, non alla intro completa.

**Baseline/fonti:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5. Preview/componente Angelastri non tracciati; letti integralmente preview, component, BrunoMouthMotion e test. Versioni locali preservate, nessuna baseline HEAD dei file.

**File/intervento:** scripts/debug/angelastri_mouth_preview.gd, scripts/tests/angelastri_mouth_test.gd. Export singing_start_seconds=73.5, update_singing commuta unico capture dal player voce al player musica soltanto dal cue. Prima bocca chiusa; fine danza, stop e replay ripristinano binding voce/bus/shape. Nessun duplicato della musica, nessuna modifica audio/asset o componenti bocca esistenti; danza/fade/looking/ritardo 1 s preservati. RMS del mix intero, NON fonemi o isolamento vocale: gli strumenti influiscono dopo il cue; limite dichiarato all'utente, ascolto semantico non effettuato.

**Verifiche:** headless ANGELASTRI_MOUTH_TEST failures=0, ANGELASTRI_SINGING_TEST cue=73.5 peak=0.540498 (.godot/angelastri_singing_test.log). Test prima cue, riproduzione e apertura reale dopo cue, bus privato unico/send Music, voce su SFX, pausa/chiusura, fine/routing/replay; rest e tutte danze conservate, 52 ossa variate per ciascuna. Screenshot singing previsto da GPU; esito finale sotto. Nuovo gradimento F6 ancora aperto.

**Ripresa:** stessa scena F6 autoplay; osservare canto dopo 73.5 s musica, poi sfumatura e looking. Aggiornati piano/stato/backlog/architettura/registro. Nessuno staging/commit/push.

**Esito GPU canto:** ANGELASTRI_MOUTH_TEST failures=0, peak canto 0.528658 in angelastri_singing_gpu.log; screenshot singing ispezionato, bocca aperta durante danza. Limite mix intero invariato.

**Steering successivo:** utente richiede seconda indicazione pointing2. Cue intro aggiunto a intro_pointing_time + durata reale pointing (12 + 3.6 = 15.6 s), tolto loop pointing; opening resta a 18 s. Test mirato controlla primo/secondo nome e screenshot intro_second_pointing. Canto/danza/looking conservati, nessun nuovo gameplay. Verifica headless nel log angelastri_singing_pointing2. Aggiornati piano/stato/backlog/architettura, gradimento F6 aperto.

## 2026-10-11 — canto con apertura e chiusura bocca

**Richiesta:** utente osserva bocca sempre aperta nel canto; vuole movimento evidente.

**Baseline/fonti:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; preview/test non tracciati, versioni complete lette e stato controllato. Componenti bocca condivisi letti nella sessione precedente, invariati.

**Diagnosi/intervento:** il mix musicale mantiene RMS sostenuto, quindi sola ampiezza non articola. In scripts/debug/angelastri_mouth_preview.gd aggiunta inner class SingingArticulation locale, priority 10/ALWAYS dopo il controller RMS; modula apertura/round/smile con impulsi dal clock musicale, smoothing 0.03/0.045 s. Attiva solo sul binding musica, cue 73.5 s immutato; chiusura pausa, ritorno voce/stop/replay preservati. Movimento stilizzato circa 2.8 Hz, variazione lenta, non allineamento alle sillabe reali/fonemi. Nessuna modifica BrunoMouthMotion, bocca/scena ufficiale, modello, asset musica, mappa o gameplay.

**Test/file:** scripts/tests/angelastri_mouth_test.gd ora misura minimo/massimo e numero chiusure dopo warmup durante canzone reale. Headless ANGELASTRI_MOUTH_TEST failures=0; canto min 0.003653/max 0.432069, sei chiusure in finestra ~2 s (.godot/angelastri_singing_articulation.log). Test lifecycle/routing e corpo/gesti/looking passano; tutte danze 52 ossa variate. GPU esito finale sotto; gradimento utente F6 ancora aperto.

**Consolidamento:** aggiornati piano/stato/backlog/architettura/registro. Stessa scena F8/F6, osservare canto; nessuno staging/commit/push.

**Esito finale GPU:** Forward+ D3D12 ANGELASTRI_MOUTH_TEST failures=0; canto min 0.003382/max 0.417480, sei chiusure, .godot/angelastri_singing_articulation_gpu.log. git diff --check passato, staging vuoto. Escursione verificata nel motore; allineamento fonetico non dichiarato.

## 2026-10-11 — preview automatica discorso principale Angelastri

**Richiesta/conferma:** utente conferma canto «funziona bene»; prima dialogo principale con animazioni completo, soltanto dopo prova balletto/sequenza in mappa. Specifica che durante balletto Angelastri deve muoversi nello spazio.

**Baseline/fonti:** dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, stato dei target non tracciati controllato; preview integrale e test letti, piano e TXT dialogo consultati. Scene/modello/player/mappa e lavoro locale preservati. Nessuna versione HEAD dei target da sovrascrivere.

**File/intervento:** scripts/debug/angelastri_mouth_preview.gd, nuova scenes/levels/angelastri_dialogue_test.tscn e scripts/tests/angelastri_dialogue_test.gd. Export preview_main_dialogue=true nella nuova scena, autoplay voce indice 1 e cue principali esistenti; risata attiva sorriso; clip gesti finite tornano looking anziché restare congelate, talk_to_combat ripetuto. Fine discorso → looking morbido; niente musica/danza/AI. Vecchia scena intro/balletto export false preservata. Tempi BOZZA, ascolto semantico non effettuato; prova audiovisiva utente necessaria per affinire cue.

**Verifiche/diagnosi:** nuovo test GPU continuo per tutta durata reale, bocca e ossa/gesti osservati, pausa/ripresa, fine/replay e capture rilasciato. Prima prova ha evidenziato avanzamento anticipato al rest durante pausa: player.playing può diventare false, aggiunta guardia not presentation_paused sull'avanzamento sequenza. Nuova esecuzione finale in .godot/angelastri_main_dialogue_final.log, esito sotto; certificati storico separato. Nessuna modifica alla mappa in questa fase.

**Ripresa:** F8 → angelastri_dialogue_test.tscn → F6, tutto automatico; ricevere correzioni gesti/tempi. Poi prova delle sequenze nella mappa con locomozione reale del balletto, continuità root motion tra clip/piedi/pavimento/ostacoli e posizione finale: la camera preview che segue bacino non prova questo. Aggiornati piano/stato/backlog/architettura/procedura/registro. Nessuno staging/commit/push.

**Esito finale continuo GPU:** ANGELASTRI_DIALOGUE_TEST duration=56.850605 peak=0.786969 gestures=9 failures=0. Pausa/ripresa e intera sequenza osservate senza avanzamenti manuali, replay/bus puliti; screenshot finale prodotto. Questo prova runtime, non sincronizzazione semantica dei cue. git diff --check passato.

**Regressione preview approvata:** headless ANGELASTRI_MOUTH_TEST failures=0 in angelastri_main_preview_regression.log; quattro danze 52 ossa variate, canto sette chiusure/min 0.00359/max 0.424947, pointing/pointing2 e looking conservati. Staging vuoto.

## 2026-10-11 — talking principali e secret soltanto nel whisper finale

**Richiesta:** utente aggiunge nuove talking, vuole valutarle e usarle ad hoc, secret soltanto alla fine quando abbassa la voce.

**Baseline/fonti:** dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; scena ufficiale e preview non tracciati. Scena ufficiale nuova letta integralmente con pose utente aggiornate, preservata senza patch; controller/test riletti integralmente. Nuove clip reali talking/talking2/talking3/talking_secret, non nome secret isolato.

**Valutazione:** test --inspect-talk genera pose GPU al 25%/65%, durate reali 3.9333/3.7667/10.2667/10.9 s; talking due mani esplicative, talking2 una mano, talking3 braccia/gestualità ampia, secret inclinato/mano vicino al viso. Sei immagini ispezionate, valutazione campionata delle pose, non ascolto. ANGELASTRI_TALK_INSPECT failures=0, .godot/angelastri_talk_inspect.log. Corretto tipo String nel probe dopo errore parser iniziale.

**File/intervento:** scripts/debug/angelastri_mouth_preview.gd, scripts/tests/angelastri_dialogue_test.gd, scripts/tests/angelastri_mouth_test.gd (quest'ultimo integralmente letto nella sessione precedente). Principal alterna talking/talking2/talking3 nelle spiegazioni e racconto, conserva pointing/angry/salute/risata; fallback talking dopo gesti. Secret solo finestra BOZZA 47–54 s, export start/end, poi talking3 ultima frase e looking a fine. Intro/balletto/canto invariati; scena/model/audio/mappa/Bruno/player non modificati. Nessuna identificazione semantica automatica del whisper: tempi da confermare in F6.

**Verifiche:** test principale GPU continuo osserva nuove talking e controlla uso secret soltanto nel suo intervallo e assenza nella intro, pausa/replay/bus. Esito finale sotto. Test headless regressione ANGELASTRI_MOUTH_TEST failures=0, 35 animazioni/33 mie, 52 ossa variano per ogni danza; canto sette chiusure min 0.003578/max 0.432061 (.godot/angelastri_talking_regression.log). Test conteggio storico sostituito per nuove clip. Certificati storico separato. Riscontro audiovisivo nuovo aperto.

**Consolidamento/ripresa:** F8 → angelastri_dialogue_test.tscn → F6; controllare scelta delle talking e cue whisper, poi mappa con locomozione balletto. Aggiornati piano/stato/backlog/architettura/registro. Nessuno staging/commit/push.

**Esito finale continuo GPU:** ANGELASTRI_DIALOGUE_TEST duration=56.850605 peak=0.786970 gestures=10 failures=0 (.godot/angelastri_talking_dialogue.log), incluse tutte nuove talking e controllo intervallo secret. git diff --check passato, staging vuoto. Sincronizzazione semantica esatta resta da valutare in F6.

## 2026-10-11 — gesti completi, blend principale e handoff combattimento

**Richiesta:** scatti/cambi posizione da tagli a metà; completare/usare meglio animazioni e passaggi dolci, secret 3 s prima, finale nuovo idle → talk_to_combat → futuro avvio combattimento.

**Baseline/fonti:** dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; scena/preview non tracciati, script e scena ufficiale riletti integralmente. Nuovi idle_new/idle_new_breathing utente verificati, scena e pose preservate senza patch.

**Valutazione idle:** GPU --inspect-talk controlla anche nuovi idle; durata idle_new 8.3333 s, idle_new_breathing 9.9333 s, immagini 65% ispezionate. Scelto idle_new per finale richiesto, breathing conservata.

**File/intervento finale:** scripts/debug/angelastri_mouth_preview.gd, scripts/tests/angelastri_dialogue_test.gd. Programma principale su durate effettive e playback continuo, nessun gesto interrotto a metà; meno cambi, risata lunga rimossa dai tagli brevi. Transizioni 0.55 s senza seek/pause per frame nel principale. X/Z del track bacino normalizzati nelle sole copie private parlato/looking/idle_new/talk_to_combat; Y/rotazioni e tutti track danza conservati. Secret 44 s, clip completa 10.9 s poi posa fino fine voce. Finale idle_new completo → talk_to_combat completo → combat_ready, handoff unico, nessuna AI/gameplay introdotta. Pausa/replay e approvata intro/balletto/canto preservati.

**Test:** principale continuo GPU aggiornato per gesti non tagliati, salto rotazioni per frame, drift bacino, secret esclusiva, nuovi stati finali e handoff unico. Primo probe con test vecchio segnalava finale looking atteso ormai superato (failures=2), fixture aggiornata al requisito nuovo. Verifica regressione headless preview precedente nel log angelastri_smooth_regression, GPU finale angelastri_smooth_dialogue; esiti sotto. Tempi semantici da rivedere in F6 dopo cambio sequenza.

**Ripresa/consolidamento:** F8/F6 stessa angelastri_dialogue_test.tscn, vedere gesti e finale. Poi mappa con movimento reale balletto e solo dopo AI. Aggiornati piano/stato/backlog/architettura/registro. Scene/model/audio/mappa/Bruno/player invariati, nessuno staging/commit/push.

**Correzioni durante verifica:** tentativo mixer manuale e filtro pose scartato: prova GPU rilevava salti fino a 1.01 rad tra frame normali (~13 ms), non stalli GPU; sweep sintetico senza frame non provava resa runtime ed è stato rimosso. Sostituito con playback continuo e normalizzazione chiavi private. Test completamento usa anche animation_finished, poiché posizione può tornare a zero su fine clip; guardia secret esclude frame dopo termine audio dove playback_position torna zero. Esito finale continuo nel log angelastri_natural_final; i probe intermedi non equivalgono a esito finale.

**Esito finale:** ANGELASTRI_DIALOGUE_TEST failures=0 GPU Forward+ D3D12, 56.850605 s voce più idle_new/talk_to_combat completi, otto gesti distinti, max variazione ossea per frame 0.201354 rad e drift bacino X/Z ~1.16e-9 m. Handoff unico e pausa/replay verificati. Regressione preview precedente headless failures=0 (37 animazioni, tutte danze 52 ossa variate, canto sette chiusure); nessun nuovo ascolto diretto. Verifica copie private nel probe angelastri_private_clips_final, originals non mutate. git diff --check passato, staging vuoto; nuovo gradimento F6 aperto.

**Verifica proprietà risorse/correzione:** il controllo identità nel probe successivo ha rilevato che duplicate(true) sulla sola AnimationLibrary conservava riferimenti alle Animation esterne. Corretto creando nuova libreria e duplicando esplicitamente ogni Animation prima di loop/normalizzazione; nessun file asset era stato scritto, ma il vecchio isolamento in memoria non era garantito. Nuovo probe angelastri_private_verified verifica Animation distinta dall'originale. Riprova continua finale angelastri_complete_private_final e regressione angelastri_private_regression_final registrate sotto; le precedenti affermazioni di copie private vanno lette con questa correzione.

**Verifiche dopo isolamento esplicito:** ANGELASTRI_TALK_INSPECT failures=0 GPU; ANGELASTRI_DIALOGUE_TEST failures=0 GPU continuo con controllo identità risorse, max_jump 0.201353 rad/drift ~1.86e-9 m e handoff unico. Regressione headless ANGELASTRI_MOUTH_TEST failures=0, 37 animazioni, sei chiusure canto, tutte danze 52 ossa variate. Stato finale consolidato, staging vuoto.

## 2026-10-11 — Angelastri: prova delle due sequenze nella mappa

**Richiesta e conferma:** utente approva il discorso studio «perfetto, da paura»; richiede comparsa su tasto diverso da F9 davanti ai contatori, intro/balletto mobile e successivamente secondo dialogo, prima della dinamica completa.

**Baseline:** dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5; working directory con precedenti modifiche/asset utente. Confrontate le differenze map_test (92 inserimenti preesistenti, 96 dopo quattro righe debug), preservate. Staging vuoto, nessun commit/push.

**File:** nuovo scripts/debug/angelastri_map_preview.gd, nodo/riferimento in scenes/maps/map_test.tscn; scripts/debug/angelastri_mouth_preview.gd con modalità mappa e trasferimento X/Z dal bacino a nodo modello; nuovo scripts/tests/angelastri_map_preview_test.gd. Guida docs/ANGELASTRI_MAP_PREVIEW.md e aggiornamenti indice/stato/backlog/architettura/procedura/piano.

**Comportamento:** F10 crea intro → musica continua/quattro danze → looking. F11 principale dalla posizione corrente e orientato al player → idle_new → talk_to_combat → handoff senza AI. F12 rimuove; FPS, F9 Bruno e salvataggi preservati. Spawn relativo contatori (-0.5,0,4.5), appoggio terreno; movimento cumulativo circa 8.27 m lungo X, niente reset tra clip. Animazioni originali non scritte: duplicazione esplicita prima delle modifiche private. Nessuna camera/ambiente dello studio in mappa; audio 2D di preview condiviso, nessun corpo fisico o trigger gameplay.

**Diagnosi/verifiche:** primo percorso troppo vicino alla cabina (38 campioni occupati); survey headless confronta dodici candidate con capsule, pavimento e aree fuoco/fumo. Controllo GPU più fitto sulla candidata (1.3,7.5) trova un contatto con Mesh_0_025 non intercettato dai 161 campioni survey; scartata e scelta (-0.5,4.5), survey zero ostacoli/hazard/pavimento mancante. Test finale GPU a 400 campioni e immagini registrato nella voce seguente. Regressione studio headless angelastri_world_mode_parse passata. I controlli automatici e screenshot non equivalgono al playtest sonoro utente.

**Prossimo passo:** F6 map_test, F10 osservare intro e intero balletto camminando attorno al personaggio, poi F11 dialogo; raccogliere riscontro su collocazione/resa prima della dinamica effettiva.

**Esito finale mappa:** Forward+ D3D12, `.godot/angelastri_map_preview_clear_route.log`: ANGELASTRI_MAP_TEST failures=0, occupazione 0 su 400 campioni, estensione percorso (8.267696,0.204416,2.133707) m, max passo campionato 0.46641 m. Continuità ai quattro confini, F10/F11/F12, camera/input, pausa bocca, cleanup bus, persistenza e stato Bruno passati. Survey candidata finale senza hazard su 161 campioni. Screenshot secondo dialogo mostra personaggio sotto illuminazione reale scura; camera fotografica iniziale coperta dal camion, non prova della visibilità dalla visuale player. Playtest audiovisivo mappa utente ancora aperto. Nessun intervento alle luci/ambiente per mascherare la resa.

## 2026-10-11 — Seconda sorgente musicale durante Angelastri

Utente conferma spawn corretto ma sottofondo ancora udibile. Letti integralmente audio_manager e controller debug: AudioManager._ready crea e avvia MenuMusic anche in lancio diretto F6. Precedente fix sospendeva solo BackgroundMusic e testava solo quella sorgente. Corretto scripts/debug/angelastri_map_preview.gd per sospendere anche AudioManager.music_player, preservare/ripristinare stato e mantenere entrambe sospese durante presentazione. Nessuna modifica ai bus, Thriller, FPS, marker o Bruno. Headless .godot/angelastri_marker_check.gd ampliato verifica entrambe le sorgenti e restore, passato; non equivale ad ascolto reale. Aggiornati stato e guida; prossimo passo ascolto F10 utente. Nessun commit/push.

## 2026-10-11 — Spawn Angelastri dal marker e sospensione sottofondo

**Verifica successiva richiesta dall'utente:** marker ora presente e salvato in scenes/maps/map_test.tscn, nodo radice Angelastri di tipo Marker3D (riga 5411). Nome compatibile con ricerca controller; precedente assenza su disco superata. Nessuna modifica alla mappa durante questa verifica.

Utente segnala musica sovrapposta e spawn invisibile; sceglie marker Angelastri. Modificato integralmente dopo lettura il solo controller debug: ricerca nodo 3D omonimo, yaw verso player anche F10, posizione attuale conservata per F11; rimosso offset contatori. BackgroundMusic sospesa conservando stato precedente, ripristinata in rest/combat_ready e clear/morte/restore. Bus Music conservato per Thriller. Marker non presente su disco: nessuna modifica automatica alla mappa utente, occorre salvarla nell'editor. Verifica headless caricamento controller e pausa/ripristino anche sottofondo già sospeso tramite .godot/angelastri_marker_check.gd; nessun playtest mappa nuova posizione. Nessun commit/push. Aggiornate guida e stato; prossimo passo provare F10 sul marker salvato.

## 2026-10-11 — Evento Angelastri: contatore, terza uscita e regia TikTok

**Richiesta/conferma:** utente conferma «anche in mappa funziona bene», autorizza dinamica Fritz/blackout/terza uscita, regia mobile, faro, ritorno FPS e passeggiata/looking. Chiede disabilitare i tasti aggiunti e provare dal proprio checkpoint dopo Bruno. Precisazione durante il lavoro: prima performance rivolta a ipotetica camera TikTok, non al player; secondo discorso verso player. AI/attacchi e racchetta arma saranno la fase successiva, con utilizzo soltanto dopo avvio fight.

**Baseline e conservazione:** branch dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, molte differenze locali/asset utente. Mappa confrontata e preservata con marker appena salvato; aggiunto soltanto riferimento script e nodo encounter (106 inserimenti complessivi contro HEAD, include lavoro precedente). Staging vuoto, nessun commit/push. Hash Bruno intro/controller nemico invariati rispetto alla sessione precedente.

**Fonti:** continuità, piano completo Angelastri, architettura/test; controller preview e parti pertinenti Bruno camera/input/HUD; ConnesiPower/Meter, Door, spotlight, SaveManager/adattatori/loot, RegiaNetworkState/integrazione/puzzle e scena marker/contatori/soglia/faro. Nessuna riscrittura Bruno, armi o puzzle.

**File:** scripts/systems/angelastri_event_state.gd; scripts/cinematics/angelastri_encounter.gd; estensione minima scripts/debug/angelastri_map_preview.gd (hotkey false, autoplay/orientamento parametrizzati, niente notifica debug durante evento); world_motion_scale privato in scripts/debug/angelastri_mouth_preview.gd. Nodo/riferimento scenes/maps/map_test.tscn. Suite scripts/tests/angelastri_event_test.gd e angelastri_encounter_map_test.gd. Nuova guida docs/ANGELASTRI_ENCOUNTER.md; indice/stato/backlog/architettura/procedura/piano e guida preview aggiornati.

**Dinamica:** primo cavo verso PC/switch arma una volta; timer iniziale 14–22 s solo dentro e con corrente, successivi 6 s solo dopo ripristino+rientro dalla soglia. Risate distanti 9–16 s. Tre blackout tramite ConnesiPower, sportelli aperti; primi due senza nemico, terza uscita avvia cinematiche. Camera audio-driven con archi/distanza/altezza e raycast/volumi orientati camion; lock FPS/arma/HUD, prestito/restauro faro, ritorno camera 1.4 s. Passeggiata lenta con controlli terreno/capsule, idle_new/looking privati; grace 3 s e vista reale/FOV/raggio 4 m per discorso fino a fight_ready, senza AI/danno. Persistenza main.angelastri.encounter, vecchi checkpoint compatibili, nessuna scrittura slot utente; save bloccato durante cinematiche/movimento sportelli/handoff.

**Diagnosi percorso/regia:** la prima direzione verso player portava contro facciata/arredi; modificata per camera TikTok e corsia libera. I collider camion lasciano libero l'interno del cassone: aggiunti volumi visivi orientati, evitando camera nel camion. Ricerca su 641 campioni/direzione, preferisce scala completa e riduce traslazione soltanto se necessario. Nel marker attuale scala 1 non completamente libera, 0.85/yaw 0.992278 con zero contatti; asset, tempo animazioni/audio invariati. Prima prova 1 fallimento percorso; corretta. Errore nil della prima fixture causato dal richiamare director dopo handoff/camera liberata, protetto con guardia cinematic; non attribuito a playtest utente.

**Verifiche:** suite stato headless passata. GPU Forward+ D3D12 .godot/angelastri_encounter_space.log: failures=0, camera_travel (7.201452,0.968715,5.772984) m, zero occlusioni/zero collisioni danza su 600 campioni; tre blackout/sportelli, soglia, input/HUD, sottofondi, restore posa, LOS con muro e handoff passati. Screenshot intro e danze ispezionati. Successiva verifica del faro/restauro rig, grace LOS e trigger naturale del secondo dialogo nel log finale sotto. Clock danza accelerato e tail simulata: non ascolto né playtest completo in tempo reale. Parametri iniziali da valutare con utente. Conferma della nuova cinematica ancora aperta.

**Prossimo passo:** caricare il checkpoint post-Bruno, primo cavo, due ripristini/rientri, terza uscita e performance, poi avvicinamento. Rifinire regia/luci in base al riscontro; implementare successivamente AI zombie, attacchi/immune bullet-vulnerabile melee e Usa/Riponi racchetta con socket e slot 5, sblocco solo fight.

**Verifica finale consolidata:** .godot/angelastri_encounter_verified.log GPU Forward+ D3D12 failures=0, 600 campioni danza/camera, zero occlusioni e collisioni, stesso camera_travel sopra. Verificati ora anche checkpoint simulato post-Bruno, orientamento camera immaginaria, LOS libero del faro, ripristino esatto transform rig, rilevamento player libero/ostruito e avvio naturale seconda sequenza dopo grace. Faro dal punto originale bloccato da MURI_ESTERNI_PT: ricollocazione temporanea esterna verificata e ripristino passato. Regressione studio headless .godot/angelastri_encounter_mouth_regression.log failures=0: 37 animazioni, 52 ossa variate per tutte quattro danze, sei chiusure canto. Diff whitespace controllato, staging vuoto; nessun commit/push. Nuovo playtest utente ancora da ricevere.

## Modello per una nuova voce

```markdown
## AAAA-MM-GG — titolo concreto

**Obiettivo/richiesta utente:** ...
**Baseline:** branch, HEAD, differenze locali rilevanti, staging.
**Fonti lette:** documenti, script integrali, scene/riferimenti/override.
**Diagnosi e decisioni:** evidenza, scelta utente, vincoli, ID backlog.
**File e modifiche:** path esatti e comportamento cambiato.
**Verifiche:** comando o scenario, ambiente, risultato e limiti.
**Conferma utente:** testo/esito o “non ancora ricevuta”.
**Stato:** implementato / testato / aperto; distinguere storico e nuovo.
**Git:** staged/commit/push solo se richiesti; hash e branch se effettuati.
**Documenti aggiornati:** stato/backlog/architettura/procedura.
**Prossimo passo:** cosa manca, dove ripartire, eventuale blocco concreto.
```
## 2026-10-11 — Angelastri: audio di mappa, blackout e avvio della regia

**Richiesta:** in F6/caricamento si sentiva il tema menu anziché l'ambiente; risata assente, click/notifica blackout mancanti e riarmo troppo corto; terza uscita bloccava il gioco prima della sequenza; camera attraversava l'arco e richiede quote più basse.

**Intervento:** `AudioManager` sincronizza la scena corrente: se trova `BackgroundMusic` arresta `MenuMusic` e fa ripartire l'ambiente, incluso avvio diretto mappa e restore. `angelastri_encounter` porta il riarmo a 12 s, crea click 3D con lo stream reale del contatore nella posizione del player, invia esattamente `forse è saltata la luce...` e aumenta sensibilmente raggio/volume della risata. `angelastri_map_preview` precarica invisibile la presentazione; il controller prepara durante l'esplorazione la direzione/scala di danza e non esegue più i 641×17 sweep fisici al passaggio soglia. Regia: tratto iniziale in direzione di uscita prima del movimento verso Angelastri, poi target più alto e camera più bassa durante danza.

**Verifiche e limite:** `angelastri_event_test.gd` passa dopo il parser (`ANGELASTRI_EVENT_TEST passed`). La suite GPU mappa non ha raggiunto l'inizializzazione della mappa in tre avvii (anche dopo chiusura editor), fermandosi subito dopo l'avvio D3D12 senza errore applicativo; i processi di prova sono stati chiusi. Rimane necessario il playtest utente F6/slot post-Bruno, soprattutto volume reale, assenza freeze e primo tratto camera, e la ripetizione della suite GPU in una sessione disponibile. Nessun commit/push/staging.

**Correzione successiva su riscontro utente:** rimossa la risata temporizzata: viene riprodotta soltanto da `_trigger_blackout`. Il caricamento residuo era compatibile col fatto che `restore_completed` eliminava la presentazione prewarmata; `_restore_finished` ora la ricrea a mappa stabilizzata. La prima danza calcola al trigger il solo yaw verso il player-side del piazzale, eliminando la direzione verso camion senza ripristinare lo sweep costoso. `angelastri_event_test.gd` ripetuto: passed.

**Correzione finale della ripresa:** il verso è ora a tre quarti, interpolato al 65% tra marker e player, non frontale. Alla fine del balletto `_finish_return` verifica camera, presentazione e modello prima di accedere alla posa: in caso di transizione già liberata sblocca comunque il player e ricostruisce l'attore nel frame successivo. Il warm-up è richiesto anche ad ogni blackout, così un restore che abbia pulito la preview lo completa durante reset/rientro e non alla terza uscita. Test logico ripetuto: `ANGELASTRI_EVENT_TEST passed`; playtest finale camera/ritorno ancora necessario.

**Correzione sparizione patrol:** la root motion della danza appartiene a `presentation.model`. Il trasferimento di quella posa al nodo contenitore a fine return resettava la trasformazione locale in alcune istanze, producendo il teletrasporto/sparizione; rimosso. Il modello conserva ora la propria trasformazione finale e patrol parte da `actor.global_position`. Test logico da ripetere; serve la verifica utente alla fine della performance.

**Verifica richiesta dall'utente prima della riprova:** la suite `angelastri_encounter_map_test.gd` ora controlla esplicitamente che, dopo il ritorno, il modello sia valido/visibile e percorra almeno 0.1 m con patrol. Il test logico `angelastri_event_test.gd` passa (`ANGELASTRI_EVENT_TEST passed`). Avvio headless della suite mappa ancora fermo prima dell'inizializzazione (soltanto bootstrap/certificati nel log), quindi questa nuova asserzione non ha un esito runtime locale e non viene dichiarata passata.

## 2026-10-11 — Cause verificate della sparizione e del precaricamento inefficace

Le precedenti attribuzioni a root motion e pose erano ipotesi non dimostrate e non avevano risolto il problema. Individuata la catena reale: `_process` entrava nel ramo cinematic, `_director` completava il ritorno e liberava la camera, poi lo stesso `_process` chiamava nuovamente `_begin_return` perché la presentazione era ancora in rest. La guardia camera chiamava `_abort`, cancellando la presentazione. Corretto ricontrollando `cinematic` dopo `_director`.

Secondo errore concreto: `spawn_preview` chiamava sempre `clear_preview` prima del ramo di riuso della presentazione warmed, rendendolo irraggiungibile. Ora conserva la presentazione warmed e riusa il modello invece di istanziarlo alla soglia. Orientamento e audio approvati conservati.

Verifica runtime isolata senza edificio: `angelastri_return_frame_test.gd` con fixture separata esegue il vero `_process` nel frame di completamento, controlla zero nuovi return e attore ancora valido in waiting. Esito `ANGELASTRI_RETURN_FRAME_TEST passed`, `.godot/return_frame_verified.log`. La prova non misura il frame time GPU della mappa né la locomozione; queste verifiche restano distinte. Nessun commit/push.

## 2026-10-11 — Passeggiata, secondo incontro e combattimento Angelastri

**Conferma/autorizzazione:** utente conferma prima performance senza freeze/sparizione. Richiede walking/running, eliminare freeze secondo incontro, IA/attacchi/morso/lock/danni/barra provvisoria/racchetta e delega bilanciamento. Precisa proiettili sempre innocui con schivate e due melee oltre al morso. Autorizza tasto per saltare al patrol: scelto F7, F9 conservato.

**Baseline:** dev/prototype-0.1, HEAD 2ac4a5fb0953e633915ed862b7942ec3d86771c5, molte differenze locali preservate, nessun staging/commit/push. Letti controller evento/preview, scena ufficiale e player/socket, player/weapon/UI/inventario e contratti save; confrontate differenze UI già locali. Nessuna modifica al controller Bruno o geometria mappa.

**Implementazione:** riuso stessa presentazione anche al secondo incontro e F7, audio principale caricato prima. Patrol seleziona destinazioni con terreno/capsule, ruota modello anziché parent con root offset. Nuovo angelastri_combat.gd con corpo/collider dedicato e modello già caricato reparentato conservando posa; stati chase/attack/bite/dodge/hurt/dead, walking/running, due melee alternati/impatti singoli, morso con preavviso/lock/rilascio e cooldown, schivate con proiettili senza danno, reazioni/morte/barra. Racchetta valore arma 4 senza rinumerare 0–3, gate possesso/fight, Usa/Riponi UI, swing sul visuale sotto Socket, slot5 dopo uso, save opzionale compatibile. Persistenza defeated/corpse, save vietato durante fight. [Parametri e limiti](ANGELASTRI_COMBAT.md).

**Verifiche:** angelastri_combat_test passato headless e GPU D3D12 con player/asset reali: immunity su 20 proiettili da100, schivata/running/spostamento, due melee e impatto unico, morso/rilascio/interruzione, morte e HUD, racchetta gate/slot/save e danno via ray sul collider reale; successiva prova GPU verifica anche pulsante inventario Usa/Riponi e uscita pausa. Screenshot barra e racchetta ispezionato. angelastri_reuse_patrol_test passato con stessa istanza primo/F7/secondo, movimento walking e handoff finale combat/controlli. INVENTORY_SAVE_TESTS_OK nella regressione. Alcuni avvii di fixture terminano con avvisi ObjectDB/resource in uso al quit, nessun errore durante le asserzioni; non equivalgono a verifica di assenza leak nella partita lunga.

**Mappa:** prima suite GPU arriva a completamento con zero collisioni danza/zero occlusioni e handoff combat; un fallimento solo per asserzione menu_music.stream_paused obsoleta (menu ora correttamente stopped). Corretto test per stopped oppure paused; riprova finale in corso. Clock accelerati e fixture non certificano bilanciamento audiovisivo, morso visto dalla FPS o navigazione fra stanze; prossimo playtest utente F7 dal checkpoint.

**Esito finale mappa:** `.godot/angelastri_encounter_combat_map_final.log`, Forward+ D3D12: `ANGELASTRI_ENCOUNTER_MAP_TEST failures=0`, camera_travel (6.810422, 1.147462, 5.968105), zero occlusioni/zero collisioni danza. Passano anche patrol/visibilità dopo ritorno, restore posa, seconda LOS libera/ostruita, riuso main e handoff al controller combat. `git diff --check` sui file toccati passato e staging vuoto. Inventario/save e suite combat GPU passate. Preservate modifiche locali ulteriori comparsa durante la sessione (VFX/config/menu): non ripristinate né incluse in commit. Prova utente F7 ora pronta, bilanciamento aperto.

## 2026-10-11 — Secondo incontro: handoff immediato e visuale frontale

Utente segnala coda dialogo bloccata, passeggiata verso muro, rilevamento troppo vicino/da dietro e voce bassa. Causa blocco: idle_new rimaneva LOOP_LINEAR dalla passeggiata nella libreria riusata; la vecchia fixture forzava combat_ready e non copriva la fine naturale. Ripristinato LOOP_NONE prima del principale e aggiunta prova reale della coda e rilevamento frontale a 6 m/rigetto da dietro: passata. Successiva richiesta esplicita: combattimento subito dopo voce, ritorno camera morbido. In modalità mappa fine voce ora emette combat_ready immediatamente, talk_to_combat durante raccordo camera 1.4 s, poi controlli/fight; nessuna attesa idle_new. Studio conserva coda precedente.

Patrol candidate orientate verso porta/piazzale sul lato esterno, FOV orizzontale più stretto e distanza 8 m con player che guarda il nemico; camera principale cerca soltanto angoli frontali entro ±0.9 rad e non ripiega dietro. Voce principale +6 dB, BackgroundMusic -10 dB anziché -4. Test asset reali `angelastri_reuse_patrol_test` passa anche dopo handoff immediato (`.godot/angelastri_immediate_handoff.log`). Nuova resa mappa/audio da confermare con F7; la suite mappa precedente resta storica. Nessun commit/push.

## 2026-10-11 — Collider utente, navigation, attacchi e morso

Utente ha rifatto la navigation map e aggiunto CollisionShape3D alla scena nemico: asset preservati. Combat trasferisce la shape reale al corpo/controller di danno, disattiva layer del solo corpo visuale e rimuove eccezione collisione player. Evitati raycast contro proprio collider anche in spawn/patrol/root motion/LOS. NavigationAgent3D collegato alla mappa esistente, con fallback deviazione locale se mappa assente. Attacchi avanzano nel windup, LOS più alto; presa mantiene lock, camera inclinata/abbassata con pulsazione e ripristino originale su rilascio.

Racchetta: runtime verifica a_arms_hold_attack1/2/3; rimosso swing procedurale, tre clip alternate, singolo ray melee al 40% della clip. Suite combat con nuovo asset/collider passa (`angelastri_collision_bite.log`), inclusi danni due melee/morso e lock/rilascio; suite patrol/riuso ripetuta. Navigation e resa FPS del morso richiedono playtest F7 nella nuova mappa; nessun commit/push.

## 2026-10-11 — Dislivelli, invulnerabilità, rabbia e F11 fight diretta

Richiesta: incastri su avvallamenti, immunità durante caricamento attacco e intera reazione, morsi più veloci/frequenti con danni ma cooldown dopo presa, scorciatoia diretta fight. Implementati floor snap 0.45, max slope50°, step0.35 verificando soffitto/movimento/appoggio; NavigationAgent conservato. Danno melee soltanto in chase, ogni colpo accettato attiva hurt completo; attack/bite/dodge/hurt protetti. Rabbia crescente monotona da HP persi (non annullata da cura morso), velocità/frequenza/raggio presa aumentati; morso fallito 3→1s, riuscito8→5s dal rilascio. F11 diretto, F7 patrol; reset attore dopo sconfitta ripulito prima di cancellare vecchio corpo.

Test aggiornati eliminando vecchia aspettativa di interrompere la presa con melee: immunità/reazione/rabbia/cooldown e attraversamento fisico gradino20cm passati (`angelastri_step_rage.log`). Fixture riuso/handoff estesa a scorciatoia F11; verifica eseguita in `angelastri_f11_verified.log`. Nessun commit/push. Bilanciamento e avvallamenti specifici mappa da valutare con F11.

## 2026-10-11 — Feedback melee, sangue, invulnerabilità, audio e locomozione

Richiesta: archi bianchi trasparenti all'impatto, sangue su danno, silhouette rossa quando invulnerabile, swoosh Bruno/racket-hit/punch e nuovi audio zombie; meno scivolamento e schivate sul posto. Aggiunta successiva: colpi respinti con feedback repulsivo e racchetta velocizzabile. Nuovi melee_feedback.gd (archi CanvasLayer, spray CPU a vita breve, audio, bounce viewmodel) e shader overlay skinnato angelastri_invulnerable.gdshader. Weapon usa HP prima/dopo per distinguere sangue da hit respinto, hold attack1–3 a1.35× e impatto al40% ricalcolato, pugno al35% anziché immediato. Racket swoosh reali Bruno, punch/racket_hit1–2 e zombie attack/eating/idle/hit reali dalla cartella enemy. Rimbalzo/arco rosso/urto pitch grave su hit protetto; niente sangue. Walking1.2/run4.0, animation speed legata alla velocità reale, dodge senza spostamento orizzontale.

Suite combat aggiornata e passata headless/GPU Forward+ D3D12 (`angelastri_feedback_gpu.log`): danni/immune/step/bite e schivata fissa, shader active e spray su hit accettato. Screenshot `.godot/angelastri_invulnerable_feedback.png` ispezionato: alone segue corpo animato e droplets visibili. Log GPU segnala scrittura shader cache fallita e risorse ObjectDB al quit, ma shader renderizzato e asserzioni passate; nessuna verifica di leak a partita lunga né ascolto reale. Prova completa della racchetta temporizzata passata in `angelastri_feedback_swing.log`, impatto reale con clip1.35×. Asset audio/scena/navigation utente conservati; nessun commit/push. Prossimo F11 per gradimento VFX/audio e velocità.

## 2026-10-11 — Mirino globale, VFX leggibili e confine attacco

Utente approva suoni/nuovi effetti, chiede alone meno spesso, archi più evidenti, crosshair strutturale per nemici e vecchi oggetti/Bruno, niente info box fight, onda leggera che delimiti esattamente area danno e sangue visibile. Letti integralmente HUD e InteractionSystem reali, modifica mirata HUD per Control custom project_blob_reticle; vecchio TextureRect conservato/nascosto. Focus da sistema interazione autorevole, target enemy da antenati collider damage; apertura interpolata, visibilità player/menu/cinematiche. Nessuna riscrittura interazione/Bruno.

Alone0.025→0.009m/alpha0.45→0.2; archi più grandi/spessi/durata0.32s. Sangue34 droplets di raggio0.035, lifetime0.65s e spawn avanzato verso camera per evitare occultamento nel corpo. Onda mesh68 triangoli definisce arco e lati esatti del settore1.95m/dot0.35, compare a impatto senza espansione, sfuma0.35s. Avvisi combattimento/presa/sconfitta e F11 rimossi. GPU combat passato (`angelastri_reticle_vfx.log`), fixture crosshair player/HUD veri testa enemy e interactable sul layer2 reale e occultamento menu (`project_blob_reticle.log`). Prima fixture usava layer1 per item, corretta senza alterare interazioni reali. Gradimento grafico mappa ancora aperto; nessun commit/push.

## 2026-10-11 — Prova VFX prima di integrarli in maps

Utente chiede arco sospeso 3D anziché pavimento e scena ad hoc per sangue non visibile; precisa di vedere prima l'arco nella prova, prima dell'integrazione in maps. Creata scenes/levels/angelastri_vfx_test.tscn con angelastri_vfx_preview.gd, modello reale, ambiente chiaro, ciclo automatico e tre pulsanti/1–3: sangue attuale, variante flipbook blood_impact_6x5 già presente nel progetto più particelle, arco 3D frontale1.95m alto1.1–1.26m a impatto di zombie_attack2. Nuovo zombie_attack_arc_3d.gd solo preview, codice onda mappa conservato.

Screenshot prima prova mostrava particelle vicino ai piedi anziché punto colpo: CPUParticles iniziava a emettere all'inserimento prima di essere posizionato. Corretta emissione condivisa mettendo emitting=false prima add_child e restart dopo global_position. Nuova preview GPU passata (`angelastri_vfx_render.log`), sangue/arco screenshot ispezionati. Test scripts/tests/angelastri_vfx_preview_test.gd; immagini .godot/angelastri_blood_preview.png e angelastri_arc3d_preview.png. Primo harness aspettava troppo pochi frame dopo change_scene, corretto. Nessun commit/push; scegliere resa in F6 prima di integrare nuovo arco e flipbook in mappa.

## 2026-10-11 — Arco approvato e sangue meno blobboso

Utente approva arco/resto della prova e chiede schizzi più realistici, nuance/texture migliori. Arco3D approvato collegato al combat mappa, sostituisce settore sul pavimento; portata1.95m conservata nelle coordinate mesh. Sangue condiviso: sfere sostituite da 26 quad sottili texturizzati proceduralmente (texture64×64 irregolare, gradazioni rosso scuro/bordeaux, bordi alpha), rotazione/scala variate e dissolvenza nel lifetime. Preview flipbook rimpicciolito/scurito, resta isolato; niente nuovo asset esterno. Rendering preview GPU passato (`angelastri_blood_refined.log`) e screenshot ispezionato. Regressione combat con arco3D e sangue eseguita (`angelastri_blood_arc_combat.log`). Nuova nuance da valutare in F6/F11; nessun commit/push.

## 2026-10-11 — Gocce piccole direzionali, eliminati gli occhi verticali

Utente approva nuance ma respinge forme verticali, richiede ritorno alle sfere più piccole e getto lungo il movimento; autorizza ispirazione web. Consultati riferimenti di spray direzionali, in particolare https://forest.dev/p/roblox/ch1kz/bloodfx (nessun asset/codice scaricato). Rimosso generatore texture ovale/quad, 38 sfere raggio0.015m, bordeaux790e1b e fade, cono28°. Weapon misura spostamento reale mano/racchetta prima/alla frazione impatto, invia vettore a feedback; getto tangenziale/outward alla ferita per evitare occultamento dentro il corpo. Preview mostra spruzzo laterale da movimento campionato; arco3D approvato conservato.

Preview GPU passed (`angelastri_droplets_direction.log`, successiva prova sole particelle `angelastri_small_spray.log`), suite combat passed (`angelastri_droplets_combat.log`). Nessun commit/push; F6 prova VFX pulsante1 oppure F11 mappa per gradimento.

## 2026-10-11 — Sangue approvato, eliminata preferenza verso destra

Utente approva effetto e chiede correzione direzione/prova diretta in game. Preview forzava esplicitamente camera.global_basis.x: rimossa la direzione destra di dimostrazione. Nel feedback condiviso la componente tangenziale del vero movimento non viene più normalizzata da sola, evitando che uno spostamento laterale minimo produca un getto quasi tutto laterale; componente outward dominante e movimento effettivo mantenuto. Gocce/colore approvati conservati, effetto già collegato a pugni/racchetta nella mappa, F11 disponibile. Regressione combat eseguita in `.godot/angelastri_spray_in_game.log`; nessun commit/push.

## 2026-10-11 — Chiusura confermata e richiesta commit/push

**Conferma:** utente «ok ci siamo», richiede salvare lavoro/aggiornare MD e poi esplicitamente «facciamo anche un push». Resa finale in game approvata; non ripetere correzioni già chiuse. Punto di ripresa: evento completo Angelastri/secondo incontro/combat/racchetta/mirino/VFX/audio. F7 patrol/F11 fight, scena VFX F6. Barra boss ancora provvisoria; nuovo obiettivo da scegliere nella prossima sessione.

**Verifiche storiche della sessione:** suite combat headless/GPU, riuso/patrol/handoff e F11, reticle legacy GPU, preview VFX GPU e regressione inventory/save passate. Mappa GPU finale precedente passata con zero collisioni/occlusioni; ultima resa VFX/direzione sangue confermata dall'utente. Non attribuire verifiche esaustive a bilanciamento, tutte geometrie navigation o partita lunga; avvisi risorse al quit annotati sopra.

**Git prima della chiusura:** dev/prototype-0.1, HEAD2ac4a5fb0953e633915ed862b7942ec3d86771c5, staging vuoto, origin https://github.com/fraidotube/project-blob.git. Working tree comprende modifiche preesistenti e molti asset locali. Commit richiesto per sorgenti/dipendenze script, scene gameplay/test, risorse item e documenti; esclusi cache, cancellazioni SilverDelivery preesistenti, asset nuovi non verificati per redistribuzione, audio/modelli/texture esterni e materiali VFX modificati estranei alla chiusura. Non è un backup autosufficiente dell'intero progetto: conservare assets/models/Angelastri, edificio, audio enemy e modelli racchetta/arms locali, oltre agli asset ignorati. La nuova sessione nello stesso workspace mantiene questi file; clone su altro PC richiede copia e licenze.

**Consolidamento eseguito:** commit `674bcf4` (134 file selezionati, controllo `git diff --cached --check` passato), push riuscito su `origin/dev/prototype-0.1`. Il remoto è passato da `e5ff3c8` a `674bcf4`, includendo anche i due commit locali precedenti. Questa annotazione viene salvata in un successivo commit documentale; file locali esclusi conservati senza modifiche.
