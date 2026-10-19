# Project Blob — procedura di lavoro e verifiche

**Audio e invito Broccolo (19/10):** controlli statici per stream assegnati, offset/durate e condizioni di stop; la prova soggettiva va fatta con audio reale, non Audio Dummy. In gioco ascoltare voce+carica durante shrink, aura/pop per ogni copia, lancio sincronizzato con la sfera, impatto solo quando infligge danno, musica durante e dopo la vittoria; avvicinarsi all'interruttore per controllare pulsazione, portata e spegnimento. L'utente esegue il playtest visivo/audio.

**Broccolo, seconda posa e shrink (19/10):** dopo una modifica alla posa verificare l'offset rispetto alla camera e la collisione col mobile in gioco. Verificare inoltre che il presenter mappa consegni `combat_ready` senza shrink e che l'unica riduzione visibile sia quella del combattente con aura. Per questa consegna l'utente ha riservato a sé la prova: non avviare Godot né test automatici.

**Regia Broccolo19/10:** eseguire `broccolo_encounter_test.gd -- --cinematic-only` fixture e poi `broccolo_encounter_test.gd -- --map --cinematic-only`, in sequenza. Verificano avanzamento rettilineo lungo corridoio, svolta a sinistra, sweep, visuale libera sul bersaglio al cue, risposta sincronizzata a13,5s e seconda cinematic. Per la mappa la suite carica l'edificio completo; il test headless non giudica composizione, quindi l'utente prova il movimento in gioco e ascolta la suoneria/risposta.

**Sfera/incendio18/10:** `broccolo_energy_burn_test.gd` headless poi GPU per catture nucleo/aura e bordi FPS, impatto swept reale,12danni periodici, refresh senza stacking, pause/scadenza/morte/stop, parete, AoE senza incendio, parametri nondefault serializzati. `broccolo_roles_audio_test.gd` ora sottrae i danni incendio registrati per verificare separatamente il singolo impatto7. Non caricare mappa in questa fase. Manuale F6 laboratorio e Tab / Prova bruciatura in FPS, poi lanci reali del caster; screenshots non sostituiscono playtest di mira/mix/ritmo.

**VFX Broccolo18/10:** `broccolo_vfx_lab_test.gd`, headless e GPU per screenshot trasformazione/coda/nascita/bordo. Include posizione iniziale identica al principale, emersione prima dello scatter, getti entrambe le istanze, pausa/spegnimento/pool, collisione muro, durata custom, hit durante nascita e legacy senza profilo. L'approvazione del pacchetto abilita il riuso delle stesse risorse nella mappa; verificare collegamenti e handoff anche con `broccolo_encounter_test.gd -- --map`.

**Broccolo mappa/pool18/10:** `broccolo_pool_test.gd` verifica costruzione anticipata, singola lettura GLB, espressioni indipendenti e reset/identita copia riusata; eseguire anche GPU per warmup. `broccolo_map_combat_test.gd` carica mappa reale e usa handoff combattimento senza riprodurre cinematiche congelate: tre porte, salto da entrambi i lati, passaggio fisico, inseguimento automatico, navigazione e stato vittoria. Eseguire map test pesanti in sequenza. Regressione laboratorio conserva verifica dying ma attende stato pooled nascosto anziche distruzione. Nessuna scrittura slot utente. Controllo tecnico non sostituisce playtest mappa, ascolto o certificazione fluidita su altro hardware.

**Broccolo ruoli/audio17/10:** `broccolo_roles_audio_test.gd` verifica profili, barra indipendente, hit immediato da corsa/protezione copie durante hurt, boss più aggressivo a bassa vita, voci/pausa/bocca, danza periodica, lancio automatico singolo/danno e occlusione esplosione, waypoint laterale, passi pitched e salto→escape da blocco fisico. GPU produce `.godot/broccolo_lanciatore.png`. Regressioni `broccolo_combat_lab_test.gd` e `broccolo_lab_fps_test.gd` aggiornate per attendere la fine della reazione prima del secondo impatto valido. Audio Dummy non certifica ascolto/mix; provare F6 con audio attivo. Mappa/cinematic fuori scope.

**Broccolo running/FPS17/10:** `broccolo_combat_lab_test.gd` ora verifica anche start/run/turn/stop/land, nuove clip cicliche/one-shot, emissioni distinte, aura e scala. Eseguire poi `broccolo_lab_fps_test.gd` per avvio automatico, input movimento e spari reali con consumo ammo/due colpi su copia. GPU della prima suite produce le sei pose `broccolo_run_*.png`, senza viewmodel davanti alla camera studio. Il laboratorio F6 parte direttamente giocabile; Tab apre studio. Non testare le cinematic congelate per questa modifica isolata.

**Laboratorio boss Broccolo17/10:** `--script res://scripts/tests/broccolo_combat_lab_test.gd`, headless o Forward+ D3D12. Verifica danni e finestre immunita, due colpi/copie, dying/rimozione, origine emissione/cap/cooldown, grafo/percorso parete e salto20cm, melee singolo, configurazione Inspector nondefault serializzata in `.godot`. Non scrive slot. GPU produce protetto/vulnerabile/ciclo in `.godot/broccolo_lab_*.png` e `broccolo_combat_lab.png`; il playtest F6 resta necessario per clip/ritmo/VFX. [Controlli e limiti](BROCCOLO_COMBAT_LAB.md). Non eseguire regressioni delle cinematic congelate per questa fase isolata.

## Regia iniziale Broccolo, marker, idle e cue suoneria (19/10/2026)

La mappa assegna `BroccoloCameraStop` al controller. L'avvio mostra `mie/idle` in loop; al cue `13,5−3,5s` il sequencer lo sostituisce con la risposta, e il dolly raggiunge il marker sul cue finale. La regressione `broccolo_encounter_test.gd -- --cinematic-only` e `-- --map --cinematic-only` controlla anche idle continuo e interruzione al cue. Su richiesta dell'utente, per questa rifinitura non eseguire test/playtest Godot: l'utente farà la prova completa in mappa. Nessun controller o scena degli altri boss va toccato.

## Prossima fase Broccolo — boss in scena isolata (17/10/2026)

Non usare la mappa per il primo tuning del combattimento. Preparare una scena di test separata e verificare prima il corpo principale rimpicciolito/aura blu/danno; poi copie melee fragili, navigazione e salto ostacoli; quindi sneak, animazioni hit/death e VFX; infine cap copie e cooldown di rigenerazione. Solo dopo il playtest utente del prototipo pianificare l'integrazione nel corridoio e il drop dell'indizio. La prima e la seconda cinematic Broccolo sono approvate e fuori scope, salvo nuova richiesta esplicita.

## Broccolo — regressione del movimento durante la danza (17/10/2026)

Eseguire in sequenza fixture e mappa: `broccolo_encounter_test.gd -- --cinematic-only`, poi `broccolo_encounter_test.gd -- --map --cinematic-only`. Il test osserva dancing3→dancing2→dancing, percorrenza prima/durante il salto, capsula lungo il tragitto, tracking camera e ritorno. Ultimo test: failures0; percorso3,56m e nessun contatto nella mappa. Il parametro `dance_motion_scale` si regola in BroccoloEncounter. Il playtest resta necessario per confermare il ritmo e la distanza a vista.

**Seconda cinematic Broccolo:** `broccolo_encounter_test.gd -- --cinematic-only` e `broccolo_encounter_test.gd -- --map --cinematic-only` verificano linea di vista iniziale oltre l'angolo, arretramento progressivo, player che segue la camera, rotazione di mira e posizione conservata al ritorno FPS. Il test porta il retreat al massimo, controlla il volume camera finale e richiede almeno0,2m di arretramento; nella mappa il planner trova0,63m su una diagonale−15°. Test17/10: entrambe failures0. La prova non valuta estetica in movimento e non è playtest della boss fight.

**Cinematica Broccolo — salto danza:** eseguire `broccolo_encounter_test.gd -- --cinematic-only` e `broccolo_encounter_test.gd -- --map --cinematic-only`. Il test controlla immobilità prima del salto, avanzamento nella finestra rilevata di `mie/dancing` e intersezioni della capsula con la mappa. Esito headless18/10: entrambe `failures=0`; direzione e resa della coreografia richiedono playtest visivo.

**Facing Broccolo18/10:** dopo ogni modifica alla seconda cinematic eseguire in sequenza `broccolo_encounter_test.gd -- --cinematic-only` e `broccolo_encounter_test.gd -- --map --cinematic-only`. Il controllo deve usare il fronte visivo +Z del modello e ripeterlo dopo almeno1,5s di dialogo; verificare anche a vista prima di procedere con la boss fight.

**Broccolo18/10, regressione cinematica mirata:** eseguire in sequenza `--script res://scripts/tests/broccolo_encounter_test.gd -- --cinematic-only` e poi lo stesso comando con `-- --map --cinematic-only`. Il test si ferma durante il secondo discorso, prima dello spawner/combat. Verifica il lancio allineato al gesto della mano, intro senza collisioni sulla mappa, camera seconda ferma alla posa FPS, orientamento verso Broccolo/player e assenza di root displacement globale in spazio stretto. Non sostituisce il playtest GPU/visivo di volo, inquadratura e postura. Il crash delle copie non è coperto e resta da indagare nel lavoro combat separato.

**Broccolo18/10, seconda cinematica e ondate:** `broccolo_encounter_test.gd` in fixture e `-- --map` controlla camera/dolly, intro ritardata, root-motion dal lato magazzino fino al marker, collisioni, lancio RigidBody e rimbalzo, ritorno controlli, trigger entro2,4m, avvio discorso e handoff `combat_ready` a2–3 minion. Ultima mappa completa: `failures=0`, attore `contacts=0`, camera `camera_contacts=0`, fine `(0.108, 0, -6.243)` vicino al marker. Avviso certificati di sistema/log `user://logs` non scrivibile e warning di teardown non alterano gli assert. Restano playtest visivo/audio e prova manuale degli spazi/AI dei minion. Regola di vittoria e loot non implementati.

**Broccolo18/10, camera/lancio:** `broccolo_encounter_test.gd` verifica asse ingresso→lampadario, tratto camera dritto, svolta a sinistra, orientamento finale su Broccolo e collisioni camera campionate. La mappa completa parte accanto al trigger reale e passa con `camera_contacts=0`; la copia resta almeno1s sopra pavimento, durata1,4s, scomparsa e restore nascosto anche con telefono originale inizialmente visibile. Fixture e `-- --map` passati (`failures=0`, mappa `contacts=0`). Playtest manuale ancora necessario per giudicare distanza dalle scatole, dolcezza della curva e leggibilità del prop.

**Telefono Broccolo17/10:** `broccolo_encounter_test.gd` passata in fixture e con `-- --map` sulla mappa completa: entrambi `failures=0`, mappa `contacts=0`. Verifica che l'originale resti agganciato/immutato, che la copia appaia al rilascio, si muova in avanti e in alto e sparisca entro la durata configurata; controlla pausa voce e snapshot/reset. Nessuno slot utente scritto. Resta la prova manuale luce ingresso→lampadario, ascolto dell'ultima parola e controllo visivo del distacco/volo breve. La precedente prova di CCD/urto/caduta non copre la nuova implementazione.

**Confronto telefono scena/runtime18/10:** il vecchio `broccolo_phone_pose_probe.gd` verificava il presenter contro il valore corrente del file, non contro la posa precedentemente impostata dall'utente. L'utente ha poi corretto la posa in `broccolo.tscn` e confermato che scena isolata e mappa ora la riproducono correttamente; il probe non deve essere usato come prova che il transform salvato sia quello voluto.

**Isolamento telefono Broccolo18/10:** aprire `scenes/levels/broccolo_phone_isolation_test.tscn` ed eseguire con F6. Istanzia direttamente `scenes/enemies/broccolo.tscn`, abilita la visibilita' del telefono e avvia l'AnimationPlayer originale su `mie/phone_answer_talk`; nessun presenter, copia di animazione, root-motion esterno o scrittura di transform. Spazio pausa/riprendi, R riavvia, F cambia vista anteriore/posteriore, frecce avanzano/arretrano di un frame. Confrontare qui con il playback editor, poi con la mappa per isolare il punto in cui cambia la posa apparente. La verifica headless conferma caricamento e avvio, non la resa visiva.

**Broccolo mappa17/10:** `broccolo_encounter_test.gd` verifica player/modello/audio reali, gating porta/corrente/ingresso/comando corridoio, nessun trigger da restore, lock/pausa/rilascio, percorso continuo, mouth RMS, evento singolo e persistenza idle; `-- --map` usa la mappa completa e campiona una capsula contro le collisioni. La variante `-- --map --cinematic-only` controlla la danza completa, collisione temporanea dello scaffale e ripristino del suo layer quando torna la camera FPS. Suite mappa pesanti sempre sequenziali. GPU fixture senza --map consente inquadrature su corridoio neutro; non equivale alla resa nella mappa. Ripetere warehouse_lights_test e broccolo_presentation_test per regressioni. Manuale F4 oppure progressione normale → ingresso → E corridoio, ascolto voce/lancio e valutazione posizione finale. [Guida](BROCCOLO_MAP_INTRO.md).

**Inspector player17/10:** `player_inspector_configuration_test.gd` usa player reale in fixture serializzata `.godot` con figli modificabili: defaults, salute/movimento/passi/FOV, possesso/arma/caricatori/riserve, consumo e ricarica torcia, capienza batterie, nuova partita tramite SaveManager e startup diretto con setup differito, checkpoint prioritario e nessun grant di item consumati; verifica override nome/colore ItemPickup dopo ready. Nessuno slot utente scritto. Regressione `inventory_save_test.gd`; `angelastri_combat_test.gd` per melee/racchetta. Manuale nuova partita vs Carica, selezione slot/ricarica/E e postura in passaggi: headless non giudica audio e resa FPS. [Nodi da selezionare](INSPECTOR_CONFIGURATION.md).

**Magazzino/bagni15/10:** warehouse_lights_test.gd genera fixture dalle sezioni vere map_test e dipendenze minime:5switch/7luci, Inputinteract reale, raymask2, corrente/circuiti/click/focus e ricostruzione/persistenza inRAM, nessuno slot utente. Poi F6 mappa per accessibilità e resaGPU. [Guida](WAREHOUSE_ZONE_2026-10-15.md). In questa fase porte/CED/boss restano futuri.

**Broccolo presentazioni13/10:** broccolo_presentation_test.gd per entrambe le sequenze in tempo reale e broccolo_preview_test.gd per28clip/bocca/danza standalone; GPU Forward+ D3D12 per screenshot. Manuale F6 broccolo_intro_test e broccolo_discourse_test: anticipo gesto risposta3,5s, saluto22s/pausa lancio/ripresa audio, camminata e idle; secondo discorso con musica sottofondo, gesti, demi-plié21s/danze3→2→1, fine frase e20cm. Spazio durante lancio deve mantenere audio sospeso; verificare volume e transizioni ascoltando. [Guida](BROCCOLO_MOUTH_AND_PREVIEW.md). Nessuno slot utente o mappa coinvolti.

**Combat Angelastri:** `angelastri_reuse_patrol_test.gd` e `angelastri_combat_test.gd` in sequenza, poi suite mappa. Fixture player/modello reali, nessuno slot utente scritto. Manuale F7 → patrol → avvicinamento → discorso/fight, I Usa/Riponi, 5/slot1–4, proiettili innocui, due melee/morso/rilascio, pausa/morte, sconfitta/save/restore. [Guida](ANGELASTRI_COMBAT.md).

**Evento Angelastri:** suite logica angelastri_event_test.gd e suite mappa GPU angelastri_encounter_map_test.gd, in sequenza. Fixture .godot distinta dagli slot utente; controllare F6 e caricamento slot senza MenuMusic, tre uscite con click/notifica/risata, attesa di 12 s dopo i primi due blackout, passaggio camera fuori dall'arco senza clipping, faro/HUD/arma e seconda vista. [Prova dal checkpoint post-Bruno](ANGELASTRI_ENCOUNTER.md). Le immagini/clock accelerati non equivalgono al playtest audiovisivo completo.

**Prova mappa Angelastri:** `angelastri_map_preview_test.gd` GPU in processo singolo; `-- --survey` per candidate di spawn. [Playtest F6, F10/F11/F12 e limiti](ANGELASTRI_MAP_PREVIEW.md). Controllare percorso reale, continuità, pavimento, libertà FPS e cleanup; il campionamento automatico non sostituisce ascolto e osservazione utente. Preservare le suite studio già approvate.

Ultimo finale principale Angelastri: test continuo copre voce (~57 s), idle_new intero (8.3333 s), talk_to_combat intero (1.1667 s) e combat_ready, non più ritorno looking. Controlla fine dei gesti, drift X/Z, variazione pose per frame, risorse private distinte, secret da 44 s, pausa/replay e handoff unico. F6 angelastri_dialogue_test per gradimento audiovisivo; AI/mappa restano fase successiva.

Discorso principale Angelastri: F8 → `scenes/levels/angelastri_dialogue_test.tscn` → F6, autoplay. Test `--script res://scripts/tests/angelastri_dialogue_test.gd` osserva l'intera durata reale (~57 s), gesti, movimento ossa/bocca, pausa/ripresa, assenza musica/idle combattimento, looking finale, replay e bus rilasciati. Non dimostra che gesti siano esattamente sulle frasi: verificare ascoltando in F6. Successiva mappa richiede controllo spostamenti reali del balletto e continuità quattro clip, non solo camera preview.

Angelastri: `--script res://scripts/tests/angelastri_mouth_test.gd`, GPU Forward+ D3D12 per closed/open/round/smile e voce provvisoria. Controlla materiale/transform, animazioni, stop/pause/bus; manuale F6 `scenes/levels/angelastri_mouth_test.tscn` e M/1/2/3/4/O, menu clip. Voce originale di Bruno solo test, non dialogo Angelastri. [Variante densa, fonti e limiti](ANGELASTRI_MOUTH.md).

Audio regia: `regia_audio_test.gd` headless verifica input reale, pool, pause e campioni PCM su capture SFX temporaneo; poi `regia_network_map_test.gd` sequenziale per eventi/animazioni porta/cavi/sblocco e restore silenzioso. Provare con audio attivo nella mappa soprattutto estratto elettrico e livelli; [associazioni e limiti](REGIA_AUDIO.md). Audio Dummy e analisi FFmpeg non equivalgono a ascolto diretto o gradimento.

Rifiniture 11/10: regia_network_map_test verifica riduzione PC, prop Fritz, dodici clic alieni dopo scala uniforme 0.75 e distanza dello zoom proporzionale. Verifica arretramento all'apertura iniziale via password e alle aperture successive, controller inizialmente attivo/disattivo ripristinato, lato opposto immobile, ostacolo nel percorso che impedisce apertura, battente interno e sweep nelle due direzioni, save/restore e raccolta kit. Screenshot network_fritz_power/desk_cables/exit_open. Manuale: F8/F6, osservare alimentatore sulla presa (non sull'interruttore), dimensioni PC e cavi; aprire vicino alla chiusura da entrambi i lati e durante pausa. Scala uniforme del nodo chiusura, non applicata ai vertici in Blender, conserva montaggi; dopo un nuovo export controllare inquadratura e tutti i tasti. Ultimi esiti nel registro.

Kit riutilizzabile: regia_network_state_test verifica caricatore prima/dopo PC, consumo/recupero, arresto vietato/consentito, capienza e snapshot legacy/kit. regia_network_map_test verifica clic Start/Arresta, chiusura/Esc automatico, raccolta e ispezione dei cinque item; fixture originale pre-raccolta conservata, nuovo slot .godot/regia_network_packed_slot.cfg. Ripristino nuovo processo con -- --packed-test. regia_book_reader_test GPU verifica sfogliatura avanti/indietro, WiFi nell'ultima apertura e annotazioni PPPoE/login, produce book_reader_*.png. Regioni texture verificate sugli atlanti reali. Non attribuire a un test di presenza dei testi la leggibilità: ispezionare anche le immagini.

Revisione visiva regia: `regia_terminal_render_test.gd` produce desktop/login/PPPoE/WiFi Full HD e controlla clic alle coordinate reali. `regia_network_map_test.gd` controlla anche posizione PC vicino al Fritz, zoom dall'alto e pulsante Collegamenti, modello KeyWithTag e snapshot, producendo network_fritz_zoom/desk_cables/power_cable/key_with_tag. Confermare manualmente cavi, alfabeto e posizione dalla visuale player; gli screenshot di fixture non equivalgono a gradimento utente. Font ora Sylfaen locale con glifi armeni, non Wingdings.

Puzzle rete regia: `regia_network_state_test.gd` per regole e font; `regia_network_map_test.gd` GPU per interazioni/clic/sweep/salvataggio. Poi stesso script in processi separati con `-- --continue-test` e `-- --partial-test`. Slot automatico `.godot/regia_network_test_slot.cfg`; preservare slot utente. Dopo variazioni comuni UI/inventario ripetere inventory_save_test, sliding_passage_test e bruno_passage_test. [Playtest manuale e limiti](REGIA_NETWORK_PUZZLE.md). La chiusura aliena deve rimanere agganciata al battente anche dopo sblocco e restore.

Eseguire le suite della mappa **in sequenza**: nella sessione rete, due istanze headless concorrenti hanno fallito allocazioni e causato crash (modello edificio locale circa 2 GB). Ripetizioni singole passate. UI Fritz finale verificabile separatamente con `regia_terminal_render_test.gd`, senza caricare l'edificio. Non scambiare gli errori di parsing risorse conseguenti a Out of memory per una corruzione degli asset originali.

Caricamento: eseguire scripts/tests/loading_transition_test.gd (headless oppure Forward+ D3D12). Verifica caricamento mentre albero in pausa, UI visibile fino a reveal, risorsa non-scena con errore intenzionale e overlay liberato, successiva transizione valida. GPU produce .godot/loading_screen.png. Ripetere inventory_save_test.gd e regia_map_test.gd -- --continue-test per restore. Playtest: F5 Nuova partita, Carica dal menu iniziale e dalla pausa, C dopo morte; verificare che HUD e input ritornino dopo ripristino. Non usare gli slot utente per test automatici.

Per porte nuove verificare anche attraversamento con il collider **reale del player**, non solo movimento del pannello/assenza di vecchie collisioni: `--script res://scripts/tests/sliding_passage_test.gd`. La suite controlla chiuso bloccante e aperto libero nelle due direzioni. Limitare la traiettoria al vano, distinguendo arredi oltre la porta da ostacoli del passaggio.

Integrazione regia: [playtest F6 e nodi](REGIA_MAP_INTEGRATION.md). Suite mappa `--script res://scripts/tests/regia_map_test.gd`, poi `-- --continue-test` in processo separato; fixture in `.godot`. GPU `regia_render_test.gd` verifica click sul monitor reale. Prima di consegnare nuove modifiche a questa zona mantenere anche regressione passaggio Bruno. Non usare la suite automatica per sovrascrivere `user://savegame.cfg`.

Regressione passaggio Bruno: `--script res://scripts/tests/bruno_passage_test.gd`, verifica triangoli Parete_013 e movimento dal marker finale intro con bocca integrata. [Diagnosi e generatore](BRUNO_PASSAGE_COLLISION.md). Dopo reimportazioni non assumere che collider incorporati corrispondano ancora alle mesh: confrontare la forma del collider effettivamente coinvolto prima di cambiare AI o dimensioni boss.

Prova bocca Bruno: [procedura F6, controlli e limiti](BRUNO_MOUTH_PREVIEW.md). Test ripetibile `--script res://scripts/tests/bruno_mouth_test.gd`, headless con audio Dummy o Forward+ D3D12 per screenshot. Dopo modifiche alla geometria verificare soprattutto M/O e 1/2; i test audio non sostituiscono la verifica artistica del taglio.

## Riprendere una sessione

1. Leggere [indice](README.md), contratto SAFE, stato e ultima sessione.
2. Verificare repository/branch/HEAD e differenze locali prima di modificare.
3. Definire obiettivo richiesto e criteri di completamento; non attivare autonomamente il backlog.
4. Leggere integralmente script, riferimenti e override scena. Se differiscono dal Git, confrontare prima di intervenire.
5. Identificare baseline ripristinabile e lavoro locale da proteggere. Git non conserva automaticamente file non tracciati e ignorati; baseline non significa commit automatico.
6. Intervento mirato autorizzato, verifiche e registro. Consegnare `.gd` completi; nessuna patch automatica PowerShell/Python.

## Git: controlli in sola lettura

Da PowerShell nella radice:

```powershell
git --version
git -c safe.directory=D:/ProjectBlob/Game rev-parse --show-toplevel
git -c safe.directory=D:/ProjectBlob/Game branch -vv
git -c safe.directory=D:/ProjectBlob/Game rev-parse HEAD
git -c safe.directory=D:/ProjectBlob/Game status --short --branch
git -c safe.directory=D:/ProjectBlob/Game status --porcelain=v1 -uall
git -c safe.directory=D:/ProjectBlob/Game diff --stat
git -c safe.directory=D:/ProjectBlob/Game diff --cached --stat
git -c safe.directory=D:/ProjectBlob/Game remote -v
git -c safe.directory=D:/ProjectBlob/Game log -8 --date=iso-strict --oneline
git -c safe.directory=D:/ProjectBlob/Game ls-files --others --exclude-standard
git -c safe.directory=D:/ProjectBlob/Game status --short --ignored
git lfs version
```

`-c safe.directory=...` vale solo per il comando e consente letture nella cartella nota con ownership diversa, senza cambiare configurazione globale. Non serve un'eccezione globale per questi controlli.

`origin/...` è l'ultimo riferimento remoto locale: confronto con HEAD non prova lo stato live GitHub. Fetch aggiorna riferimenti e richiede rete; dichiarare se non è stato eseguito.

Una cancellazione Git può essere uno spostamento in cartella non tracciata. Verificare prima di ripristinare. Non usare reset/clean/checkout/restore per eliminare lavoro locale durante la diagnosi.

Staging/commit solo su richiesta: path esatti concordati, verifica `git diff --cached`, controllo dipendenze necessarie. Mai `git add .`/`git add -A`. Push separato e solo su richiesta.

## Asset, backup e riproducibilità

Git conserva solo file tracciati e committati. Ignore comprende ambiente pesante, `.blend`, `.fbx`, `.obj`, import/cache, archivi, export e `export_presets.cfg`. LFS per `.glb`/`.blend` non supera ignore.

Per backup o cambio PC inventariare e conservare anche asset ignorati/non tracciati, sorgenti Blender, texture/audio, licenze, export e file esterni. Concordare destinazione con l'utente; non caricare automaticamente né cambiare ignore senza obiettivo.

Servono gli asset LFS reali e le dipendenze locali dell'edificio. La cache `.godot` non deve essere l'unica fonte dei collegamenti: un clone con HEAD corretto può essere incompleto.

## Godot e Blender

Godot presente: `D:\ProjectBlob\Tools\Godot\Godot_v4.7.2-stable_win64.exe`. Progetto: `D:\ProjectBlob\Game\project.godot`. Nessuna esecuzione del motore nella sessione documentale. Blender e `.blend` attivo non verificati.

Controllare parser/import nell'editor per codice/risorse e provare il comportamento interessato. Per importazione pulita usare copia separata con tutti gli asset necessari; non cancellare cache originale. Headless può verificare parte del codice/import, non resa, input/audio o gameplay.

In Blender verificare scala reale ed export esistenti, posizione, separazione mesh, poligoni/materiali/texture/licenze. Non inventare fattori di scala. Preservare geometria visiva; collisioni semplici dove sufficienti. Per ottimizzazioni misurare byte delle risorse, non solo numero shape.

## Prove manuali pertinenti

Eseguire quelle relative alla modifica; ampliare solo per regressioni/dipendenze. Registrare versioni, ambiente, esito e conferma. La tabella è una procedura, non test già eseguiti.

| Sistema | Scenari |
|---|---|
| Avvio/menu | Loghi → menu → gioco, opzioni/ritorno, transizioni senza overlay residuo |
| Player | WASD/sprint/salto/crouch, ostacolo sopra testa, danno/morte/N |
| Porte | Prompt/outline, E, apertura/chiusura/audio, perdita focus |
| Pickup | Armi/torcia/munizioni, batterie accettate/rifiutate, doppia raccolta/riferimenti invalidi |
| Armi | Slot, pistola/raffica SMG, ricarica/vuoto, melee, animazioni, viewmodel vicino ai muri |
| Impatti | Esclusione player, headshot, feedback, concrete/wood/metal/glass/asphalt/drywall/generic e fallback |
| Torcia | Toggle, consumo/esaurimento/ricarica/capienza e HUD |
| Volto | Idle/4 livelli, danno sopra pickup, raffica senza restart, ritorno idle |
| Pausa/opzioni | Pausa/ripresa, audio persistente, sensibilità/FOV nella stessa partita e riavvio |
| Scala | Ingresso basso/alto, salita/discesa, uscite solide, ripristino input/collisioni |
| Intro Bruno | Blocchi player/HUD, prompt/outline nascosti, TV/dialoghi/ducking, camere/luci, avvio boss |
| Boss | Navigazione/anti-incastro, racchetta/scudo/tennis/onda, danni/headshot, 3 fasi/HUD, morte/ambiente |
| Ambiente | Passaggi/scale/muri/pavimenti, suoni superfici, nebbia interna/esterna e torcia |
| Risorse | Import con dipendenze, niente path mancanti nei componenti usati, mesh/materiali/animazioni |
| Inventario e PC | F6 inventory_save_test, I/E/Esc, card sopra HUD senza coprire volto/valori, soppressione in cinematica/morte; clic monitor, ritorno camera e salvataggio manuale; provare nella mappa dopo collegamento SAFE |

La revisione usa scripts/tests/connesios_render_test.gd per immagini/input D3D12 a 1280×720/1600×900, senza scrivere settings.cfg. Slot automatici in `.godot`; manuale F6 in **user://inventory_save_test.cfg**, separato da **user://savegame.cfg**. Provare PC/Salva/Esc → F8/C, F8/N, pausa/Carica e riapertura F6/Carica: C ripristina, N azzera il runtime senza cancellare il file. Senza file C non compare e Carica è disabilitato. [Nota e limiti](INVENTORY_SAVES_CONNESIOS.md). Utente conferma scena base e grafica ConnesiOS, non salvataggio.

Provare caricamento fallito o animazione assente in copia/scena separata; non danneggiare gli asset della mappa. Il fallimento deve lasciare UI/input/flag recuperabili.

## Chiudere e consegnare

Standard Inspector17/10: verificare per ogni nuovo componente parametri/riferimenti configurabili, gruppi e descrizioni `##`, valori iniziali sicuri, ID stabili e guida al nodo da selezionare. `door_inspector_configuration_test.gd` prova PackedScene→disco→istanza con valori non predefiniti, schema dei campi/gruppi esportati, avvisi duplicati, autoclose con passaggio occupato e fingerprint configurabile indipendente dall'ordine. `warehouse_doors_test.gd` controlla anche12configurazioni nella scena, ID e versi storici. Check editor locale `.godot/editor_configuration_check.gd` usa fixture generata dal primo test con `--headless --editor --script`: conferma che l'editing non costruisce fisica o sposta mesh. Warning editor_settings fuori sandbox e teardown EditorNode annotati, non equivalgono a fallimento degli assert.

Aggiornamento ingresso/lampadari17/10: fixture warehouse_lights_test verifica12luci su6switch; warehouse_emission_map_test verifica18materiali con ingresso indipendente e due lampadari, incluso override della maschera emissiva. PNG in assets/textures/warehouse/chandelier_emission.png deve essere presente/importata. RenderGPU in.godot/chandelier_render_check.gd usa fixture vera estratta dall'addon (helper inspect_chandelier_runtime.gd), produce chandelier_off/on.png per controllo della lampadina; è un artefatto locale, non un test riproducibile senza rigenerare la fixture.

Emissione lampade/verso038: `--script res://scripts/tests/warehouse_emission_map_test.gd` carica la mappa reale e verifica14materiali emissivi locali (12corridoio:6centri+6corpi laterali,2specchi). Verifica ricorsiva dei gruppi interi, originali/texture/colori/intensità invariati, circuiti indipendenti, blackout e restore. Controlla anche038−90°/+X, telai fermi e passaggio reale nei due sensi. La fixture `warehouse_lights_test.gd` esclude i riferimenti ai modelli per mantenere il test leggero; i materiali sono coperti dalla suite mappa. Nessuno slot utente scritto. Verifica estetica finale sempre in gioco.

Porte zona magazzino/bagni: `--script res://scripts/tests/warehouse_doors_test.gd` carica la mappa reale (eseguire da sola rispetto ad altre suite mappa). Aggiornata17/10 verifica12battenti inclusi013/014/015 e038 sopra le scale, quota da pivot, ray/outline e E reale, tre serrature, capsula nel vano chiuso/aperto nelle due direzioni, restore silenzioso e fingerprint10s. `warehouse_door_height_test.gd` verifica che il piano sotto non inneschi arretramento e quello corretto conservi la protezione. `warehouse_lights_test.gd` verifica gli attuali11punti luce su5circuiti, anche annidati nei gruppi. Non scrivono checkpoint utente. Playtest dopo riavvio map_test: F4, otto porte libere apribili, tre con prompt chiave, CED rosso senza credenziale. Chiavi/impronta non sono ancora pickup in mappa. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

- Riassumere cambiamento, motivo, prove e limiti; distinguere statico/runtime/storico.
- Aggiornare registro, stato, backlog e architettura dove necessario; baseline storica inalterata.
- Indicare file e prossimo passo. Non dichiarare completamento quando mancano i test necessari.
- Per documentazione: completezza fonte, link e diff; non occorre playtest.
- Commit/push separati dal completamento tecnico e subordinati alla richiesta utente.
# **Broccolo, regia di ritorno17/10:** test mappa `broccolo_encounter_test.gd -- --map --cinematic-only`: failures0; primo dolly ruota prima della svolta; secondo dolly segue waypoint liberi verso la prima svolta per4,8m (endpoint0,39m dal target); player segue senza perdere la camera. Verificati salto avanzato e volume camera finale. Headless non valuta la fluidità visiva né l'orientamento percepito: richiede playtest.
**Illuminazione Broccolo (19/10):** verificare staticamente snapshot/applicazione/ripristino e lasciare all'utente il controllo visivo in gioco.
**Rifinitura scena Broccolo (19/10):** offset cinematic aggiornato tramite valore Inspector esportato; playtest visivo con props e texture completati richiesto all'utente.
