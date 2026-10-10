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
