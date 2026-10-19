# Project Blob — stato locale

**19/10 — Broccolo audio/interruttore:** i nuovi MP3 sono collegati a shrink, duplicazione, lancio e impatto sul player; la traccia `Broccolo_soundtrack.mp3` parte col combattimento e riparte a285s per evitare la coda muta. Offset/durate tagliano silenzi senza modificare gli originali. Il solo interruttore del lampadario riceve luce viola pulsante quando il player è entro4m, disattivata dopo l'accensione/intro. Verifiche statiche soltanto; ascolto e visibilità a carico dell'utente. Nessun file di altri boss modificato.

**19/10 — Broccolo:** nella seconda cinematic il personaggio riceve un offset verso destra regolabile, applicato solo se il volume resta libero. A fine danza la scena mappa non esegue più il preview shrink: l'unica riduzione è quella con aura del combattente principale all'handoff. Nessun test Godot eseguito, come richiesto; prova completa all'utente. Altri boss intatti.

**19/10 — regia iniziale Broccolo:** resta in `mie/idle` ciclico mentre la camera avanza; al cue anticipato della suoneria l'idle viene sostituito da `mie/phone_answer_talk`, mantenendo risposta a13,5s e arrivo camera sul marker. Il tragitto è stato verificato prima in fixture e mappa; questa rifinitura non è stata provata in Godot su richiesta dell'utente, che farà la prova della cinematic completa e del combattimento. Angelastri/altri boss intatti. Nessun commit/push.

**Checkpoint Git 18/10:** commit `6c490a4` (script e `scenes/maps/`), `ebaaa36` (documenti, scene di supporto, risorse serializzate e UI) e `bf82775` (registro/stato) su `dev/prototype-0.1`. Al retry del19/10 `git push` ha confermato `up to date` su origin; la ref locale di tracking risultava ancora indietro di3. Modelli e archivi esclusi. Le modifiche del19/10 non sono committate né pushate.

**18/10 — nuova prova sfera/incendio:** utente approva lampo arancione e chiede proiettile con aura e bruciatura sul player. Laboratorio ora ha nucleo azzurro, anello/aura infuocata/scia; impatto diretto incendia3s,3HP ogni0,75s (12extra), rinnovo senza stacking. Fiamme corpo da fuori, bordi animati in FPS; danno/voce/HUD/morte reali. Tab offre Prova bruciatura in FPS. Nuovi link effetti/stato presenti solo nel test, mappa invariata. Suite incendio headless/GPU e regressione ruoli passate, guida [sfera e bruciatura](BROCCOLO_COMBAT_LAB.md#sfera-energetica-e-bruciatura--prova1810). Prossimo valutazione utente; trasferimento identico in mappa ancora successivo.

**18/10 — aura gradita, duplicazione rifinita:** aggiunto lampo arancione0,22s insieme alle particelle su principale e copie; il principale torna poi all'aura dorata se ancora attiva. Parametri Copy Flash Seconds/Strength in PowerVFX. Test headless passato, prova sempre nel laboratorio; trasferimento mappa ancora successivo alla conferma degli effetti complessivi.

**18/10 — nuova prova VFX, solo laboratorio:** battaglia in mappa confermata dall'utente. Copie ora nascono dal corpo e si separano fisicamente per0,5s prima della corsa; getti di particelle arancioni, bordo piu leggibile e aura dorata con fiammate/scintille durante riduzione e coda1,4s. [Controlli e parametri](BROCCOLO_COMBAT_LAB.md#prova-effetti-1810--prima-approvazione-nel-laboratorio). F6 laboratorio, Tab e pulsante Ripeti trasformazione. Nuova scena condivisa PowerVFX abilitata soltanto nel test; **non trasferire alla mappa prima di approvazione, poi usare IDENTICA risorsa/configurazione**. Test VFX headless/GPU e regressione combattimento passati. Mappa/controller/cinematic invariati e non caricati per test.

**Verifica finale18/10:** suite mappa passata,4785punti/3portali, percorso completo8punti attraverso il varco, salto/apertura/attraversamento autonomo, riuso copie e restore vittoria verificati. Log `.godot/broccolo_map_combat_final_pass.log`. Emissioni1,041/0,448ms nella prova mappa; pool GPU isolato0,69/0,573ms. Restano playtest manuale e tuning ambientale; messaggi renderer Dummy a teardown documentati nel registro.

**18/10 — Broccolo in mappa:** integrazione autorizzata dopo approvazione del laboratorio. Copie preparate/riusate, bocca GLB condivisa con morph indipendenti e warmup GPU prima dello scontro. Nuovo componente `BroccoloEncounter/BroccoloMinionSpawner` usa handoff esistente senza modificare cinematiche; principale e tre ruoli combattono in mappa con HUD Broccolo. Grafo multiquota locale e salto/apertura solo WarehouseGrid013/014/015. Prima verifica mappa passata: 4765 punti, tre porte da entrambi i lati e passaggi capsula, riuso copie; controlli finali e limiti nel registro. [Dettagli e Inspector](BROCCOLO_COMBAT_LAB.md#integrazione-mappa-e-copie-preparate-1810). Prossimo playtest in mappa di inseguimento, scale e battenti.

**17/10 — audio Broccolo rifinito:** solo esclamazioni `_mostro` su tutti i corpi;3nuovi `colpito*_mostro` sui danni validi, inclusi letali, senza suono su hit protetto. Passi più presenti (−4dB, attenuazione6m, portata16m e3code). Test PCM sul mixer passato, picco a4m0,014→0,100; proprietà/stream/pause/colpi verificati in `broccolo_audio_feedback_test.gd`. [Guida](BROCCOLO_COMBAT_LAB.md); prossimo ascolto F6. Nessun nuovo gameplay o commit/push.

## 17/10/2026 — varietà copie, esclamazioni, boss progressivo

[Laboratorio](BROCCOLO_COMBAT_LAB.md) scala0,20; copie Assaltatore3,8m/s/Lanciatore2,2/Aggiratore2,8 configurate sotto Roles, sfere energetiche prototipo con occlusione. Principale in disparte a salute alta, più vicino e frequente attaccando a salute bassa; HP/barra solo sui colpi al principale. Esclamazioni4originali+4mostro, bocca RMS, passi player acuti e salti/colpi condivisi. Danze periodiche. **Ultima regola utente:** copie protette durante hit, vulnerabili appena finisce; hit immediato da corsa/fermo. Recupero ostacoli con salti e deviazione. Test ruoli/audio headless, regressione GPU e FPS reale passati; esiti finali nel registro. Mix e ritmo da ascoltare/provare; suoni carica/energia/esplosione dedicati mancanti. Mappa/cinematic preservate, nessun commit/push.

## 17/10/2026 — running Broccolo e prova FPS diretta

Scena utente Broccolo aggiornata a34clip, verificata e lasciata intatta. [Laboratorio](BROCCOLO_COMBAT_LAB.md) ora parte in FPS con lotta automatica dopo shrink; Tab apre studio e il pulsante Gioca riattiva il combattimento. Nuove partenza/corsa/inversione/frenata/atterraggio integrate; waving fra le scenette. Scala0,17 (~30cm), copie con bordo arancione tenue e dispersione casuale distinta prima dell'inseguimento. Test transizioni/ciclo e FPS reale con movimento/input sparo passati. Sfere esplosive ancora future. Mappa/cinematic congelate, nessun commit/push. Backup mirato pre-intervento in `local_optimization/broccolo_running_lab_20261017/`; dettagli/esiti nel registro.

## 17/10/2026 — prototipo boss Broccolo isolato

Nuova scena `scenes/levels/broccolo_combat_test.tscn`, [istruzioni](BROCCOLO_COMBAT_LAB.md). Principale ridotto/aura blu, vulnerabile durante scenette; copie sempre vulnerabili, due impatti e morte prima del VFX finale, emissione dal corpo, cap3 e cooldown6s. Arena AStar3D/CharacterBody, pareti e salto20cm. HUD condiviso con broccolo.png. Test headless/GPU passati; ultima verifica e limiti in SESSION_LOG. Corsa dedicata assente (walking accelerata provvisoria), JumpSlam sperimentale; preview include i tre throw, sfere esplosive future. Cinematic e mappa non toccate. HEAD verificato `3b685e42b67e616334c81008d10575044f95b8e6`, branch `dev/prototype-0.1`; molti file/asset preesistenti locali, nessuno staging/commit/push. Prossimo: playtest F6 e tuning di animazioni/effetti prima dell'integrazione magazzino.

## Punto di ripresa 17/10/2026 — cinematic Broccolo confermata

L'utente conferma che la prima cinematic ora è corretta: movimento uniforme, avanzamento e rotazione coordinati, arrivo nel punto e orientamento previsti. Considerarla bloccata: non ritoccare la prima o la seconda cinematic mentre si prepara il boss. La verifica è playtest visivo dell'utente; nessun ulteriore test automatico richiesto.

Prossimo obiettivo scelto: preparare una scena isolata per provare la boss fight di Broccolo prima dell'integrazione in mappa. Provare corpo principale rimpicciolito e vulnerabile con aura blu, copie 2–3 per ondata che inseguono/attaccano melee, animazioni di corsa/salto/attacco/sneak lungo i muri, hit/death, spawn e sparizione VFX, limite copie e rigenerazione dopo cooldown. Le copie devono avere poca vita (circa due colpi); il boss principale deve ricevere danno. La resa di gioco e i passaggi fra animazioni vanno valutati nella scena test. Il drop-indizio per il prossimo enigma e la vittoria della battaglia restano da definire; prima validare il prototipo isolato.

## Aggiornamento 18/10/2026 — rotazione prima cinematic Broccolo

La seconda cinematic resta congelata nella configurazione già accettata. Modifica limitata alla rotazione della prima camera: il raccordo verso Broccolo ora si distribuisce sull'intera durata del dolly, invece di completarsi prima dell'arrivo. Nessun test eseguito in questa correzione; serve il playtest dell'utente.

La prima cinematic usa una tabella di lunghezza d'arco per distribuire uniformemente il movimento tra rettilineo e curva; il ritardo di inseguimento posizione resta attivo solo nella seconda cinematic. La rotazione parte dall'orientamento iniziale e si raccorda sul progresso del dolly. Seconda cinematic invariata. Nessun test eseguito.

## Aggiornamento 18/10/2026 — seconda cinematic Broccolo, spazio camera

Ridotto l'offset a sinistra da25 a15cm. Il retreat mira a6m nella direzione opposta a Broccolo; nella mappa il percorso sicuro effettivo è4,11m. Lo scaffale passa temporaneamente al layer32: la camera continua a interrogarlo mentre il movimento cinematico/player non ne viene bloccato, poi viene ripristinato al layer1. Test Godot4.7.2 mappa `-- --map --cinematic-only`: `failures=0`, percorso danza senza contatti, distanza camera-attore finale3,10m, arretramento misurato4,11m.

## Aggiornamento 18/10/2026 — collisione scaffale nella danza Broccolo

Per evitare che il braccio attraversi la parete, Broccolo mantiene lo spostamento di0,25m verso sinistra. Solo durante la seconda cinematic viene temporaneamente portato a0 il `collision_layer` di `connesi_building_test2_addon_1/ScaffaleMagazzino/StaticBody3D`; il mobile resta visibile e il suo layer originale viene ripristinato quando torna la camera FPS (anche all'interruzione della regia). Mappa Godot headless `-- --map --cinematic-only`: `failures=0`, danza `3,559m`, contatti capsula0, layer1 disattivato e ripristinato. Playtest visivo utente ancora da fare.

## Aggiornamento 17/10/2026 — movimento della danza Broccolo

Root motion continuo per `dancing3`, `dancing2`, `dancing`; `dance_motion_scale=0.5` riduce il percorso da7,12m a3,56m senza alterare ritmo o pose. Test fixture e mappa `--cinematic-only` passati (`failures=0`, mappa `contacts=0`), nessun arredo spostato. Serve ancora playtest visivo dell'utente.

**Broccolo — camera e continuità del player17/10:** dolly iniziale dritto2,8m prima della curva per superare l'angolo del magazzino; raggio visivo verificato libero. Nella seconda cinematic il retreat cerca diagonali libere fino a1m; nel test mappa seleziona0,63m a−15° per evitare gli scaffali. Il player segue con `move_and_collide`; al rientro FPS conserva la nuova posizione orizzontale e orienta la vista. Riduzione e avvio dello spawner restano successivi alla danza. Fixture e mappa headless `--cinematic-only`: failures0, camera verificata libera al termine del retreat. Playtest visivo utente ancora necessario.

**Broccolo — cinematica17/10:** al termine dell'intro resta in idle verso il player. Nel secondo incontro dialogo e prime due danze restano fermi; solo il salto della clip `mie/dancing` avanza gradualmente fino a0,35m. Camera arrestata all'imbocco; copia telefono rimossa al contatto col pavimento. Fixture e mappa `--cinematic-only` passate, collisioni della posa campionata assenti. Playtest visivo utente necessario. [Guida](BROCCOLO_MAP_INTRO.md).

**18/10 — correzione facing Broccolo:** nella seconda cinematic il corpo del modello guardava dalla parte opposta, anche se il test precedente riteneva corretto l'asse del nodo. La mesh usa fronte locale +Z, mentre `look_at` punta -Z: aggiunta una correzione Inspector di180° e riapplicata dopo il reset della sequenza. Test fixture e mappa con `--cinematic-only`: `failures=0`, facing controllato all'avvio e dopo1,5s di dialogo. Resta il playtest visivo utente.

**18/10 — Broccolo, intro e fase combattimento:** camera avanza in3,25s e la telefonata parte all’88% del percorso. L’attore parte dal lato magazzino (circa X4,5) e il movimento lo porta al marker BroccoloSpawn senza spostarlo; nella mappa il planner trova una rotta yaw−87° e la simulazione completa ha zero contatti attore/camera. Telefono copia RigidBody con gravità/rimbalzo, rimosso dopo contatto e assestamento. Il player che torna entro2,4m innesca la seconda cinematic, dialogo e danza; combat_ready rilascia la regia e avvia 2–3 cloni da20cm, health3, solo corpo a corpo, inseguimento/salto/furtività e hit/death. Fixture e mappa aggiornate passate (`failures=0`); resa audiovisiva e spazio/AI dei minion da confermare in gioco. Le modifiche Broccolo sono file locali/non tracciati; preservare le altre cancellazioni/archiviazioni in working tree. [Guida](BROCCOLO_MAP_INTRO.md).

**18/10 — cinematic Broccolo:** il lancio usa la direzione orizzontale ricavata dal movimento della mano nella clip `trow2`. La seconda camera resta nella posa FPS; il fronte visivo del modello (+Z locale) ora guarda il giocatore dopo il reset del discorso. Root motion globale disattivato nella corsia stretta. Fixture e mappa con `--cinematic-only`: `failures=0`, facing controllato prima e durante il dialogo. Resta il playtest visivo utente prima della boss fight.

**18/10 — ripristino trigger dopo salvataggio scena:** `map_test.tscn` conteneva override `null` per `presentation_scene`, parametri del controller e percorso puzzle; il trigger non trovava la presentazione/puzzle. Rimossi gli override nulli, ripristinato `alien_puzzle_path = ../RegiaIntegration/NetworkPuzzle`, lasciati i default validati nello script. Prova mappa `-- --map --cinematic-only` torna a `BROCCOLO_CINEMATIC_STARTED`, completa intro/secondo dialogo, `failures=0`. Se il checkpoint personale ha già `intro_completed=true`, il trigger resta one-shot; per rivedere la prima intro serve un checkpoint nuovo.

**18/10 — regia Broccolo aggiornata su riscontro in mappa:** la camera parte dalla posa del player, si orienta dolcemente e percorre2,2m dritti lungo l'asse ingresso→lampadario, poi curva a sinistra verso Broccolo; sweep sferico0,3m contro gli ostacoli. Sequenza e resa da riconfermare visivamente dall'utente.

**18/10 — telefono Broccolo:** al rilascio0,76s di `trow2` l'originale viene nascosto e una copia separata vola per1,4s con gravita' visiva ridotta3,5m/s², poi viene rimossa. La posa del nodo originale resta quella salvata dall'utente in `broccolo.tscn`; il restore non lo fa riapparire dopo l'intro. Test fixture e mappa: `failures=0`, `contacts=0`; serve il playtest visivo della nuova durata/regia. [Guida](BROCCOLO_MAP_INTRO.md).

**18/10 — diagnosi isolata telefono:** l'utente ha corretto la posa nel `broccolo.tscn` e confermato che la scena di test ora la riproduce correttamente; anche la successiva prova in mappa ha confermato la posa. La scena di test resta disponibile per confronti futuri.

**17/10 — Broccolo introdotto nel corridoio:** nodo BroccoloEncounter collegato al marker utente e agli interruttori ingresso/corridoio. Trigger su comando riuscito del corridoio, con sblocco alieno e luce ingresso; mai da restore o blackout. Telefonata approvata, pausa lancio22s, walking/idle, traiettoria avanti-indietro adattata alla corsia senza modificare clip o marker. Pianificazione93°/lateral0,2, nessun assestamento spawn; mappa headless passata con zero contatti, fine circa(4,594/0/−6,453) davanti015. Lock/camera/bande e persistenza; su scelta esplicita utente ritorno di controlli/HUD/armi a fine intro. Nessun secondo dialogo o combat automatico. Studio/luci e render isolato passati; resaGPU mappa da verificare manualmente. [Guida e limiti](BROCCOLO_MAP_INTRO.md).

**17/10 — Inspector player e armi:** esteso lo standard generale richiesto dall'utente. Player espone movimento/postura/passi/sensibilita, salute massima/iniziale e inventario allo spawn; WeaponHolder espone possesso/arma iniziale, caricatori/riserva, carica torcia/batterie, tuning melee e armi con gruppi/descrizioni. Defaults e scene invariati. Spawn distinto dai checkpoint, nessun oggetto consumato rigenerato. Guida anche per parametri nativi camera/ray/luci/audio, pickup, item e pericoli ambientali; nome/colore pickup inventario non vengono piu' sovrascritti al ready. Fixture player reale con serializzazione e caricamenti personalizzati passata; regressione inventory_save passata. [Nodi e limiti della copertura](INSPECTOR_CONFIGURATION.md).

**17/10 — configurazione Inspector:** WarehouseDoors non usa piu' CONFIG nello script:12nodi figli con warehouse_door_setup.gd, mesh/cardine/angolo/chiave/audio/evidenziamento esposti e descritti. Angolo determina anche direzione di sicurezza. Sul genitore parametri fingerprint; interruttori e porta base con gruppi e commenti `##`. ID storici conservati, valori default invariati. Test mappa12porte, fixture12luci/6switch, round-trip configurazione e prova editor safe passati. Standard permanente AGENTS/PROJECT_BLOB_STANDARDS e [guida](INSPECTOR_CONFIGURATION.md).

**17/10 — ingresso e lampadine:** collegata Luce Tonda_006 (centro+lati) al nuovo comando ingresso con ID/circuito indipendente eOmni dedicata0,8. Risolta texture emissione lampadari esterna nera usando copia della maschera corretta incorporata nel GLB; ora lampadine sincronizzate agli Spotlight.6switch/12luci/18materiali. Suite mappa e fixture passate; render GPU lampadina off/on ispezionato. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — emissione lati Luce Tonda:** dopo riscontro utente, estesi i riferimenti ai sei gruppi interi, includendo anche body_002_01_black_metall_0 oltre ai centri.12materiali corridoio +2specchi sincronizzati; copie locali e aspetto acceso originale conservati. Script runtime/porte/luci invariati. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — rifinitura richiesta dopo playtest:** utente conferma zona funzionante;038 ora −90°/+X verso giocatore/scale per evitare scaffali (supera il verso precedente). Sei superfici light_003_03_light_0 del corridoio e due specchi bagno collegati agli interruttori con copie locali dei materiali emissivi, off/on/blackout/restore sincronizzati. Originali e texture conservati. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — ampliamento magazzino:**4configurazioni aggiunte a WarehouseDoors (013/014/015 interno+Z,038 pianerottolo−X), libere; totali12porte e11luci/5circuiti. Mappa utente non modificata. Guard quota sull'arretramento della porta superiore e test dedicato; suite porte reale12, luci fixture11 e altezza tutte failures=0. Nessuno slot utente scritto, playtest manuale/GPU nuove porte aperto. Backup e [guida](WAREHOUSE_ZONE_2026-10-15.md).

**15/10 — otto porte collegate:** nuovo WarehouseDoors in map_test crea collider/outline/E e movimento secondo elenco utente; quattro libere, Switch/AssistenzaPrincipale/Produzione richiedono tre chiavi diverse, CED richiede fingerprint con LED blu/rosso/verde e autorizzazione10s. Risorse registrate, nessun pickup collocato o enigma inventato. Raggio capsula privata mappa0,32 per passaggio bagni, controller/altezza/camera intatti. Luci/F4 confermati dall'utente; playtest delle nuove porte da fare riavviando la scena. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**15/10 — accesso test nuova zona:** in map_test F4 prima di Angelastri apre la porta aliena e sospende il suo evento per la prova; solo debug, checkpoint protetto bloccando i salvataggi dopo l'attivazione. Ricaricare per tornare alla progressione normale. Test runtime mappa reale passato, failures=0; playtest dal checkpoint utente ancora da fare. Luci confermate funzionanti dall'utente; porte da implementare secondo elenco, tre chiavi distinte. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**Nuova zona15/10 — priorità corrente:** utente conferma GLB reimportato, aggiunti materiali/luci/interruttori. Collegati5interruttori a7luci con corrente, click, E e persistenza; [guida e test](WAREHOUSE_ZONE_2026-10-15.md). Verifica isolata passa, prova mappa utente aperta. Prossimo porte; CED fingerprint/enigma e boss corridoio con indizio registrati, non implementati.

**Connesi14 nuovo salvataggio15/10 00:13:** normalMaterial.013 rimossa dall'utente; restano3NormalUDIMpacked in Material.012/final1/final3 su altri CamionShell. [Elenco e PNG identici](CONNESI14_EXPORT_MATERIAL_ERROR_2026-10-15.md) in cartella_updated. Test completo helper bloccato da memoria; sorgente/GLB gioco intatti, correzione ancora da applicare.

**15/10 — connesi14 export:** errore riprodotto: Material.013/CamionShell012–013, normal UDIM1001 packed non supportata dall'exporter. [PNG singolo identico e verifica](CONNESI14_EXPORT_MATERIAL_ERROR_2026-10-15.md) pronti, export materiale isolato passa. .blend attivo intatto; applicazione e export completo ancora da fare.

**Punto di ripresa13/10 — Broccolo approvato:** utente conferma «perfetto» e richiede salvare tutto. Bocca,28clip e due presentazioni sono il risultato da preservare. [Guida](BROCCOLO_MOUTH_AND_PREVIEW.md). Prossima fase: integrazione nella mappa e battaglia minion, da sviluppare su nuova richiesta; file salvati localmente, nessun commit/push.

**Broccolo presentazioni13/10:** ora28clip con phone e talk1–4. Due preview separate intro/discourse; audio telefonata sospeso al lancio22s e ripreso durante3,817m di walking, secondo discorso con musica−16dB e danza3/2/1 da21s, poi20cm. [Guida](BROCCOLO_MOUTH_AND_PREVIEW.md). Riscontro audiovisivo utente ancora aperto; minion/mappa fasi successive.

**13/10 — Broccolo:** [bocca e scena F6](BROCCOLO_MOUTH_AND_PREVIEW.md), 23clip, intro_broccolo, danza e riduzione20cm. Test headless/GPU passati; riscontro utente aperto. Minion e integrazione mappa sono fasi successive.

**Broccolo animazioni — 12/10:** [diagnosi e copie compatibili](BROCCOLO_ANIMATIONS.md). GLB con Armature0.01/ossa in cm, clip in metri: bug origine riprodotto e corretto su28copie separate. Folder animation_compatibili/in_place per modello fermo, con_spostamento per movimento originale. 868campioni passati sul vero GLB, originali e scene utente intatti; gradimento manuale aperto.

**Broccolo revisione — 12/10:** sangue approvato dall'utente e conservato. [Diffuse/normal aggiornate](BROCCOLO_TEXTURE.md): badge retro ridotto, Connesi sopra taschino più grande, PARKSIDE sul petto opposto e casco bianco. Nuova normal 4096² creata dalla diffuse aggiornata senza mappa originale; Non-Color → Normal Map in Blender. Render e controlli passati, gradimento nuova disposizione ancora aperto.

**Broccolo — 12/10 sera:** [texture del corpo pronta](BROCCOLO_TEXTURE.md), nuova variante Ch17_1001_Diffuse_Broccolo.png 4096². Gilet blu/Connesi taschino, sangue sugli abiti, PARKSIDE casco e badge rotondo utente dietro. Originali FBX/diffuse invariati, zero nuovi pixel neri, anteprime su modello originale; innesto testa utente non toccato. Assegnazione della variante nel Blender dell'utente e gradimento ancora aperti, nessuna AI/gameplay aggiunta.

**Audio contatore — 12/10:** [timing corretto](REGIA_AUDIO.md): entrambi gli sportelli avviano lo stesso suono all'inizio anche in chiusura. Opt-in su due nodi reali della mappa; altre porte conservano impatto a battuta. Test runtime isolato passato, ascolto utente della correzione aperto.

**Ripresa 12/10, faro Angelastri:** utente conferma KONA V2 reimportata e gioco provato integralmente, tutto funzionante salvo faro che non segue Angelastri in combat. [Correzione mirata](ANGELASTRI_COMBAT.md) nell'encounter; preservati controller boss e luce Bruno. Conferma manuale della nuova correzione aperta.

**KONA V2 — 12/10/2026 sera, TESTATO UTENTE:** [livrea corretta](KONA_CONNESI_LIVERY.md), sagome originali preservate e pallini vicino alle ruote. Utente conferma export/import Godot, gradimento e prova completa del gioco; unica nuova segnalazione faro Angelastri, gestita sopra. V1 superata, backup e originale conservati.

**Asset archiviati — 12/10/2026:** [inventario, eccezioni e ripristino](ASSET_ARCHIVE_2026-10-12.md). Spostati6.047file/13,89GiB in `asset_archive/2026-10-12`, zero cancellazioni fisiche; tutto `assets/models/enemies/` conservato per richiesta utente. Archivio ignorato Godot/Git, registri e restore script pronti. Nessuna nuova dipendenza mancante rilevata, mappa/scorrevoli e inventario/save passati headless. Cache vuota e playtest completo non verificati. Nuove cancellazioniGit rappresentano spostamenti; non usare reset/clean. Nessun commit/push.

**Texture14 importate e misurate — 12/10/2026:** GLBattivo1,746GB, import aggiornato17:35; PNGcampione2K/paved4Kverificati. [Benchmark](CONNESI14_TEXTURE_BENCHMARK.md): risorse texture3.598→3.367MiB (−231MiB/6,4%), rotazioni circa10ms e zero frameoltre50ms nei campioni stabili. Load56,5s contro49,2precedenti, senza confronto controllato (editororaaperto): nessunmiglioramento caricamento dimostrato; picco iniziale3,33s resta. Prossimo profilo caricamento/prewarm e playtest. Nessuna ulteriore modifica o commit/push.

**Texture applicate al sorgente14 — 12/10/2026 sera:** su richiesta esplicita e dopo «salvato e chiuso», aggiornato `Assets_Source/connesi14.blend` delle 16:55 con 26 riduzioni. [Applicazione e backup](CONNESI14_TEXTURES_APPLIED.md). Backup completo in `local_optimization/connesi14_current/connesi14_before_textures.blend`; nuovo file 1,902 GB, 536 immagini conservate, payload non selezionati identici, digest geometria/UV/gerarchie invariato. Copia e installazione verificate SHA256. Serve nuovo export/import/benchmark; GLB attivo ancora precedente. Nessun commit/push.

**Reimport14 — 12/10/2026 pomeriggio:** utente conferma fine import. [Benchmark e collider rack](CONNESI14_REIMPORT_BENCHMARK.md): import190,3MB(−26%), load49,2s/rotazione10ms medi/zero frameoltre50ms nelle rotazioni misurate; confronto indicativo con vecchio benchmark/editoraperto. Scorrevoli e Bruno passati. Corretto solo parentcolliderrack rinominato `Rack Regia` nella mappa. GLBcontiene ancora paved8K/mappeIveco4K: texturecandidate non applicate integralmente. Sorgente14aggiornato16:30, copia precedente00:26non va esportata sovrascrivendo le nuove modifiche. Prossimo playtest e texture su copia del sorgente più recente. Nessun commit/push.

**Connesi14 e copia texture — 12/10/2026:** utente conclude la riduzione mesh; sorgente definitivo00:21 verificato:6,20M triangoli base (−27,7% da13), Panda523k/sportelli12ciascuno. Preparata/riaperta copia isolata `local_optimization/connesi14/connesi14_textures_candidate.blend`:26 texture ridotte,153MB meno sul blend, originali conservati. [Confronto e limiti](CONNESI14_TEXTURE_OPTIMIZATION.md). Godot ancora sul GLB precedente; verifica visiva3D/export/import/benchmark aperti. Nessuna modifica gameplay e nessun commit/push.

**Priorità performance — 11/10/2026:** utente richiede ottimizzazione prima del nuovo gameplay; successivamente chiede suggerimenti su `Assets_Source/connesi13.blend` senza modificarlo. Analisi Blender completata in sola lettura: 3.068 oggetti mesh, 8,58 milioni di triangoli base sulle istanze, 123 texture4K/tre8K; Panda/Default/sportelli contatori primi candidati. [Diagnosi e piano](PERFORMANCE_AUDIT.md). Ripetizione GPU completa: risorse59,3s, rotazione29,7ms medi, pausa28,3ms, senza ombre20,8ms; texture3,58GiB nei contatori motore. Rendering/asset prioritari; benchmark sintetico, editor aperto, non playtest completo. Nessuna modifica gameplay/asset/import/opzioni. HEAD reale `3b685e42b67e616334c81008d10575044f95b8e6`; differenze preesistenti conservate. Nessun commit/push.

**Riferimento Git di chiusura:** gameplay/documentazione consolidati in `674bcf4` e pubblicati su `origin/dev/prototype-0.1` il 11/10/2026. Vedere ultima voce di SESSION_LOG per verifiche, file locali esclusi e limiti del backup.

**Chiusura confermata dall'utente — 11/10/2026:** «ok ci siamo» dopo correzione finale del sangue e prova in game. Conservare la resa attuale di dialoghi, arco 3D, sangue piccolo bordeaux/direzionale, suoni, alone, mirino e combat. F7 passeggiata/F11 combattimento diretto; racchetta I Usa/Riponi, 5 dopo primo uso. Prossima sessione: leggere ultima SESSION_LOG e ANGELASTRI_COMBAT, scegliere il prossimo intervento senza rifare i pezzi approvati. Barra boss grafica finale ancora provvisoria. Commit/push ora esplicitamente richiesti; asset pesanti/commerciali/locali non costituiscono backup Git e restano sul PC finché licenza/dipendenze non sono inventariate.

**Sangue approvato:** rimossa la forzatura verso destra della preview e ridotta l'amplificazione di piccoli movimenti laterali nel getto condiviso. Direzione dal colpo reale + componente verso l'esterno della ferita, gocce/colore conservati; F11 per prova diretta in game.

**Sangue rivisto su riscontro:** eliminati quad che apparivano come occhi verticali; 38 gocce sferiche piccole (raggio0.015), colore bordeaux attuale, getto più stretto28°. Direzione dal movimento reale mano/racchetta fra avvio e impatto, proiettata sul lato visibile del colpo per evitare emissione dentro il corpo. Preview/combattimento aggiornati e test passati; vecchie note sangue texturizzato superate.

**Arco 3D approvato/integrato:** l'utente approva arco della prova, ora usato anche nel combat mappa, stesso settore1.95m a quota busto. Sangue condiviso sostituisce sfere con quad texturizzati sottili/irregolari, rosso scuro/bordeaux, fade; preview aggiornata. La variante flipbook resta prova, tinta più scura. Verifica GPU preview e regressione combat eseguite; gradimento sangue nuovo aperto.

**Prova isolata VFX:** F6 `scenes/levels/angelastri_vfx_test.tscn`, ciclo automatico e pulsanti1/2/3 per sangue attuale, variante schizzo animato e arco 3D all'altezza del busto. Nuovo arco/flipbook soltanto preview: non ancora inseriti nella mappa, per esplicita richiesta utente. Corretta emissione sangue condiviso: particelle spente prima dell'inserimento, piazzate poi restart, evitando emissione iniziale all'origine/pavimento. Preview GPU passata/screenshot ispezionati, gradimento aperto.

**Mirino condiviso e rifinitura VFX:** HUD sostituisce vecchio crosshair con project_blob_reticle.gd, quattro archi/dot e apertura morbida su nemici (take_damage, Bruno incluso) o focus autorevole InteractionSystem per oggetti/pulsanti. Su UI/cinematiche/morte nascosto. Alone rosso ridotto a0.009m/alpha0.2, archi impatto più grandi, sangue34 particelle più grandi/0.65s. Fight senza avvisi testuali. ZombieImpactWave delimita da subito settore reale1.95m e dot>0.35, arco più due bordi laterali, senza espansione. Test GPU combat passato; mirino legacy verificato separatamente.

**Feedback melee Angelastri:** archi impatto/sangue su danno, silhouette rossa durante invulnerabilità, rimbalzo/arco rosso/urto sui colpi respinti; audio punch/racket_hit/zombie utente e swoosh Bruno collegati. Racchetta hold attack1–3 a1.35×; walking/running rallentati e playback legato al movimento reale, schivata sul posto. Suite GPU passata, screenshot ispezionato; F11 per prova audiovisiva.

**Rifinitura fight:** F11 combattimento diretto, F7 passeggiata. Angelastri invulnerabile durante attacchi/morso/schivata/reazione; rabbia e velocità/frequenza morso crescenti con danni, cooldown dopo presa riuscita 5–8 s. Step controllato 0.35 m/floor snap per dislivelli. Test shape reale su gradino 20 cm e regole danno/rabbia passati; nuova navigazione mappa da provare.

**Combattimento Angelastri — 11/10:** prima performance senza freeze/sparizione confermata. Implementati riuso secondo incontro/audio, patrol walking, IA walking/running, due melee e morso, schivate/proiettili sempre innocui, HP/barra provvisoria, reazioni/morte e racchetta dall'avvio fight. **F7 salta direttamente alla passeggiata**; avvicinarsi per discorso/fight. I → Usa/Riponi, 5 dopo primo uso. [Parametri e limiti](ANGELASTRI_COMBAT.md). Test isolati asset reali headless/GPU passati; bilanciamento mappa aperto. Le note sotto sul combattimento non implementato sono storiche.

**Evento Angelastri automatico:** «anche in mappa funziona bene» confermato dall'utente. F6/caricamento mappa ora arresta MenuMusic e riattiva `BackgroundMusic` ambientale; ciascun blackout emette una sola risata forte, click del contatore nella posizione player e notifica `forse è saltata la luce...`. Riarmo successivo 12 s. Il precaricamento viene ripetuto dopo restore, così la terza uscita non esegue né istanziazione tardiva né ricerca fisica pesante; prima danza orientata a tre quarti fra marker e player-side del piazzale, lontano dal camion. Camera esce prima dal varco e usa anche inquadrature basse. [Guida e limiti](ANGELASTRI_ENCOUNTER.md). F10/F11/F12 disabilitati. AI/danni e racchetta arma ancora da implementare; prova utente dal checkpoint post-Bruno richiesta. Parser/stato logico passati; prova mappa automatica rinviata perché la suite non inizializza la scena.

**Sottofondo Angelastri corretto nuovamente:** AudioManager avvia MenuMusic anche in F6; la sola pausa BackgroundMusic lasciava questa seconda traccia udibile. Controller ora sospende entrambe, mantiene pausa durante presentazione e ripristina gli stati alla fine/clear. Test headless sulle due sorgenti passato; ascolto utente ancora da confermare. Spawn marker confermato dall'utente.

**Revisione prova mappa:** spawn dal marker `Angelastri` scelto dall'utente, orientamento verso player per entrambe le sequenze; musica BackgroundMusic sospesa durante presentazione e ripristinata alla fine/rimozione. Marker non ancora presente nel file su disco al controllo: salvare scena editor. Percorso nuovo da provare; misure precedenti riguardano lo spawn storico.

**Angelastri in map_test:** utente approva il dialogo «perfetto, da paura» e richiede prova nella mappa prima della dinamica. [F10 intro/balletto, F11 principale, F12 rimozione](ANGELASTRI_MAP_PREVIEW.md); F9 Bruno conservato. Spawn nel piazzale davanti ai contatori, percorso cumulativo delle quattro danze e appoggio al terreno. FPS libero. Nessuna AI/blackout/combattimento; nuovo playtest mappa aperto. Questa ripresa supera le precedenti note sulla mappa ancora non integrata.

**Ultima revisione dialogo:** gesti completi, riproduzione continua con crossfade 0.55 s e programmazione sul clock voce; posizioni bacino X/Z normalizzate nelle sole copie private del dialogo. Secret anticipata 47→44 s. Finale voce → idle_new completo → talk_to_combat completo → punto combat_ready (preview/handoff, nessuna AI). Nuove risorse utente idle_new/idle_new_breathing e spostamenti balletto originali preservati. Prova audiovisiva nuova aperta.

**Nuove talking:** quattro clip utente caricate senza modificare scena ufficiale, 33 mie/35 totali. Valutate durate e pose GPU, assegnate talking/talking2/talking3 al discorso principale, talking_secret SOLO segmento finale provvisorio 47–54 s. Fra gesti usa talking, finale dopo whisper torna talking3/poi looking. Nuova prova F6 nella scena dialogo; sincronizzazione esatta whisper da ricevere.

**Discorso principale Angelastri:** canto articolato approvato «funziona bene». Nuova preview `scenes/levels/angelastri_dialogue_test.tscn` autoplay discorso reale completo/gesti/RMS/risate, poi looking; intro/balletto approvata conservata nella sua scena. Tempi gesti ancora bozza da valutare sul parlato. Mappa solo dopo questa prova; utente richiede movimento spaziale reale del balletto e continuità da verificare. Nessuna integrazione mappa o combattimento in questo intervento.

**Articolazione canto:** corretta apertura sostenuta segnalata dall'utente. Solo preview modula RMS canzone con aperture/chiusure stilizzate dal clock musica; cue 73.5 s invariato. Headless min 0.00365/max 0.43207, sei chiusure in finestra di circa due secondi, failures=0; pausa/stop/routing, gesti e danze preservati. Non sincronizzazione fonetica, gradimento F6 aperto.

**Secondo pointing intro:** ora pointing2 dopo durata completa del primo pointing (12 + 3.6 = 15.6 s). Eliminata ripetizione primo pointing; canto a 73.5 s musica conservato. Test GPU canto failures=0 (picco 0.528658); nuova verifica mirata secondo gesto nel test headless.

**Canto Angelastri:** sequenza precedente approvata «PERFETTO». Ingresso canto fornito dall'utente 73.5 s dalla musica; ora bocca RMS pilota MP3 da quel cue fino al fade/fine danza. Prima chiusa, pausa/stop/replay e routing Music/SFX ripristinati. Capture unico commuta tra voce e musica; movimento stilizzato dal mix, inclusi strumenti. Test headless failures=0, picco canto 0.540498; riscontro F6 sul nuovo canto aperto.

**Ultima rifinitura:** dance_start_delay=1.0 s richiesto dall'utente; nessun uso di idle nella presentazione (clip per combattimento). Looking durante lead-in e in loop dopo danza con blend 0.6 s, pausa/ripresa funzionanti. Test headless failures=0, fine danza/fade a 112.3 s musica, tutte quattro clip ancora muovono 52 ossa. Prova F6 nuova da ricevere.

**Ultima rifinitura Angelastri:** utente «bellissima» dopo correzione corpo. Preview con danza ritardata di 2 s rispetto alla musica, pointing intro a 12 s (+1), idle↔looking con blend 0.6 s e riproduzione continua. Idle loop solo copia privata, pausa/ripresa rest preservate. Danza 111.3 s invariata; audio ora sfuma alla fine di 113.3 s dall'avvio musica, traccia 125.41 s senza loop. Test su pose verificano continuità/movimento dei blend. Nuovi tempi scelti come prova da affinire con riscontro, non ascolto diretto.

**Correzione corpo fermo nella preview automatica:** segnalazione utente riprodotta con nuovo controllo sulle rotazioni reali dello scheletro: 0 ossa variate prima, 52 dopo. Blend AnimationPlayer 0.15/0.2 s non avanzava perché player messo in pausa dopo seek; passaggi audio-driven ora senza blend pendente. Intro usa pointing nel tratto provvisorio 11–18 s (muro/contatori/asfalto), ripetuto se necessario; timing della frase non ancora verificato da ascolto. Test precedenti sui soli nomi/tempi clip non dimostravano movimento del corpo.

**Ultima traccia utente:** Thriller nuova 125.410249 s, quattro danze 111.3 s: riproduzione unica senza loop, fade ultimo secondo della quarta. AudioStreamMP3 privato legge file reale, evitando vecchio import di 91 s. Autoplay F6 intro→1/2/3/4→idle/looking. Prova GPU completa precedente passata con vecchia musica; nuova traccia verificata per durata/decodifica e test logico, ascolto finale utente aperto.

**Aggiornamento quattro danze:** nuove clip utente thrller_3/4 preservate nella scena ufficiale; preview riproduce 1→2→3→4, totale 111.3 s a velocità originale, 29 mie/31 totali. Musica MP3 privata in loop per superare i 91.0513 s della traccia, compensazione clock al wrap, fade ultimo secondo del quarto balletto. Poi idle/looking. Raccordo sonoro e cue intro da valutare in F6; nessun intervento gameplay.

**Ultima richiesta, prova automatica Angelastri:** F6 avvia intro con gesti e voce, poi entrambi i balletti su Thriller continuo, fade finale e idle/looking periodico. UI semplificata, nessuna selezione necessaria. Modalità manuale precedente conservata dietro export automatic_preview=false. Sincronizzazione semantica intro e gradimento della sequenza restano da ricevere; mappa/gameplay invariati.

**Preview Angelastri fase 1 implementata — 11/10/2026:** figura intera/volto e camera sul bacino, 27 clip con controlli e libreria privata, voci reali/RMS, Thriller separato, sequenza danze 48.6667 s e fade finale. Test headless e GPU failures=0; screenshot di tutte le clip campionati a metà, non prova continua. Gesti dialoghi con tempi BOZZA modificabili in RAM da verificare sul parlato. [Controlli e ripresa](ANGELASTRI_IMPLEMENTATION_PLAN.md). Fase 1 resta aperta per ascolto, sincronizzazione semantica/ritmo e visione continua; fasi gameplay successive non implementate.

**Ripresa attiva — 11/10/2026:** bocca/denti Angelastri V2 approvati dall'utente («ok perfetta»). [Passaggio di consegne completo](ANGELASTRI_IMPLEMENTATION_PLAN.md): risorse, 27 clip mie attuali, quattro audio reali, RacketSocket salvato e decisioni evento. Prima realizzare solo la preview modello/animazioni; poi cinematiche, infine combattimento. Nuove fasi non implementate. Le conferme aperte e i conteggi storici sotto descrivono gli stati precedenti.

**Angelastri V2:** rialzata l'arcata superiore di 1.2 mm per coprirla maggiormente col labbro e aumentare separazione. Variante precedente preservata, HEAD_FILE mouth_preview_v2; conferma finale ricevuta.

**Nuovo Angelastri — 11/10/2026:** su modello ufficiale sgt_Angelastri.glb e scena reale angelastri.tscn, aggiunta variante bocca open/round/smile e arcate continue con texture Bruno V6. Nodo MouthPresentation sostituisce solo testa runtime; corpo/rig/24 animazioni mie conservati. [Prova F6 e limiti](ANGELASTRI_MOUTH.md). Test GPU passato, picco apertura 0.603476; gradimento utente aperto. Voce provvisoria Bruno soltanto nella preview, nessuna voce/AI/gameplay ufficiale ancora assegnati. Originale GLB conservato.

Scorrevoli/audio regia e testo «allo switch» approvati dall'utente («ok ci siamo»); preservarli.

**Scorrevoli audio e testo cavi:** dopo «perfetto» sugli effetti regia, aggiunto sliding_door a laboratorio/bagno regia, apertura e chiusura con stop al termine del movimento e restore silenzioso. Menu ora «Collega allo switch» / «Scollega dallo switch». Originale conservato, estratto senza silenzio iniziale in gameplay/sliding_motion.mp3. Conferma nuova rifinitura aperta.

**Audio regia — 11/10/2026:** effetti utente collegati a tasti/sblocco alieni, battente uscita, mouse/tastiera PC, cavi/caricatore e sfoglio. Originali conservati, estratti temporizzati in assets/audio/edificio/gameplay; SFX e pool locale, niente audio al restore. [Associazioni, tempi e prova](REGIA_AUDIO.md). Test dedicato passato con campioni PCM verificati; prova sonora utente aperta, agente senza ascolto diretto.

Test ciclo mappa headless e GPU Forward+ D3D12 passati con zero fallimenti; GPU include asserzioni su bip, fine posa cavi, sblocco unico, battuta/arretramento e restore silenzioso. Nessuna modifica a mappa/Bruno/SaveManager, nessun staging/commit/push.

**Conferma finale denti — 11/10/2026:** utente «perfetto» sulla V6: arcate continue texturizzate e bordo destro corretto approvati. Lavoro concluso; preservare la versione attiva. La conferma estetica non implica nuove prove complete combattimento/salvataggi.

**Denti V6 attiva:** bordo destro leggermente accorciato/arretrato dopo riscontro V5; texture avorio con separazioni sottili applicata alle fasce continue, GLB incorporato. Test GPU bocca passato; render chiuso frontale/tre quarti senza bianco sporgente. Conferma finale utente in mappa aperta.

**Ultima rifinitura denti:** attiva V5, arcate continue allungate soprattutto all'angolo destro e fasce leggermente meno alte per aumentare lo spazio fra loro. V4 gradita come direzione («ci siamo quasi»), nuova rifinitura da confermare. Bocca/audio invariati.

**Revisione denti prevalente:** V3 respinta dall'utente per quadratini separati/storti; attiva V4 con due fasce continue bianco avorio, profilo regolare e UV per possibile texture futura. Preview e integrazione puntano a V4. Nessuna texture di separazione ancora applicata. Conferma estetica aperta.

**11/10/2026 — denti Bruno:** nuova variante V3 con due arcate semplici color avorio, nascoste a bocca chiusa; inferiore solidale all'apertura. Preview e MouthIntegration caricano V3; varianti precedenti conservate. Test GPU bocca passato, gradimento utente da ricevere. Dettagli e prova in [BRUNO_MOUTH_PREVIEW](BRUNO_MOUTH_PREVIEW.md). Mappa locale reale SHA256 BFC63E1AF1ED572D82BD2DDD25746ABE8DC74832294A413D46ADF974A3BE3CA9, diversa dalla fotografia storica: nessuna modifica alla mappa in questa sessione. Nessun staging/commit/push.

## Punto di ripresa confermato — 11/10/2026

**Ultima conferma manuale — 11/10/2026:** utente: «ok funziona tutto». Confermati nella mappa alimentatore Fritz sulla ciabatta, portatile ridotto, porta aliena che apre verso l'interno sul cardine destro e arretramento solo dal lato interno; chiave scorrevole con messaggio generico. Ridimensionamento uniforme della chiusura segue monitor/tasti/LED/zoom. Prove tecniche ed esiti nell'ultima [SESSION_LOG](SESSION_LOG.md) e nella [guida](REGIA_NETWORK_PUZZLE.md). Per riprendere: non rifare queste modifiche; proseguire con il nuovo obiettivo scelto dall'utente. Rimane separatamente da provare il ciclo completo di salvataggio nella mappa (PC, Carica da pausa/menu, C/N, riavvio). Preservare bocca Bruno, porte approvate, immagini menu e caricamento. Nessun commit/push.

Le voci seguenti sono cronologia; eventuali richieste di conferma estetica che risultavano aperte sono superate dalla conferma qui sopra. La prova del ciclo completo di salvataggio resta aperta.

**Portatile riutilizzabile, inventario e lettura 3D:** dopo «molto meglio» l'utente richiede PC più grande e rivolto alla sedia rossa, caricatore raccoglibile, arresto/raccolta dopo soluzione e documenti realistici. Implementato: display circa 71×44 cm, Ethernet SX/alimentazione DX; caricatore nell'inventario → E sul PC lo monta come scatolina nera con cavi verso PC/ciabatta. Start → Arresta il sistema rifiutato prima dello sblocco; dopo chiude il PC ed esce, E raccoglie PC/caricatore insieme e recupera il cavo PC, senza alterare l'uplink dello switch. Deposito successivo rifiutato. Cinque oggetti con icone e ispezione 3D; descrizioni neutre. Libro/quaderno aperti 3D, texture locali riusate, pagine aliene sfogliabili e solo simbolo WiFi alla terza apertura. State/GPU mappa/lettore/restore in processo nuovo con kit raccolto/inventario C/N passati; regressioni e limiti nell'ultima sessione. Nuova resa da confermare manualmente. Nessun commit/push.

**Revisione visiva regia dopo playtest:** utente «funziona la logica», chiede correzioni estetiche mirate. Portatile ora sulla scrivania sinistra accanto al Fritz, non sul lato del PC ConnesiOS; LED sulle finestrelle originali, nessuna etichetta aggiunta, E sul Fritz collegato apre vista dall'alto con Collegamenti/Esc. Desktop Full HD e font MSDF, stile browser/Fritz dai quattro riferimenti in docs. Wingdings sostituito da dodici lettere armene Sylfaen; schermo alieno nello stesso alfabeto, texture racchetta rigenerata. Rimossi suggerimenti su manico/posizione caricatore; cavi curvi con gioco e innesti; chiave reale key_with_tag da 34 cm. Conferma utente della nuova resa ancora aperta; non estendere «funziona la logica» alla verifica manuale completa salvataggi. Dettagli e test nell'ultima sessione e nella guida. Nessun commit/push.

**Chiusura dopo crash della finestra — istruzioni non ancora lette:** l'utente chiede di salvare tutto negli MD e riprendere in un'altra sessione. Il crash segnalato non è stato diagnosticato: finestra, causa e contesto non verificati; non attribuirlo automaticamente all'esaurimento memoria dei test precedenti. Il puzzle è implementato, ma manca il playtest utente. Alla ripresa leggere l'ultima voce del registro e ripresentare le [istruzioni di consegna salvate](REGIA_NETWORK_PUZZLE.md#istruzioni-di-consegna-per-la-prossima-sessione), poi accompagnare la prova. Non reimplementare il lavoro completato e non considerare questa chiusura un'approvazione del nuovo puzzle. Nessun commit/push.

**Nuovo puzzle regia implementato — 10/10/2026:** piano autorizzato «Implement the plan», portatile/corrente/documenti/cavi recuperabili/Fritz/login/PPPoE/WiFi aperto/tastiera aliena/racchetta esaminabile/luci/persistenza collegati nella mappa addon aggiornata. Correzione utente prevalente: **chiusura aliena non scompare**, resta solidale al battente definitivamente sbloccato e riapribile senza password. Unit state e GPU mappa/save/restore passati, regressione inventario/C/N passata; esiti processo nuovo/intermedi/regressioni nel registro. [Procedura completa](REGIA_NETWORK_PUZZLE.md). Playtest utente del nuovo puzzle aperto, nessun commit/push. Mappa locale aggiornata dall'utente preservata salvo rimozione del solo override verso Portatile scomparso; controller Bruno/cinematica/SaveManager/loader/scena boss invariati. Wingdings 3 usa font locale installato, non copiato nel repo.

**Conferma precedente:** utente «funziona tutto, ora Bruno non si blocca […] se risuccede lo affronteremo». Versione precedente confermata funzionante, segnalazione sporadica archiviata senza nuova correzione AI/collider. Le note sotto su blocco aperto sono storiche.

**Ripresa e segnalazione successiva 10/10/2026:** Git reale `dev/prototype-0.1`, HEAD `2ac4a5fb0953e633915ed862b7942ec3d86771c5` (registrazione documentale del checkpoint `5b3267e`), staging vuoto. Codice/scene tracciati inizialmente senza differenze; conservati sei audio modificati, cancellazioni SilverDelivery e asset non tracciati/ignorati. Utente richiede playtest completo salvataggio e segnala Bruno incastrato nel muro della porta del laboratorio durante combattimento. Due nuove tracce headless dal marker finale intro, player allo spawn e a (6.8, 0.9, 26), attraversano l'uscita esterna aperta: Z finale 19.16 / 18.25; nessun urto contro parete porta registrato. Segnalazione **aperta/non riprodotta**, non considerata risolta: precisare porta, posizione player e fase. Nuova diagnostica `scripts/tests/bruno_lab_exit_diagnostic.gd` (opzione `--far-player`); nessuna modifica gameplay. Bocca/porte/menu/caricamento approvati preservati. Salvataggio manuale nella mappa ancora da confermare; prove automatiche nuove non scrivono slot utente. Nessun commit/push.

**Consolidamento Git richiesto:** commit locale autorizzato dall'utente per codice, scene e risorse Godot testuali, UID e Markdown. Esclusi binari, modelli, texture/audio, PDF, cache e cancellazioni SilverDelivery. Questa baseline conserva l'integrazione ma dipende dagli asset locali esclusi; non è un backup completo esportabile su un altro PC. Hash definitivo verificabile con git log e registro commit. Nessun push richiesto.

**Commit creato:** 5b3267e — Consolidate inventory saves, regia integration and Bruno presentation, 107 file testuali. Baseline di sviluppo locale sul branch dev/prototype-0.1; segue registrazione documentale del risultato. Asset esclusi e cancellazioni SilverDelivery restano fuori commit; nessun push.

Utente: «ok ci siamo» dopo pulizia schermata caricamento. **TESTATO UTENTE: resa finale caricamento approvata**, blob centrale conservato, nessuna striscia decorativa a sinistra/in alto. Nuova partita e Carica condividono loader; immagini Carica collegate nei menu, Nuova partita sopra Carica. Queste attività sono completate: non riproporre integrazione asset o revisione bocca/porte/caricamento.

Mappa: bocca Bruno e passaggi confermati; chiave/drop, tre porte e PC ConnesiOS integrati. Suite inventario/save, restore mappa in processo nuovo e GPU loader passate. Rimane da confermare esplicitamente il playtest completo manuale del salvataggio nella mappa: Salva al PC, Carica da pausa/menu, morte C/N e riavvio applicazione. HUD inferiore rinviata a un obiettivo successivo scelto dall'utente.

Branch dev/prototype-0.1, HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c; staging vuoto, nessun commit/push. Molti file/asset sono locali non tracciati: conservare questa working directory, verificare Git e file reali alla ripresa. Le voci sottostanti sono aggiornamenti cronologici storici: le indicazioni «ancora da collegare» o «conferma estetica aperta» sono superate da questo punto di ripresa.

**Pulizia caricamento, 10/10/2026:** animazione centrale approvata dall'utente. Rimossi accenti laterali e striscia blob superiore dal solo caricamento; cornice, animazione centrale e avanzamento conservati. Inventario mantiene le proprie decorazioni.

**Caricamento unificato, 10/10/2026:** utente conferma funzionamento immagini menu. Nuova partita e Carica salvataggio ora condividono SceneTransition con caricamento threaded, pannello scuro/viola, blob deformabile e bolle ciano, barra interpolata e dissolvenze. SaveManager mantiene copertura e pausa fino al ripristino completo; demo e slot principale conservati. Nuova resa verificata GPU; playtest estetico utente ancora da ricevere. Le note precedenti su immagini da collegare sono storiche e superate.

**Menu Carica salvataggio collegato, 10/10/2026:** immagini utente normale/blob ora associate in `menu_button.gd`, usate sia nel menu iniziale sia nella pausa. Menu iniziale: Nuova partita sopra Carica salvataggio (poi Opzioni/Esci). Verifica runtime texture e ordine passata; conferma estetica utente aperta. Logica caricamento/abilitazione/slot conservata; non resta da implementare il collegamento indicato nella precedente chiusura.

**Chiusura confermata dall'utente, 10/10/2026:** «perfetto ora funziona» dopo correzione attraversamento scorrevole: **TESTATO UTENTE per il passaggio**, senza dedurre prove specifiche di salvataggio/C/N/riavvio. Prossima sessione: usare nei menu i nuovi asset utente `assets/ui/caricasalvataggio.png` e `assets/ui/caricasalvataggio_blob.png`, nello stile degli altri pulsanti. Entrambi presenti localmente; non ancora collegati da questa chiusura documentale. Ripartire dalla nota regia e dall'ultima sessione. Bocca Bruno e passaggi confermati; porte/PC/persistenza integrati e testati automaticamente, playtest completo del salvataggio nella mappa ancora da confermare.

**Attraversamento scorrevoli, 10/10/2026:** blocco utente con porta aperta riprodotto come urto sugli stipiti, vano circa 79.5 cm e capsula player larga 80 cm. `regia_map_integration.gd` ora usa una shape privata con raggio 35 cm per questa mappa; nessuna patch al controller/scena player o alla visiva delle porte. Nuovo test fisico `sliding_passage_test.gd`; prova F8/F6 e attraversamento reale richiesti. [Nota](REGIA_MAP_INTEGRATION.md).

**Regia integrata nella mappa, 10/10/2026:** sui path indicati dall'utente, scorrevole laboratorio DX→SX con chiave, scorrevole bagno libera, battente regia con pannello/maniglie solidali e PC reale ConnesiOS. Drop finale Bruno e stato di porte/pickup/alimentazione/TV/evento/ambiente collegati a SaveManager; slot principale distinto dalla demo. Test mappa salvataggio/restore e GPU click monitor passati; regressioni demo e passaggio Bruno passate. Playtest utente della nuova integrazione aperto. [Nodi, modifiche e procedura](REGIA_MAP_INTEGRATION.md).

**Ultimo riscontro/obiettivo, 10/10/2026:** «ok ci siamo» dopo correzione collider: passaggio Bruno confermato dall'utente. Ora integrazione chiave/drop boss, porta scorrevole con chiave e PC/salvataggi nella mappa, più scorrevole bagno regia senza chiave e porta a battente regia. Utente offre di identificare mesh/pivot; richiesti nomi/path esatti delle porte e monitor. Nel GLB rilevati PCRegia, Porta Bagno Regia, Porta Regia e Porta Regia.001: assegnazione funzionale ancora da indicare, nessun collegamento presunto. Componenti esistenti ispezionati; integrazione tecnica non ancora applicata.

**Correzione passaggio Bruno, 10/10/2026:** bocca confermata funzionante dall'utente nella mappa. Blocco movimento riprodotto anche senza bocca; collider incorporato Parete_013 non corrisponde alla mesh corrente. Rigenerata solo quella forma in `resources/collision/parete_013_current.tres`, collegata nella mappa; AI/collider boss/navmesh/visiva conservati. Test sul punto finale intro: Bruno supera il blocco, failures=0. Playtest completo utente ancora aperto. [Diagnosi e ripresa](BRUNO_PASSAGE_COLLISION.md).

**Bocca collegata alla scena reale, 10/10/2026:** V2 approvata dall'utente («ok ci siamo»). Nuovo componente `MouthIntegration` nella scena boss collega dialoghi della cinematica, frasi/reazioni in combattimento e audio sconfitta. Mappa eredita il componente; controller gameplay/intro/ambiente e file mappa preservati. Prossimo playtest utente su `scenes/maps/map_test.tscn`, poi porta scorrevole/chiave/PC e salvataggi. [Collegamenti e prove](BRUNO_MOUTH_PREVIEW.md).

**Revisione bocca espressiva 10/10/2026:** richiesta attiva completata nella preview: maggiore apertura nel parlato, shape aggiuntive arrotondata/sorriso, risata più ampia dal riferimento temporale originale 11.55 s. Asset nuovi `mouth_preview_v2`, variante approvata precedente conservata. F6 sulla stessa scena; Spazio parlato/risata, L risata, M e 3/4 forme manuali. Conferma utente della nuova resa aperta; [nota aggiornata](BRUNO_MOUTH_PREVIEW.md). Integrazione PC/chiave/salvataggi nella mappa rimane il successivo obiettivo concordato.

**Obiettivi di ripresa concordati:** oltre a terminare la bocca di Bruno, integrare nella scena principale i sistemi già provati separatamente: PC ConnesiOS/salvataggio, inventario, chiave droppata alla morte finale di Bruno e porta scorrevole. Leggere [la procedura di collegamento](INVENTORY_SAVES_CONNESIOS.md), identificare i nodi reali della mappa e procedere SAFE; poi provare salvataggio/caricamento, morte C/N e persistenza nella mappa. Richiesta registrata per la prossima sessione; nessuna integrazione eseguita durante questa chiusura documentale.

**10/10/2026 — bocca Bruno:** scena autonoma `scenes/levels/bruno_mouth_test.tscn`, testa separata con `mouth_open`, RMS della sola voce, default 0.45. Taglio ricalibrato; dopo le istruzioni F6 l'utente conferma «ok bellino»: **TESTATO UTENTE, gradimento generale**. Domani riprendere con movimenti più ampi durante il parlato e valutare forme aggiuntive come “O”; l'apri/chiudi attuale resta accettabile se queste non convincono. Forme aggiuntive non implementate. Originali boss/intro/mappa invariati. [Dettagli e ripresa](BRUNO_MOUTH_PREVIEW.md).

**Ultima conferma utente — 10/10/2026:** «funziona tutto», dopo la revisione inventario/blob, caricamento, C/N e slot separato. Sistema nella scena di prova **TESTATO UTENTE**. La successiva integrazione SAFE nella mappa e il rifacimento della HUD inferiore restano aperti. Questa conferma aggiorna lo stato di verifica della fotografia sottostante, senza certificare la mappa non ancora integrata.

**Ultima implementazione: 10/10/2026.** ConnesiOS approvato e preservato. Inventario industriale sostituito con scuro/viola dei menu e accento blob del boss; HUD inferiore rinviata. Carica nella pausa/menu iniziale, da morto **C carica**, **N ricomincia sempre**. Prova F6 con slot `user://inventory_save_test.cfg`, mappa/menu con `user://savegame.cfg`. Routing, C/N, pausa, riavvio e grafica verificati tecnicamente; nuovo inventario e salvataggio ancora non TESTATO UTENTE. Integrazione nella mappa successiva e SAFE. Leggere [la nota](INVENTORY_SAVES_CONNESIOS.md) e l'ultima sessione. Branch/HEAD `dev/prototype-0.1` / `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c`; nessun commit/push.

Al controllo finale `scenes/maps/map_test.tscn` misura **26.936.463 byte**, timestamp locale **10/10/2026 00:30:45**, diverso dalla lettura iniziale della sessione. Non attribuire questa differenza all'implementazione inventario: nessuna patch dell'intervento tocca la mappa. La nuova versione va letta prima dell'integrazione; il solo timestamp non certifica il contenuto della stanza.

Fotografia del **08/10/2026**, acquisita prima della creazione dei Markdown di continuità. Etichetta: **VERIFICATO LOCALE — ANALISI STATICA**. Ripetere i controlli all'inizio della prossima sessione. Le differenze aggiunte da questa consegna sono annotate nel registro, senza riscrivere l'inventario precedente.

## Repository e strumenti

| Voce | Valore verificato |
|---|---|
| Workspace | `D:\ProjectBlob\Game` |
| Repository root | `D:/ProjectBlob/Game` |
| Branch attivo | `dev/prototype-0.1` |
| HEAD | `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c` |
| Ultimo commit | Complete HUD face reactions for flashlight and battery pickups |
| Data ultimo commit | 2026-10-08 18:15:25 UTC / 20:15:25 Europe/Rome |
| Cronologia raggiungibile da HEAD | 85 commit |
| origin fetch/push | https://github.com/fraidotube/project-blob.git |
| Riferimento remoto locale | HEAD coincide con origin/dev/prototype-0.1 (0 avanti / 0 indietro) |
| Git | 2.39.0.windows.1 |
| Git LFS | 3.3.0 |
| Regole LFS | `*.glb`, `*.blend` |
| Godot, file presente | `D:\ProjectBlob\Tools\Godot\Godot_v4.7.2-stable_win64.exe` |
| Progetto Godot | `D:\ProjectBlob\Game\project.godot` |
| Blender / sorgente .blend attivo | Non verificati |
| PDF fonte | `docs/Project_Blob_Baseline_SAFE_2026-10-08.pdf` |

Il remoto live non è stato interrogato; il confronto usa i riferimenti già disponibili localmente. Git segnala ownership diversa nell'ambiente dell'agente: le letture hanno usato `git -c safe.directory=D:/ProjectBlob/Game ...`, senza modificare la configurazione globale.

## Differenze dalla baseline

Prima della documentazione: **10 file tracciati modificati, 26 cancellati dalla working directory, 258 file non tracciati**, nessun cambiamento nello staging. I 258 includono il PDF caricato dopo il primo controllo, che aveva contato 257 file. Un elenco completo datato è in fondo.

Le cancellazioni riguardano la vecchia cartella `SilverDelivery/Low_World_Base_Male_Character/`. Il percorso nuovo `assets/models/player/` è presente ma non tracciato: verificare se le cancellazioni sono parte dello spostamento, senza ripristinare automaticamente.

I 10 file modificati prima della consegna:

- Sei audio Bruno: `dolore2_mostro.mp3`, `dritto1_mostro.mp3`, `dritto2_mostro.mp3`, `pallina1_mostro.mp3`, `pallina_esplosiva1_mostro.mp3`, `pallina_esplosiva2_mostro.mp3`, sotto `assets/models/enemies/bruno_buozzi/`.
- `scenes/enemies/bruno_buozzi.tscn`.
- `scenes/levels/shooting_range.tscn`.
- `scenes/maps/map_test.tscn`.
- `scripts/systems/interaction_system.gd`.

Gli altri file non tracciati comprendono arredi, modelli player/armi, animazioni/audio/texture Bruno, volto HUD, materiali, UID e copie di script. Non sono conservati da HEAD. Non attribuire intenzione o completamento a un file dal solo nome.

## Mappa e boss

| Dato | Baseline PDF | Locale verificato |
|---|---|---|
| Dimensione map_test.tscn | 53.845.966 byte nel commit GitHub citato | **26.608.635 byte**, 26,61 MB / 25,38 MiB |
| Collisioni concave | Storia: 212, poi 114 in copie diverse | **50** dichiarazioni sub_resource `ConcavePolygonShape3D` |
| Salute Bruno nello script | 180 | 180 |
| Salute nella scena Bruno | Da verificare prima di cambiare | Override **90** in `scenes/enemies/bruno_buozzi.tscn` |

Il conteggio locale non misura le collisioni ereditate da GLB/scene importate o istanziate e non valuta da solo costo/performance. La dimensione è coerente con la dichiarazione storica di circa 25 MB, senza dimostrare quali interventi ne abbiano causato ogni riduzione. Gli override nella mappa e il comportamento runtime devono ancora essere verificati.

## Rilievi aperti

| Rilievo | Evidenza statica | Limite |
|---|---|---|
| Percorsi SilverDelivery | Scene sotto referenziano la vecchia cartella assente | UID/cache possono mascherare il problema; serve importazione completa separata |
| Sensibilità in pausa | Player legge da file in avvio; pausa salva senza aggiornare il campo player | Non riprodotto in gioco |
| SceneTransition su errore | Rami errore dopo fade-in azzerano busy senza nascondere overlay | Potenziale schermo nero/interfaccia bloccata |
| Attese animazioni | Sparo/ricarica attendono animation_finished anche se animazione richiesta manca | Potenziale blocco o completamento su animazione diversa |
| Prompt cinematic | Controllo visibilità Interface e pulizia focus nel locale modificato | Implementato localmente, test/push non certificati |
| GodotLootVFX | Riferimenti assenti sotto assets/BinbunVFX... | Non dedurre coinvolgimento nella mappa principale |
| Codice esteso e copie | Bruno ~4.473 righe, intro ~2.450, armi ~2.151; backup/varianti presenti | Non autorizza refactor o rimozione |

Percorsi assenti rilevati direttamente nelle scene:

| Scena | Dipendenza mancante |
|---|---|
| `scenes/weapons/lowworld_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn` |
| `scenes/weapons/lowworld_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/gltf/a_arms_flashlight_idle.res` |
| `scenes/weapons/lowworld_arms_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb` |
| `scenes/weapons/lowworld_arms_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter.tres` |
| `scenes/pickups/pistol_pickup.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn` |

Sono osservazioni da diagnosi, non bug risolti o autorizzazioni a modificare. Le priorità e i criteri di completamento sono nel [backlog](DECISIONS_AND_BACKLOG.md).

## Asset ignorati e stato degli export

`.gitignore` esclude `.godot/`, import/cache, `assets/models/environment/`, `assets/textures/environment/`, archivi, `*.fbx`, `*.obj`, `*.mtl`, `*.blend`, `*.import`, file temporanei/backup/log, export exe/pck e `export_presets.cfg`. Le regole non rimuovono automaticamente file già tracciati.

`export_presets.cfg` è presente ma non tracciato: preset Windows Desktop, export `./ProjectBlob_demo.exe`, x86_64, PCK separato. Non è stato eseguito un export né verificato il template di esportazione.

I Markdown e Git non sono un backup completo. Per spostare il progetto servono inventario e conservazione anche di asset ignorati, sorgenti Blender e contenuti LFS. Le licenze dei pacchetti non sono state auditate.

## Verifiche eseguite e limiti

Letti configurazione, scene/riferimenti principali, controller pertinenti, standard tecnici, istruzioni scala e tutte le pagine del PDF. Controllati Git, cronologia, branch, remoto configurato, ignore/LFS, dimensione mappa, dipendenze testuali e alcuni override.

**Nessun Godot/Blender avviato; nessun playtest, benchmark, importazione pulita, build/export, fetch, staging, commit o push.** I test nel PDF restano conferme storiche dell'utente. Il primo controllo non trovava Godot nel PATH; il PDF ha consentito di verificarne il percorso reale.

## Inventario Git completo prima della consegna documentale

Output `git status --porcelain=v1 -uall`. ` M` = modifica non staged, ` D` = cancellazione non staged, `??` = file non tracciato. I path fra virgolette usano la rappresentazione di Git. Le esclusioni di ignore non compaiono in questo elenco.

```text
 D SilverDelivery/Low_World_Base_Male_Character/gltf/a_arms_flashlight_idle.res
 D SilverDelivery/Low_World_Base_Male_Character/gltf/mesh_melee.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/mesh_melee.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_character_male.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_character_male.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_pistol.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_pistol.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_revolver.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_revolver.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_shotgun.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_shotgun.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_sniper.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_sniper.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter.tres
 D SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter_placeholder.tres
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_arms_male.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_character_male.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_melee.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_revolver.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_shotgun.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_sniper.tscn
 D SilverDelivery/Low_World_Base_Male_Character/textures/t_lowworld_basemalecharacter.png
 D SilverDelivery/Low_World_Base_Male_Character/textures/t_lowworld_basemalecharacter.png.import
 M assets/models/enemies/bruno_buozzi/dolore2_mostro.mp3
 M assets/models/enemies/bruno_buozzi/dritto1_mostro.mp3
 M assets/models/enemies/bruno_buozzi/dritto2_mostro.mp3
 M assets/models/enemies/bruno_buozzi/pallina1_mostro.mp3
 M assets/models/enemies/bruno_buozzi/pallina_esplosiva1_mostro.mp3
 M assets/models/enemies/bruno_buozzi/pallina_esplosiva2_mostro.mp3
 M scenes/enemies/bruno_buozzi.tscn
 M scenes/levels/shooting_range.tscn
 M scenes/maps/map_test.tscn
 M scripts/systems/interaction_system.gd
?? assets/models/edificio/metal-shelf-5mb/textures/01_DefaultMaterial_Metallic.png
?? assets/models/edificio/metal-shelf-5mb/textures/01_DefaultMaterial_Normal.png
?? assets/models/edificio/metal-shelf-5mb/textures/01_DefaultMaterial_Roughness.png
?? assets/models/edificio/metal-shelf-5mb/textures/alpha-base_color.png
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster.glb"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic010_2K-JPG_Color.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_Color.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_NormalGL.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_Roughness.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_Roughness_5.png"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Wood027_2K-JPG_Color.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Wood027_2K-JPG_NormalGL.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Wood027_2K-JPG_Roughness.png"
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic010_2K-JPG_Color_7.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_Color_4.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_NormalGL_6.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_Roughness_3.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_Roughness_5@channels=G.png
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Wood027_2K-JPG_Color_1.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Wood027_2K-JPG_NormalGL_0.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Wood027_2K-JPG_Roughness_2@channels=G.png
?? assets/models/edificio/office-monitor-workstation-monitor/source/monitor.dae
?? assets/models/edificio/office-monitor-workstation-monitor/source/monitor.stl
?? assets/models/edificio/office-monitor-workstation-monitor/source/read.txt
?? assets/models/edificio/office_chair.glb
?? assets/models/edificio/office_chair_0.jpg
?? assets/models/edificio/office_chair_1.png
?? assets/models/edificio/office_chair_2.png
?? assets/models/edificio/rack_22U.glb
?? assets/models/edificio/warehouse_shelving_unit.glb
?? assets/models/edificio/warehouse_shelving_unit_0.jpg
?? assets/models/edificio/warehouse_shelving_unit_1.png
?? assets/models/edificio/warehouse_shelving_unit_2.png
?? assets/models/edificio/warehouse_shelving_unit_3.png
?? assets/models/edificio/warehouse_shelving_unit_4.png
?? assets/models/edificio/warehouse_shelving_unit_5.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture_.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_texture_0.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_texture_0_metallic_roughness.png
?? "assets/models/enemies/bruno_buozzi/ElevenLabs_2026-10-02T23_03_47_Paolo - Dynamic Italian Radio Voice_pvc_sp100_s50_sb75_v4.mp3"
?? assets/models/enemies/bruno_buozzi/Meshy_AI_Mutated_Tennis_Player_All_Animations_texture_0_2.png
?? assets/models/enemies/bruno_buozzi/Meshy_AI_Mutated_Tennis_Player_All_Animations_texture_0_metallic_roughness_3.png
?? assets/models/enemies/bruno_buozzi/Meshy_AI_Mutated_Tennis_Player_All_Animations_texture_0_mod.png
?? assets/models/enemies/bruno_buozzi/animations/Talk_Passionately.res
?? assets/models/enemies/bruno_buozzi/animations/disappointed.res
?? assets/models/enemies/bruno_buozzi/animations/idle4.res
?? assets/models/enemies/bruno_buozzi/animations/idle7.res
?? assets/models/enemies/bruno_buozzi/animations/laughing.res
?? assets/models/enemies/bruno_buozzi/animations/parla_sx.res
?? assets/models/enemies/bruno_buozzi/animations/risata.res
?? assets/models/enemies/bruno_buozzi/animations/sitting_laughing.res
?? assets/models/enemies/bruno_buozzi/animations/sitting_talking.res
?? assets/models/enemies/bruno_buozzi/animations/talking1.res
?? assets/models/enemies/bruno_buozzi/animations/talking2.res
?? assets/models/enemies/bruno_buozzi/animations/talking_sfida.res
?? assets/models/enemies/bruno_buozzi/animations/trovata_racchetta.res
?? assets/models/enemies/bruno_buozzi/buozzi_avatar.png
?? assets/models/enemies/bruno_buozzi/buozzi_avatar_2.png
?? assets/models/enemies/bruno_buozzi/caduta_fase1.mp3
?? assets/models/enemies/bruno_buozzi/caduta_fase2.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p1.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p12_mostro.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p1_mostro.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p2.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno_monster.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno_monster2.mp3
?? assets/models/enemies/bruno_buozzi/dolore1.mp3
?? assets/models/enemies/bruno_buozzi/dolore2.mp3
?? assets/models/enemies/bruno_buozzi/dolore3.mp3
?? assets/models/enemies/bruno_buozzi/dritto1.mp3
?? assets/models/enemies/bruno_buozzi/dritto2.mp3
?? assets/models/enemies/bruno_buozzi/idle4.glb
?? assets/models/enemies/bruno_buozzi/idle4_texture_0.png
?? assets/models/enemies/bruno_buozzi/idle4_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/idle7.glb
?? assets/models/enemies/bruno_buozzi/idle7_texture_0.png
?? assets/models/enemies/bruno_buozzi/idle7_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/morte.mp3
?? assets/models/enemies/bruno_buozzi/morteBruno.mp3
?? assets/models/enemies/bruno_buozzi/pallina1.mp3
?? assets/models/enemies/bruno_buozzi/pallina2.mp3
?? assets/models/enemies/bruno_buozzi/pallina_esplosiva1.mp3
?? assets/models/enemies/bruno_buozzi/pallina_esplosiva2.mp3
?? assets/models/enemies/bruno_buozzi/parla_manoSX.glb
?? assets/models/enemies/bruno_buozzi/parla_manoSX_texture_0.png
?? assets/models/enemies/bruno_buozzi/parla_manoSX_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/parla_passione.glb
?? assets/models/enemies/bruno_buozzi/parla_passione_texture_0.png
?? assets/models/enemies/bruno_buozzi/parla_passione_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/racchetta_trovata.mp3
?? assets/models/enemies/bruno_buozzi/risata.glb
?? assets/models/enemies/bruno_buozzi/risata_texture_0.png
?? assets/models/enemies/bruno_buozzi/risata_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/rovescio1.mp3
?? assets/models/enemies/bruno_buozzi/rovescio2.mp3
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_0.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_metallic.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_roughness.png
?? assets/models/enemies/bruno_buozzi/test/morte2_0.png
?? assets/models/enemies/bruno_buozzi/testa.glb
?? assets/models/enemies/bruno_buozzi/testa2.glb
?? assets/models/enemies/bruno_buozzi/testa2_texture_0.png
?? assets/models/enemies/bruno_buozzi/testa2_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/testa_texture_0.png
?? assets/models/enemies/bruno_buozzi/testa_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_DIAGNOSTIC.gd
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_DIAGNOSTIC.gd.uid
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_FINAL.gd
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_FINAL.gd.uid
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_SHIELD_DEATH_FIX.gd
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_SHIELD_DEATH_FIX.gd.uid
?? assets/models/enemies/bruno_buozzi/textures/texture_0.png
?? assets/models/enemies/bruno_buozzi/textures/texture_0_mod.png
?? assets/models/enemies/bruno_buozzi/trovata_racchetta.glb
?? assets/models/enemies/bruno_buozzi/trovata_racchetta_texture_0.png
?? assets/models/enemies/bruno_buozzi/trovata_racchetta_texture_0_metallic_roughness.png
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/a_arms_flashlight_idle.res
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/mesh_melee.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_character_male.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_pistol.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_revolver.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_shotgun.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_sniper.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter.tres
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter_placeholder.tres
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_arms_male.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_character_male.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_melee.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_revolver.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_shotgun.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_sniper.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/textures/t_lowworld_basemalecharacter.png
?? assets/models/weapons/Guns/AdditionalMeshes/Projectiles/Texture/Projectiles_Albedo.png
?? assets/models/weapons/Guns/Pistol_01/Textures/Pistol_01_Albedo.png
?? assets/models/weapons/Guns/Pistol_01/Textures/Pistol_01_silhouette.png
?? assets/models/weapons/Guns/Rifle_01/Textures/Rifle_01_Albedo.png
?? assets/models/weapons/Guns/Rifle_01/Textures/Rifle_01_silhouette.png
?? assets/models/weapons/Guns/Shotgun_01/Textures/Shotgun_01_Albedo.png
?? assets/models/weapons/Guns/Shotgun_01/Textures/Shotgun_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/FP_Arms/Texture/FPS_Arms_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/FX/Textures/LowRes_Noise.png
?? assets/models/weapons/RetroWeaponsPack/FX/Textures/MuzzleFlash.png
?? assets/models/weapons/RetroWeaponsPack/Guns/AdditionalMeshes/Projectiles/Texture/Projectiles_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Pistol_01/Textures/Pistol_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Pistol_01/Textures/Pistol_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Rifle_01/Textures/Rifle_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Rifle_01/Textures/Rifle_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Fbx_Files/Texture/SMG_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Fbx_Files/Texture/SMG_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Textures/SMG_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Textures/SMG_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Shotgun_01/Textures/Shotgun_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Shotgun_01/Textures/Shotgun_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Readme.pdf
?? assets/models/weapons/ak47.glb
?? assets/models/weapons/ak47_akmat.png
?? assets/models/weapons/ak47_akmat_1.png
?? assets/package-lock.json
?? assets/shaders/boss_health_blob.gdshader.uid
?? assets/textures/Rack_lab.png
?? assets/ui/face/stato1_1.png
?? assets/ui/face/stato1_10.png
?? assets/ui/face/stato1_11.png
?? assets/ui/face/stato1_12.png
?? assets/ui/face/stato1_13.png
?? assets/ui/face/stato1_14.png
?? assets/ui/face/stato1_15.png
?? assets/ui/face/stato1_16.png
?? assets/ui/face/stato1_17.png
?? assets/ui/face/stato1_18.png
?? assets/ui/face/stato1_19.png
?? assets/ui/face/stato1_2.png
?? assets/ui/face/stato1_20.png
?? assets/ui/face/stato1_3.png
?? assets/ui/face/stato1_4.png
?? assets/ui/face/stato1_5.png
?? assets/ui/face/stato1_6.png
?? assets/ui/face/stato1_7.png
?? assets/ui/face/stato1_8.png
?? assets/ui/face/stato1_9.png
?? assets/ui/face/stato2_1.png
?? assets/ui/face/stato2_10.png
?? assets/ui/face/stato2_11.png
?? assets/ui/face/stato2_12.png
?? assets/ui/face/stato2_13.png
?? assets/ui/face/stato2_14.png
?? assets/ui/face/stato2_15.png
?? assets/ui/face/stato2_16.png
?? assets/ui/face/stato2_17.png
?? assets/ui/face/stato2_18.png
?? assets/ui/face/stato2_19.png
?? assets/ui/face/stato2_2.png
?? assets/ui/face/stato2_20.png
?? assets/ui/face/stato2_3.png
?? assets/ui/face/stato2_4.png
?? assets/ui/face/stato2_5.png
?? assets/ui/face/stato2_6.png
?? assets/ui/face/stato2_7.png
?? assets/ui/face/stato2_8.png
?? assets/ui/face/stato2_9.png
?? assets/ui/face/stato3_1.png
?? assets/ui/face/stato3_10.png
?? assets/ui/face/stato3_11.png
?? assets/ui/face/stato3_12.png
?? assets/ui/face/stato3_13.png
?? assets/ui/face/stato3_14.png
?? assets/ui/face/stato3_15.png
?? assets/ui/face/stato3_16.png
?? assets/ui/face/stato3_17.png
?? assets/ui/face/stato3_18.png
?? assets/ui/face/stato3_19.png
?? assets/ui/face/stato3_2.png
?? assets/ui/face/stato3_20.png
?? assets/ui/face/stato3_3.png
?? assets/ui/face/stato3_4.png
?? assets/ui/face/stato3_5.png
?? assets/ui/face/stato3_6.png
?? assets/ui/face/stato3_7.png
?? assets/ui/face/stato3_8.png
?? assets/ui/face/stato3_9.png
?? assets/ui/face/stato4_1.png
?? assets/ui/face/stato4_10.png
?? assets/ui/face/stato4_11.png
?? assets/ui/face/stato4_12.png
?? assets/ui/face/stato4_13.png
?? assets/ui/face/stato4_14.png
?? assets/ui/face/stato4_15.png
?? assets/ui/face/stato4_16.png
?? assets/ui/face/stato4_17.png
?? assets/ui/face/stato4_18.png
?? assets/ui/face/stato4_19.png
?? assets/ui/face/stato4_2.png
?? assets/ui/face/stato4_20.png
?? assets/ui/face/stato4_3.png
?? assets/ui/face/stato4_4.png
?? assets/ui/face/stato4_5.png
?? assets/ui/face/stato4_6.png
?? assets/ui/face/stato4_7.png
?? assets/ui/face/stato4_8.png
?? assets/ui/face/stato4_9.png
?? assets/ui/hud/bullet_back.png
?? assets/ui/hud/bullet_sfondo.png
?? assets/ui/hud/bullet_smg_final.png
?? character_body_3d.tscn
?? docs/Project_Blob_Baseline_SAFE_2026-10-08.pdf
?? materials/faro2_material.tres
?? materials/faro_material.tres
?? scripts/enemies/bruno_buozzi_hud.gd
?? scripts/enemies/bruno_buozzi_hud.gd.uid
?? scripts/pickups/smg_ammo_pickup.gd.uid
?? scripts/pickups/smg_pickup.gd.uid
?? scripts/systems/hud_face_controller.gd.uid
```

Per aggiornare questa fotografia usare i comandi della [procedura](WORKFLOW_AND_TESTING.md), annotando data, HEAD e limiti della verifica remota. Non copiare automaticamente questi conteggi nel prossimo resoconto.

## Aggiornamento 08/10/2026 — materiale onda di Bruno

Per la successiva modifica della maglietta consultare anche la nota di aggiornamento in fondo e il registro sessioni.

Successivo alla fotografia precedente e alla creazione dei documenti: modificati lo shader attivo e la scena sotto assets/vfx/bruno_melee_banana3d, oltre allo script completo dell'anteprima scenes/vfx_tests/bruno_melee_banana3d_test.gd. Materiale lilla più chiaro, pulsazione morbida e rigonfiamenti radiali; parametri e stato di approvazione nel backlog B03 e nel registro.

L'eseguibile è ora verificato anche in esecuzione: **4.7.2.stable.official.ed1daf0bf**. Anteprima avviata headless; verifica grafica Forward+ D3D12 su NVIDIA GeForce RTX 4060 completata con screenshot e controlli materiali. Nessun test del combattimento nella mappa e nessuna conferma visiva utente ancora ricevuta. Il precedente paragrafo “Nessun Godot avviato” descrive solo la sessione documentale.

Controller Bruno, controller movimento/danni dell'onda e mappa non modificati da questo intervento; conservate le differenze locali preesistenti. Nessun staging/commit/push; HEAD invariato. Script temporaneo di verifica, screenshot e log restano sotto .godot, ignorati da Git e rigenerabili: non sono dipendenze del gioco.

## Aggiornamento 08/10/2026 — maglietta BetterBuozzi

Nuova variante PNG _texture_connesi.png (2508×2508), lettering connesi_wordmark.png e materiale BetterBuozzi_connesi_material.tres nella cartella Bruno. La scena scenes/enemies/bruno_buozzi.tscn usa un override del materiale sul solo corpo; originale PNG, GLB e script Bruno conservati. Import e rendering della mesh di riposo confermati, animazioni/playtest/conferma utente aperti. Tutto locale, nessun commit/push. Dettagli e prompt nella [nota asset](BETTERBUOZZI_CONNESI_TEXTURE.md).

# Aggiornamento cinematic Broccolo (17/10): la prima camera ruota gradualmente durante il dolly; nella seconda cinematic segue waypoints fino alla svolta salvata della prima ripresa e il player la segue con collisioni. Nella mappa il percorso è di4,8m e termina in un punto libero a0,39m dal target; raggio anticollisione0,32m. L'idle ruota quando Broccolo esce dal campo visivo e la posa persistente viene catturata al termine del rientro. Il salto di `mie/dancing` avanza fino a1m. Test mappa `--cinematic-only`: failures0; playtest visivo richiesto.

Aggiornamento: il secondo dialogo parte contestualmente alla camera, senza pausa idle. Sequenza parlato `talk1` → `talk2` → `talk4` (esclusa `talk3` su richiesta). Incrementato a2m l'avanzamento associato al salto finale. Test mappa `broccolo_encounter_test.gd -- --map --cinematic-only`: failures0; resa visiva e ascolto ancora da provare dall'utente.
**19/10 — Luci boss fight Broccolo:** sfumatura viola tenue alle luci ambientali all'avvio, ripristino esatto a morte/stop/uscita. Intensità configurabile; luci dei personaggi escluse. Playtest visivo all'utente.
**19/10 — Playtest luci Broccolo e offset seconda scena:** l'utente conferma la tinta viola in combattimento. Il default Inspector per l'offset a destra della seconda presentazione passa da 0,35 a 0,45 m (+10 cm), sempre subordinato al controllo di spazio.
