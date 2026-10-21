# Project Blob — decisioni e attività aperte

**21/10 — Allineamento pistola e zoom mira:** spostare a sinistra le pose aim pistola; introdurre un lieve zoom per ogni arma che usa la mira mantenuta. Implementato offset8cm solo sulle copie runtime di AimIdle/Walk/Fire/Pose; FOV ridotto7° con transizione liscia0,18s su pistola/SMG/shotgun. F6 all'utente per giudicare allineamento visivo e livello di zoom.

**21/10 — Shotgun: traslazione di mira e suoni:** dopo due playtest, l'utente chiede ulteriore spostamento a destra e in alto; offset ora16cm destra e4cm alto camera-space, compensato per scala rig3×, senza rotazioni nuove. Audio confermato buono; verificare con F6.

**21/10 — Mira e capienza shotgun:** l'utente chiede mano destra più a destra con presa sinistra ferma, in tutte le clip di mira, e cinque cartucce prima della ricarica. Rotazione di mira predefinita6°attorno alla mano sinistra, IK destro con transizioni progressive; capienza5 e ricarica per-cartuccia via ReloadStep. Da confermare nel poligono.

**21/10 — Shotgun: superata prova a_arms:** utente richiede tutte le FBX, rotazione in blocco verso sinistra e correzione twist polsi; screenshot chiarisce sinistro avvitato con mano già quasi corretta. Piano approvato con Implement the plan. Copie dedicate19clip, yaw misurato9,35°, torsione ridistribuita senza perdere le prese; nessuna rotazione braccia/WeaponHolder/modello/socket o modifica pistola/SMG. Profilo Inspector e preview separata; test/render passati, conferma estetica in poligono aperta.

**20/10 — Shotgun autorizzato:** utente aggiunge modello/player e scene pickup arma/cartucce, richiede tutta la meccanica, forte danno ravvicinato e ampia rosata, singolo colpo, FX adatto dal pacchetto in player; HUD proiettili espressamente dopo. Riafferma Inspector per tutto il tuning. Implementata prima taratura1caricato/12riserva,10×12danno,cono14°,pieno6m→zero18m,ricarica manualeR,slot6,miraDX. Parametri esposti; asset/transform dell'utente preservati. Test tecnici e GPU passati; bilanciamento/impugnatura/audio provvisorio da playtest, nuova HUD rimane backlog. [Guida](SHOTGUN_GAMEPLAY.md).

**20/10 — Raccordi pistola approvati:** eliminare lo scatto fra presa normale a una mano e mira a due mani in entrambe le direzioni. Piano autorizzato con “Implement the plan”: gesto personalizzato0,55s per direzione, ripartenza dalla posa corrente nelle inversioni, mano sinistra accompagnata e trasformazioni conservate. Implementato con clip runtime locali e tuning Inspector; fixture tecnica passata. Valutazione naturalezza/impugnatura nel poligono resta all'utente.

**20/10 — Pistola e ritmo movimento autorizzati:** applicare le clip FBX Pistol e tutta la mira mantenuta già introdotta per SMG, preservando la nuova posizione braccia salvata dall'utente. Richiesto forte rallentamento camminata e corsa: prima taratura dimezzata a2,5/4m/s e crouch1,4m/s per conservare i rapporti; valori Inspector. L'utente assume esplicitamente il playtest del poligono per velocizzare: controllo tecnico di caricamento soltanto, nessuna prova gameplay automatica o mappa caricata. [Guida](PISTOL_GAMEPLAY.md).

**20/10 — SMG, sviluppo autorizzato:** usare le clip FBX per tutte le azioni SMG applicabili e introdurre mira con destro tenuto, con sparo anche in mira. Utente corregge la rotazione e chiede esplicitamente prova nel poligono: nuova versione riletta, trasformazioni conservate, dotazione SMG applicata soltanto al poligono. Nuovo profilo Inspector con17assegnazioni (15azioni/cicli e2pose di riferimento), blocchi/restore testati, altri sistemi armi conservati. [Guida e limiti](SMG_GAMEPLAY.md). Playtest visivo del poligono come prossimo passo, senza caricare la mappa.

**20/10 — conversione completa autorizzata e conclusa:** l'utente approva la nuova prova FBX e chiede tutte le animazioni nel player. Convertiti70FBX col profilo provato, aggiunti alla libreria `fbx_arms` e mantenute librerie esistenti. Alias `mie/SMG_01_fire` corretto alla clip convertita. Nessuna riassegnazione automatica di sparo/ricarica/movimento nei controller. Test gerarchia reale e hash sorgenti passati; valutazione visiva delle singole clip/impugnature aperta. [Guida](FPS_ARMS_RETARGET.md).

**20/10 — braccia FPS:** l'utente richiede trasferimento completo di una clip di `assets/models/player/Animations`, escludendo esplicitamente `SMG_01_fire.res` e pose base prese dalle nostre animazioni. Nuova prova da `FP_Arms_SMG_01_Fire.fbx` letto direttamente con FBXDocument; profilo 43 ossa e clip LowWorld autonoma 0,50 s. Verifiche tecniche/GPU passate; valutazione della mesh e impugnatura con arma reale ancora aperte. Vecchia prova relativa superata. Le altre 69 clip non sono state convertite. [Guida](FPS_ARMS_RETARGET.md).

**19/10 — feedback sonoro e switch Broccolo:** usare `aura_charge` per shrink e breve duplicazione, `pop1/2` alternati, `lanciosfera1/2/3` abbinati alle tre animazioni, `flame_impact` solo se il player perde salute, `rimpicciolisco_mostro` in avvio trasformazione e `Broccolo_soundtrack` nella boss fight. L'interruttore lampadario pulsa viola per prossimità. Restano da ascoltare mix e volume in Godot; non modificare gli altri boss.

**19/10 — correzioni Broccolo:** seconda posa spostata verso destra (offset Inspector, controllo collisioni); in modalità mappa il presenter emette combat-ready senza ridurre la mesh, così il controller del boss applica una sola trasformazione con VFX. L'utente prova la cinematic completa e il combattimento; non lanciare test Godot in questa rifinitura.

**19/10 — regia iniziale Broccolo, playtest utente aperto:** il marker `BroccoloCameraStop` guida la tratta rettilinea e l'arresto; la camera mira progressivamente a Broccolo. Cue audio unico: l'animazione di risposta parte a10s, il dolly segue il playback e raggiunge il marker sul cue13,5s. Fixture e mappa passate (`failures=0`); serve valutazione visiva in gioco. Cinematiche successive e sistemi di altri boss intatti. [Dettagli](BROCCOLO_MAP_INTRO.md#regia-iniziale-sincronizzata-al-cue-utente-19-ottobre).

**Seguito19/10:** `mie/idle` resta in loop durante il dolly, poi la risposta lo interrompe al cue anticipato. L'utente prova la sequenza completa e il combattimento; in questo passaggio non sono stati eseguiti test Godot.

**18/10 — sfera e incendio da valutare:** nuova richiesta esplicita dopo gradimento di aura/lampo. Prototipo laboratorio usa stesso VFX sul proiettile, impatto diretto incendia3s con danno periodico3/0,75s, senza stacking; AoE conserva danno senza incendio e muri proteggono. Scelto componente separato dal player storico per non alterare fuochi ambientali o save. Tuning/durata e resa FPS da confermare; pacchetto effetti da trasferire identico in mappa solo dopo approvazione. Audio energia/esplosione dedicati ancora mancanti.

**18/10 — VFX da approvare nel test:** utente conferma combattimento mappa funzionante e chiede copia/particelle che partano dal corpo, arancione piu visibile e aura power-up dorata alla riduzione. Implementati nel laboratorio con risorsa PowerVFX condivisa, nascita fisica0,5s prima della corsa e rim configurabile. Esplicito: evitare caricamenti mappa, trasferire IDENTICI solo dopo approvazione. Riferimento profilo null in mappa conserva versione precedente; futura integrazione deve usare lo stesso PackedScene e collegarne l'attivazione alla riduzione finale. [Guida](BROCCOLO_COMBAT_LAB.md).

**18/10 — obiettivo esplicito successivo:** ottimizzare freeze di generazione e integrare il combattimento approvato nella mappa; autorizzata apertura con salto delle sole porte013/014/015. Superato il precedente vincolo della sola scena laboratorio. Pool, cache bocca e preparazione GPU anticipano i caricamenti; handoff esistente usa il nuovo componente senza ritoccare cinematiche approvate. Navigazione locale multiquota, parametri serializzati e vittoria persistente. Restano tuning utente di inseguimento in magazzino/scale, mix e VFX; indizio/drop non richiesto in questo intervento. [Guida](BROCCOLO_COMBAT_LAB.md).

**17/10 — nuove richieste prevalenti:** scala0,20, tre ruoli di copie con velocità e percorsi distinti, lanciatore solo throw con sfere prototipo, balletto ed esclamazioni; implementati nel laboratorio. Principale inizialmente a distanza e poco aggressivo, crescendo con la perdita di HP; solo danni a lui aggiornano barra. Hit sincronizzato senza blend ritardato, reazione specifica da corsa/fermo. **Cambio esplicito utente:** le copie NON sono vulnerabili durante l'animazione hit;2colpi validi distanziati. Il precedente requisito sempre vulnerabili è superato per questa finestra. Anti-incastro salta poi cambia rotta. Riutilizzati passi/salti player e impatti boss; da procurare eventualmente carica/lancio energetico ed esplosione dedicati, mix da ascoltare. [Parametri e prove](BROCCOLO_COMBAT_LAB.md). Nessuna integrazione mappa/cinematic.

**17/10 — running e FPS nel laboratorio:** sei nuove clip collegate dall'utente ora usate per locomozione e saluto/scenetta; corsa provvisoria superata. Inversione animata180° compensata solo su copia privata runtime. Approvato come obiettivo giocare e combattere subito: avvio FPS/lotta automatico, Tab studio, nessun blocco per una fase di sola preview. Copie con emissioni casuali distinte, bordo arancione tenue e scala leggermente maggiore0,17. Test tecnici passati, playtest utente di animazioni/movimento/effetti aperto. Mappa e cinematic fuori scope; sfere energetiche esplosive restano future.

## 17/10 — boss Broccolo: prototipo da valutare

Scena isolata [BROCCOLO_COMBAT_LAB](BROCCOLO_COMBAT_LAB.md), senza modifiche mappa/cinematic. Specificato dall'utente: principale vulnerabile soltanto durante scenette, mai durante attacchi o recupero dal colpo; alone blu protettivo. Copie sempre vulnerabili, due colpi, morte completa e sparizione VFX, emissione dal corpo con limite/cooldown. Implementati per la prova; animazioni, ritmo, resa effetti e wall sneak richiedono playtest utente. Non trovata corsa dedicata: walking accelerata provvisoria dichiarata, Run Clip configurabile. FlyingKick più JumpSlam sperimentale da approvare visivamente. **Richiesta successiva:** attacchi throw con sfere energetiche esplosive; preview gesti già disponibile, proiettili/esplosioni restano fase futura. Vittoria/drop/persistenza e navigazione magazzino non implementati qui.

## Ripresa 17/10/2026 — Broccolo

**Confermato dall'utente:** prima cinematic ora uniforme e fluida, movimento e rotazione coordinati e posa finale corretta. Congelare entrambe le cinematic; non riaprirle durante il prossimo lavoro.

**Prossimo obiettivo:** costruire/provare una scena boss isolata prima dell'integrazione in mappa. Il corpo principale di Broccolo si rimpicciolisce, subisce danno ed è riconoscibile da un'aura blu. Evoca2–3 copie melee per volta, con poca vita (circa due colpi), inseguimento, uso dell'ambiente, salti e sneak lungo i muri. Provare le animazioni disponibili di corsa, attacchi/salti, hit da fermo/in movimento e morte; aggiungere/valutare VFX di spawn, colpo e scomparsa; limitare i cloni vivi e rigenerarli dopo cooldown. Prima obiettivo: comportamenti e animazioni in una scena test, poi integrazione nel corridoio. La battaglia dovrà fornire un indizio al successivo enigma; vittoria, drop e collegamento enigma non sono ancora definiti.

**17/10 — camera Broccolo e arretramento player:** richiesta utente: anticipare la prima ripresa oltre l'angolo e allontanare progressivamente la camera durante la danza; al termine il player deve restare nel punto della camera. Applicato dolly2,8m; il retreat sceglie una diagonale sicura fino al massimo Inspector1m (0,63m nella mappa di test), limitato da sweep camera e collisione CharacterBody, con riallineamento FPS. Test fixture/mappa passati; il playtest deve confermare composizione e spazio. Shrink→spawner resta la catena esistente; prossima fase è la resa/AI boss.

**17/10 — danza Broccolo nella corsia stretta:** scelta utente: fermo durante le clip troppo lunghe e avanzamento solo nel salto. Applicato alla clip finale `mie/dancing`, massimo0,35m; niente root motion delle altre danze. Fixture e mappa passate, posa campionata senza collisioni. Prossimo: playtest utente per confermare direzione/distanza prima di riprendere la boss fight.

**18/10 — correzione facing seconda cinematic:** l'utente ha riportato che Broccolo mostrava ancora la schiena. Il controllo precedente verificava l'asse standard del nodo, non il fronte del modello importato. Applicata compensazione +Z/180° e spostato il facing dopo il reset del sequencer; test fixture e mappa passati fino al dialogo. Prossimo passo: playtest utente della postura; non iniziare la boss fight finché la cinematica non è confermata.

**18/10 — Broccolo, prossimo segmento implementato:** il marker esistente è il punto finale; attore parte sul lato magazzino e cammina verso il marker. Cinematica più breve, parlato avviato vicino all’inquadratura; telefono con urti/rimbalzi reali e cleanup ad assestamento. Avvicinamento entro2,4m avvia discorso/danza; fine shrink aggancia ondate continue fino a3 minion melee simultanei. Regole ancora da definire: condizione di vittoria, numero/ritmo complessivo e ricompensa indizio; per ora combattimento a ondate ripetute. Verificare player playtest e collocazione minion reali. [Dettagli](BROCCOLO_MAP_INTRO.md).

**18/10 — Broccolo, revisione camera/lancio:** su riscontro utente la camera ora segue prima l'asse d'ingresso del corridoio e solo dopo curva a sinistra verso Broccolo; il prop del lancio dura1,4s. Fixture e test mappa headless passati dopo l'intervento; resta la verifica visiva dell'utente, soprattutto distanza dalle scatole e leggibilità del telefono in volo.

**18/10 — priorità prima del combattimento:** corretti il verso del lancio (vettore della mano), la seconda inquadratura (punto FPS conservato, mira diretta) e l’orientamento/percorso di Broccolo (guarda il player, discorso/danza senza traslazione globale nella corsia). `broccolo_encounter_test.gd -- --cinematic-only` passa in fixture e mappa reale. Prossimo passo: playtest utente delle due cinematic; restano separati e non affrontati crash Array[Node] e progettazione/prova della boss fight. [Guida](BROCCOLO_MAP_INTRO.md).

**17/10 — nuova richiesta Broccolo, pronta per playtest:** far sparire la copia del telefono dopo atterraggio e assestamento (attesa configurata0,8s); al via della cinematic accendere le Luci Corridoio; percorso camera lento4s, orientamento indipendente dallo yaw player e collision sweep per muri/arredi. Implementato localmente; da provare in mappa con player rivolto in direzioni diverse. Nessuna estensione a dialogo/combat.

**Correzione successiva telefono17/10:** richiesta aggiornata dall'utente: telefono originale nascosto al lancio, copia diversa visibile per un volo approssimativo verso l'avanti e poi rimossa; niente simulazione d'atterraggio. La nota precedente sulla sparizione dopo l'assestamento e' superata. Test fixture e mappa completa passati; resta la conferma visiva in gioco.

**17/10 — Broccolo confermato dall'utente e rifinito:** primo ingresso/cinema funzionante. Utente corregge il comando di avvio sul lampadario, chiede un secondo in piu' prima della pausa voce e il lancio fisico dello Smartphone gia' agganciato/posizionato nella scena. Aggancio e scala utente intatti; visibilita e rilascio gestiti da PhonePresentation. Ritorno mobilita invariato. Rimane da valutare la revisione in gioco prima di scegliere il passaggio al secondo dialogo/battaglia. Il precedente comando corridoio descritto sotto e' superato. [Guida](BROCCOLO_MAP_INTRO.md).

**17/10 — obiettivo attuale Broccolo:** prima cinematica nel corridoio magazzino all'accensione del corridoio dopo ingresso/porta aliena. Marker BroccoloSpawn fornito dall'utente, telefonata davanti013/014/015, lancio/camminata/idle. Utente sceglie esplicitamente ritorno della mobilita alla fine per ispezionare la posizione; Return Control After Intro=true. Mappa headless verificata senza contatti, fine davanti015; resta playtest audiovisivo. Dopo questa prova decidere insieme avvicinamento o continuazione automatica al secondo discorso, poi danza/riduzione e boss/minion. Enigma CED e loot indizio non attivati da questa fase. [Guida](BROCCOLO_MAP_INTRO.md).

**17/10 — estensione Inspector a tutti gli script di gameplay:** richiesta esplicita dell'utente, priorita player/armi/salute/energia/dotazione. Implementati i parametri mancanti del player e spawn, organizzati armi/pickup/item/interazione/pericoli, defaults conservati; checkpoint non rigenera oggetti. Guida elenca anche gli export preesistenti e i limiti: runtime combat Angelastri e alcuni factory storici non hanno ancora un pannello serializzato permanente per ogni parametro. Proseguire con lo stesso standard sui sottosistemi toccati, preservando bilanciamento e ID. Non equivale a esporre tutte le variabili interne. [Guida](INSPECTOR_CONFIGURATION.md).

**17/10 — modus operandi approvato dall'utente:** nuovi componenti con configurazione da Inspector, gruppi, descrizioni, riferimenti tipizzati e validazione; ID stabili e strumenti editor innocui. Applicare ai prossimi sviluppi e ai componenti toccati, senza riscritture storiche fuori obiettivo. Migrazione attuale12porte WarehouseDoors e documentazione interruttori completate/testate. [Guida](INSPECTOR_CONFIGURATION.md), regola anche in AGENTS e standard tecnici.

**17/10 — nuova luce ingresso e lampadine lampadari:** implementati circuito ingresso indipendente/persistente, emissione completa006 e lampadine dei due lampadari sincronizzate. Ripristinata maschera emissiva GLB in nuova PNG locale senza sostituire asset importati. Test e renderGPU passati; prossimo playtest di questi due circuiti dopo riavvio. Enigma/chiavi/boss restano successivi. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — lati lampade:** riscontro utente centro spento/lati accesi; esteso controllo ai corpi emissivi dei sei gruppi Luce Tonda. Ora12superfici corridoio +2bagni, senza cambiare aspetto originale acceso o altre parti della mappa. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — playtest e rifiniture:** utente conferma zona funzionante; richiede038 verso giocatore per non urtare scaffali e spegnimento emissione superfici lampade. Verso038 invertito in+X,6light_003_03_light_0 e2specchi bagno sincronizzati ai rispettivi circuiti con materiali locali. Questo supera l'indicazione precedente038 verso pianerottolo. Resta gradimento visivo della rifinitura; chiavi/enigma/boss futuri invariati. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — richiesta magazzino completata tecnicamente:** luci aggiunte ai gruppi funzionano senza nuovi collegamenti (11totali); collegate libere Porta_013/014/015 verso interno e038 verso pianerottolo lontano dai gradini.12porte complessive testate con capsula reale. Prossimo gradimento/manuale dei versi dopo riavvio scena, poi posizioni chiavi ed enigma impronta secondo decisioni precedenti. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**15/10 — porte nuova zona implementate:** otto battenti secondo elenco, tre chiavi distinte senza consumo, CED con autorizzazione fingerprint10s/LED. Luci e F4 confermati dall'utente; la precedente assenza di prompt dipendeva dal lavoro porte non ancora eseguito, non da F4. Prossimo playtest versi/apertura/E, poi collocazione chiavi ed enigma impronta; boss e drop ancora futuri. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**15/10 — prova nuova zona senza boss:** F4 debug apre l'uscita aliena e sospende Angelastri per la sessione; salvataggi bloccati per proteggere il checkpoint. Test runtime passato. Luci confermate dall'utente. Elenco otto porte ricevuto, tre chiavi diverse confermate, collocazione chiavi e acquisizione impronta ancora da definire; implementazione porte successiva alla scorciatoia richiesta. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**Nuova zona15/10, una cosa alla volta:** prima luci(5interruttori/7luci collegate e testate in fixture reale), poi porte con passaggio player/collider; CED deve restare chiuso con fingerprint per enigma futuro, poi nuovo boss corridoio davanti magazzino che droppa indizio. Nessuna regola di sblocco o drop inventata. [Guida](WAREHOUSE_ZONE_2026-10-15.md). Prova F6 delle luci prima di nuovi interventi.

**Chiusura Broccolo13/10:** presentazioni approvate dall'utente («perfetto salva tutto»). Preservare configurazione e tempi attuali; riscontro richiesto dalle voci storiche sotto superato da questa approvazione. Restano integrazione mappa e combattimento minion, nessuna nuova attività avviata alla chiusura.

**Broccolo presentazioni13/10:** utente sceglie telefonata22s→throw con pausa audio→walking→idle; discorso con talking reimportate, musica sottofondo, danza3/2/1 da21s e miniatura. Implementate nelle preview F6 separate, aggiunte5clip senza sostituire le23precedenti. Prossimo riscontro audiovisivo; battaglia effettiva e mappa ancora da implementare. [Guida](BROCCOLO_MOUTH_AND_PREVIEW.md).

**Broccolo13/10:** prima fase bocca/denti e studio23clip implementata, intro_broccolo→danza→miniatura20cm. [Guida e fasi future](BROCCOLO_MOUTH_AND_PREVIEW.md). Attendere riscontro F6 prima della coreografia definitiva e dell'integrazione; richiesti in seguito minion melee piccoli2–3 con spawn continuo, salto/furtività e hurt/death contestuali. Nessuna AI nuova ora.

**Broccolo animazioni — 12/10:** utente segnala corpo riportato all'origine applicando clip al GLB. Scala root verificata e [copie compatibili preparate](BROCCOLO_ANIMATIONS.md), con opzione sul posto o movimento originale; nessuna modifica al sorgente o nuova AI. Prova manuale delle risorse corrette aperta.

**Broccolo revisione — 12/10:** utente approva sangue e richiede loghi più leggibili/piccoli, PARKSIDE spostato dal casco al gilet opposto a Connesi, nuova NORMAL dalla diffuse modificata. [File e collegamenti](BROCCOLO_TEXTURE.md) pronti; sangue preservato, normal originale non riutilizzata. Conferma estetica revisione aperta; sola lavorazione asset, nessuna nuova AI.

**Broccolo — 12/10:** utente autorizza sola modifica texture del nuovo modello, mentre innesta la testa in Blender. [Variante pronta e verificata](BROCCOLO_TEXTURE.md); collegamento al corpo e gradimento utente aperti. Non attivare autonomamente sviluppo AI, animazioni o integrazione mappa.

**12/10, audio sportelli contatore:** richiesta avvio immediato apertura/chiusura, stesso effetto. Implementata opzione per istanza nel controller porte, attiva solo sui due sportelli; comportamento storico delle altre porte preservato. [Verifiche](REGIA_AUDIO.md); conferma sonora utente aperta.

**12/10, faro Angelastri:** dopo conferma KONA V2 e prova completa Godot riuscita, utente richiede che l'occhio di bue segua Angelastri come Bruno durante fight. Acquisizione combat e rilascio/restauro del faro nell'encounter, nessuna variazione AI/luci. [Dettagli](ANGELASTRI_COMBAT.md); conferma utente della correzione aperta.

**KONA V2 — 12/10/2026, completata e TESTATO UTENTE:** pallini vicino alle ruote e forme originali conservate, V1 superata. [Correzione e verifiche pixel](KONA_CONNESI_LIVERY.md). Utente conferma export/import, resa e prova integrale del gioco; nuova segnalazione distinta faro Angelastri sopra.

**Archiviazione asset — 12/10/2026:** autorizzata pulizia con eccezione tassativa per `assets/models/enemies/`. Archiviati6.047file non raggiunti dal grafo conservativo, preservati licenze, test e percorsi dinamici. [Esiti/ripristino](ASSET_ARCHIVE_2026-10-12.md). Mappa e inventory/save passati, nessuna nuova dipendenza mancante; playtest e import pulito restano verifiche distinte. Nessuna eliminazione definitiva o commit/push.

**Texture14 verificate nel gioco — 12/10/2026:** nuovo export/import dell'utente contiene texture ridotte; benchmark conferma231MiBmeno nelle risorse texture e fluidità stabile nelle rotazioni. [Misure e limiti](CONNESI14_TEXTURE_BENCHMARK.md). Nessun guadagno caricamento dimostrato; prossimo intervento basato su profilo risorse/ready/prewarm, senza ulteriori riduzioni indiscriminate.

**Texture14 applicate — 12/10/2026 sera:** utente autorizza l'aggiornamento del proprio connesi14 e conferma salvato/chiuso. Applicate 26 riduzioni con backup, digest geometria e verifica di tutte le 536 immagini. [Consegna](CONNESI14_TEXTURES_APPLIED.md). Beneficio atteso soprattutto memoria/caricamento; nessun guadagno FPS non misurato. Nuovo export/import necessario; conservare il backup delle 16:55.

**Reimport14 — 12/10/2026 pomeriggio:** resa texturecandidate approvata dall'utente; benchmark mappa aggiornata completato dopo attesa import. Scorrevoli/Bruno passati, due pathcolliderrack riparati per parentrinominato. [Risultati](CONNESI14_REIMPORT_BENCHMARK.md). Il GLBattivo include ancora texturePNGcontrollate a4K/8K; nuova applicazione deve usare sorgente14delle16:30, conservando ulteriori cambiamenti utente. Nessuna nuova ottimizzazione ombre o gameplay applicata.

**Connesi14 — 12/10/2026:** utente richiede verifica e aiuto texture, conferma definitivo il salvataggio. Verifica mesh e prima copia isolata con26 texture ottimizzate completate; originali conservati. [Consegna](CONNESI14_TEXTURE_OPTIMIZATION.md). Prossimo controllo visivo ravvicinato della copia, poi esportazione/import e misura reale; non dichiarare migliorata la mappa che usa ancora il GLB precedente.

**Priorità performance — 11/10/2026:** prima di proseguire il gameplay, diagnosi caricamenti/scatti e ottimizzazione misurata. Utente indica `D:/ProjectBlob/Assets_Source/connesi13.blend` e richiede analisi/suggerimenti senza modificarlo; autorizza ripetizione test. [Audit](PERFORMANCE_AUDIT.md): mesh e texture sproporzionate identificate, nessun intervento sul sorgente. Prossimo intervento su copia, un candidato alla volta, confronto visivo e tempi prima/dopo; preservare nomi/pivot/UV/interazioni e atmosfera.

**Chiusura 11/10:** conferma utente «ok ci siamo» sul risultato finale in game. Archiviare le precedenti richieste di gradimento VFX/sangue come superate; preservare effetti e audio approvati. F7/F11 restano strumenti di prova autorizzati. Aperta immagine definitiva barra Angelastri e prossima scelta gameplay dell'utente; nessun nuovo obiettivo inferito. Commit/push richiesti dall'utente per chiudere la sessione.

**11/10 — combat Angelastri:** autorizzazione esplicita IA/bilanciamento affidati all'assistente; tassativo proiettili innocui/schivate, due melee e morso. Implementati 40 HP, danni 10/16, morso24/cooldown12s, racchetta5/2.5m dall'avvio fight, barra provvisoria in alto. F7 autorizzato per saltare alla passeggiata. Test isolati passati, playtest/bilanciamento mappa aperti. [Dettagli](ANGELASTRI_COMBAT.md).

**Priorità Angelastri evento:** preview mappa approvata. Implementato il ciclo Fritz → tre blackout → terza uscita/performance → FPS/passeggiata → vista reale/secondo discorso → handoff; da confermare nel playtest completo post-Bruno. Prima scena TikTok rivolta a camera immaginaria, non player. Faro esistente temporaneamente assegnato. Parametri iniziali 14–22 s, riarmo 12 s, vista 4 m. Il blackout deve restare udibile anche lontano dal contatore: click presso player, notifica e risata forte. Prossima fase AI zombie/attacchi/melee e racchetta utilizzabile soltanto dopo inizio fight; non anticipare sblocco al balletto. [Guida](ANGELASTRI_ENCOUNTER.md).

**Priorità corrente Angelastri:** dialogo studio approvato; valutare entrambe le sequenze nella mappa mediante F10/F11, con balletto che si sposta nel piazzale davanti ai contatori. F12 pulisce; F9 resta Bruno. Integrazione solo debug, senza dinamica blackout o AI. [Guida](ANGELASTRI_MAP_PREVIEW.md). Prossimo lavoro subordinato al riscontro sulla resa in mappa.

**Vincolo nuovo dialogo:** evitare tagli a metà e scatti/cambi posizione. Completare gesti e sfumare mixer, stabilizzare bacino nel parlato soltanto. Secret 44 s (−3), a fine dialogo idle_new e poi talk_to_combat; dopo questo avverrà avvio combattimento nell'integrazione futura. Preview termina al segnale combat_ready. Priorità sempre valutare dialogo, poi mappa con balletto mobile, infine AI/combattimento.

**Nuovo vincolo dialogo:** usare nuove talking ad hoc; talking_secret esclusivamente quando abbassa voce nel finale, non prima/intro/balletto. Implementata finestra preview 47–54 s regolabile, timing BOZZA; talking spiegazioni a due mani, talking2 gesto contenuto una mano, talking3 narrazione/enfasi. Aperto ascolto F6 e correzione cue del whisper; mappa successiva.

**Priorità utente:** canto approvato; prima provare dialogo principale completo, poi entrambe le sequenze nella mappa. Preview autoplay del discorso preparata in angelastri_dialogue_test.tscn, cue provvisori da affinire. Requisito mappa: Angelastri si muove nello spazio durante danza, continuità root motion/piedi/posizione finale da verificare, non sola camera che segue. Rinviata integrazione fino al riscontro dialogo.

**Riscontro canto:** utente vuole bocca mobile, non apertura sostenuta. Implementata articolazione stilizzata sulla misura RMS del mix, senza riconoscimento sillabe/fonemi; garantisce aperture/chiusure dopo 73.5 s. Test misura escursione/chiusure e lifecycle; nuova resa F6 da ricevere.

**Gesti intro:** utente richiede secondo gesto con pointing2: implementato dopo primo pointing completo, default 15.6 s, senza ripetizione pointing. Canto 73.5 s preservato, nuova prova F6 aperta.

**Conferma e canto:** utente «PERFETTO» sul balletto ritardo 1 s/looking; vuole bocca al canto. Cue esplicito 1:13.5 della musica, implementato singing_start_seconds=73.5. RMS sul mix completo, nessuna separazione vocale; limite dichiarato prima dell'implementazione. Aperto gradimento canto in F6; preservare sequenza approvata.

**Scelta prevalente:** ritardo balletto ridotto a 1 s; idle è animazione combattimento, esclusa dalla preview automatica. Per questa prova attesa con looking, in loop dopo danza e ingresso sfumato 0.6 s; precedente alternanza idle-looking superata. Riscontro F6 aperto.

**Riscontro «bellissima», timing e blend:** corpo e sequenza approvati dall'utente; richiesta ritardo danza/pointing e transizioni idle-looking dolci. Implementati valori preview 2.0 s lead-in, primo pointing 12.0 s, crossfade rest 0.6 s. Continuano autoplay/quattro danze/musica unica/fade. Aperto riscontro sulla precisione di questi tempi e morbidezza, senza avviare fase gameplay successiva.

**Riscontro utente corpo fermo:** riprodotto e corretto blend congelato sotto seek/pausa; verifica aggiunta sul movimento reale delle ossa, non soltanto nome/tempo clip. Richiesto pointing su «questo è un muro»: assegnato al tratto intro 11–18 s, timing ancora provvisorio. Aperto nuova prova audiovisiva F6 e affinamento preciso dei cue.

**Traccia Thriller sostituita dall'utente:** ora 125.41 s, copre tutte quattro danze (111.3 s); loop precedente non utilizzato. Fade ultimo secondo del quarto, poi idle/looking. Confermare effetto completo con nuova musica in F6.

**Estensione utente:** aggiunte Thriller 3/4, richieste consecutive senza interrompere musica. Implementate quattro clip con durate reali, 111.3 s. Per coprire durata maggiore del file (91.05 s) preview usa loop MP3 privato; da valutare raccordo nel playtest. Preservata velocità originale. Fade solo al quarto, poi idle/looking.

**Chiarimento utente fase 1:** osservare automaticamente soltanto intro → danze 1/2 con musica continua e fade → idle/looking; poi proseguire dopo riscontro. Implementato autoplay F6 con UI minima. Intervallo looking preview 10 s, gesto looking completo poi idle. Aperto riscontro audiovisivo e rifinitura cue intro; non avviare automaticamente discorso principale o gameplay.

**Fase 1 Angelastri, nuova richiesta 11/10:** includere già prove discorso/gesti e balletto/musica. Preview implementata e testata tecnicamente; TXT privi di tempi, cue iniziali esplicitamente provvisori. Danze originali 48.6667 s totali, clock musicale comune, fade ultimo secondo. Aperto: ascoltare e affinare cue, valutare ritmo musicale e root motion/transizione in riproduzione continua, confermare tutte le clip; soltanto dopo passare alla fase 2. Cue UI temporanei da annotare prima della chiusura.

**Decisione attiva Angelastri — 11/10/2026:** V2 approvata «ok perfetta». Obiettivo successivo esplicitamente richiesto, in tre fasi: modello/animazioni → cinematiche sincronizzate → combattimento/racchetta. Prima connessione Fritz a PC oppure switch; due blackout con solo quadro aperto, terza uscita con nemico. Riarmo dopo ripristino e rientro nel lab. [Specifica, risorse e istruzioni di ripresa](ANGELASTRI_IMPLEMENTATION_PLAN.md). Nessuna delle nuove fasi implementata; iniziare soltanto dalla fase 1. Le richieste di nuovo obiettivo/conferma Angelastri nelle note storiche sotto sono superate.

**Rifinitura Angelastri:** rialzo superiore V2 +1.2 mm confermato; preservare bocca e denti.

**Angelastri — obiettivo autorizzato:** prima bocca apribile e denti come Bruno, sul GLB ufficiale sgt_Angelastri e scena reale angelastri. Implementata variante localizzata e collegamento runtime, tre shape/arcate continue texturizzate, animazioni preservate. Prova estetica aperta; voce ufficiale/AI/combattimento/cinematica/mappa richiedono successivo obiettivo. Scorrevoli/audio regia precedenti confermati «ok ci siamo».

**Audio regia approvato:** utente «perfetto» sulla revisione precedente. Richiesti sliding_door per scorrevoli e «allo switch» nel menu cavi: implementati su laboratorio/bagno e testo collegamento/scollegamento. Prova della nuova rifinitura ancora aperta.

**Audio regia autorizzato:** collegare e sincronizzare gli otto effetti utente. Implementati bip/sblocco/battente/cavi/mouse/tastiera/sfoglio; originali preservati, estratti per rimuovere silenzi e regolare livelli. Timbro e bilanciamento da confermare manualmente; analisi segnale e test motore distinti dall'ascolto.

**Denti Bruno conclusi — 11/10/2026:** «perfetto» approva V6 con texture e bordo destro corretto. Preservare arcate continue, separazione e materiale; conferma artistica chiusa.

**V6 richiesta e realizzata:** eliminare bianco destro a bocca chiusa e aggiungere texture. Bordo accorciato/arretrato, separazioni leggere dipinte su fasce continue; gradimento finale aperto, test GPU passato.

**Rifinitura V5:** «ci siamo quasi» sulla fascia continua; richiesto coprire il vuoto destro e distanziare leggermente le arcate. Estensione laterale e lieve riduzione altezza implementate senza cambiare apertura/audio. Conferma finale aperta.

**Correzione richiesta denti:** utente respinge V3 (separati/storti), preferisce mesh bianca unica e possibile differenziazione tramite texture successiva. Implementate due fasce continue V4, nessuna suddivisione visiva; UV predisposte, texture rimandata. Gradimento da ricevere.

**11/10/2026 — richiesta denti Bruno:** denti semplici e solo accennati. Implementata variante V3 con sei corone per arcata, avorio opaco e movimento inferiore collegato alla mandibola; V2 preservata. Test grafico passato, conferma estetica in mappa aperta. Nessuna nuova modifica gameplay.

Aggiornamento 08/10/2026. Riferimenti: [baseline](BASELINE_SAFE_2026-10-08.md), [stato locale](CURRENT_STATE.md), [registro](SESSION_LOG.md).

## Decisioni da preservare

**Conferma utente 11/10/2026:** «ok funziona tutto» dopo playtest delle rifiniture Fritz/porta aliena/PC/notifica chiave. Resa e comportamento di questa revisione passano a confermati dall'utente; non attribuire a questa frase la prova specifica del ciclo completo Carica/C/N/riavvio, che resta aperta. Prossima sessione: leggere il punto di ripresa e lavorare al nuovo obiettivo indicato dall'utente.

**11/10/2026 — rifiniture B20 autorizzate:** «tutto perfetto» conferma generale della revisione kit/documenti, senza attribuire prove manuali specifiche C/N/riavvio. Alimentatore Fritz puramente scenico già inserito nella ciabatta, cavo bianco/grigio; nessuna raccolta o dipendenza gameplay aggiunta. PC ridotto del 16%, orientamento/innesti conservati. Uscita aliena: cardine destro dalla faccia della chiusura e apertura interna; arretramento del player vicino soltanto da quel lato, con collisioni reali e apertura negata se percorso occupato. Messaggio della scorrevole generico «Serve una chiave.». Scala uniforme del nodo chiusura segue figli/clic e zoom; modifiche alla geometria importata richiedono verifica dei montaggi. Nuova resa da confermare dopo F8/F6; preservare sblocco permanente e kit riutilizzabile.

**Nuova estensione B20:** utente approva miglioramento generale e cavi, chiede dimensioni del monitor PC e orientamento sedia rossa, rete SX/corrente DX; caricatore prima in inventario poi installato con E sul portatile. Arresto solo dopo soluzione, chiusura/uscita automatica e raccolta congiunta PC/caricatore, ri-deposito rifiutato. Icone ed esame anche key/cavi; descrizioni neutre, nessuna storia del cerchio nel libro. Documenti aperti 3D; nel libro pagine di glifi e solo WiFi dopo sfogliatura, nel notebook appunti realistici con annotazioni. Nuovo ciclo implementato; conferma utente della resa e ciclo manuale salvataggi ancora aperti.

**Revisione B20 dopo playtest:** utente conferma la logica e richiede portatile sulla scrivania sinistra vicino al Fritz, LED nelle sedi originali senza nuove scritte, E sul Fritz collegato per zoom, niente suggerimenti sul manico o sulla posizione del caricatore, desktop nitido, alfabeto distinguibile condiviso anche nei messaggi alieni, cavi con curve e gioco, chiave key_with_tag più visibile. Dodici lettere armene Sylfaen selezionate; codice a indici conservato. La nuova resa resta da confermare.

| Decisione / vincolo | Provenienza |
|---|---|
| FPS aziendale goliardico nella sede Connesi, meteorite/blob e dipendenti mutati | Concept/storia nel PDF |
| Godot + Blender, milestone e interventi SAFE | Contratto PDF e standard |
| Nessun commit/push autonomo; staging su path espliciti | Contratto PDF |
| Non sostituire geometria visiva durante ottimizzazioni fisiche | PDF, sezioni 1 e 11 |
| Impatti condivisi, esclusione player dal raycast, dimensioni approvate preservate | Standard |
| Vetro con crepe, per ora senza rottura | Standard |
| SettingsManager e settings.cfg come fonte unica; slider senza eventi in inizializzazione | Standard |
| Audio per categorie, volume arma distinto dal mix generale | Standard e baseline |
| HUD boss esistente con tre fasi cromatiche e ricarica tra fasi; non ricostruire una HUD nuova | Baseline |
| Volto 4 stati × 20 pose, danno prioritario, raffiche senza restart continuo | Baseline, TESTATO UTENTE storico |
| HUD nascosta durante intro Bruno; niente alert volto nell'intro senza nuova scelta | Baseline |
| Preservare navigation_source, bruno_intro_blocker, superfici e percorsi giocabili | Baseline e locale |
| Nebbia esterna sperimentale approvata; evitare nebbia globale intensa negli interni definitivi | Standard e baseline |

## Prossima attività storica

**Blender: completare la nuova stanza dell'edificio**, con uffici, magazzini, bagno, rack/scaffali, arredi e materiali. Il PDF riporta questa scelta dell'utente; riconfermare l'obiettivo prima di avviarla in una nuova sessione.

Prima di importare: scala reale, mesh separabili, poligoni, texture/materiali e licenze. Non applicare trimesh a ogni arredo. Completamento: geometria/materiali approvati, import senza risorse mancanti, passaggi/collisioni/scala provati nel gioco. `.blend` attivo e scala export non accertati in questa sessione.

## Backlog

Gli ID sono riferimenti documentali, non issue GitHub. L'ordine non autorizza esecuzione autonoma.

| ID | Attività | Stato/evidenza | Completamento richiesto |
|---|---|---|---|
| B01 | Consolidare mappa alleggerita | Locale: 26.608.635 byte, 50 sub_resource concavi, differenze non committate | Confronto baseline; percorsi/collisioni/audio/navigazione testati; eventuale commit su richiesta |
| B02 | Prompt durante intro/morte | Protezione Interface presente nel codice locale; runtime aperto | Prompt/outline nascosti con HUD, ripristino corretto, pickup senza riferimenti invalidi |
| B03 | Onda blob in arena | Materiale lilla/pulsante/gelatinoso implementato e verificato in anteprima D3D12 il 08/10; conferma utente e prova arena aperte | Traiettoria continua, origine/VFX/danno/schivata confermati nell'arena |
| B04 | Nebbia e luce interna | Vincolo storico, nessun nuovo test | Esterno atmosferico, interni leggibili con torcia, conferma utente |
| B05 | Percorsi SilverDelivery | Scene referenziano cartella vecchia assente; nuova non tracciata | Dipendenze risolte senza sola cache, viewmodel/animazioni/pickup provati |
| B06 | Sensibilità da pausa | Player legge una volta; pausa salva ma non aggiorna player | Effetto nella stessa partita, persistente al riavvio, coerente fra menu |
| B07 | Errori SceneTransition | Risolto 10/10: cancel_loading libera overlay e busy nei rami errore | Test risorsa non-scena e successiva transizione passati; loader condiviso con salvataggi |
| B08 | Attese animazioni armi | animation_finished atteso anche se animazione assente | Sparo/ricarica validi; assenza non lascia flag bloccati |
| B09 | GodotLootVFX prima dell'uso | Riferimenti mancanti assets/BinbunVFX... | Scene selezionate importabili; nessuna riscrittura generale dei pacchetti |
| B10 | Asset e copie storiche | Molti non tracciati/ignorati, duplicati | Inventario, licenze e backup; distinzione attivi/test; Git solo su richiesta |
| B11 | Parametri Bruno | Script 180 HP, scena locale 90 | Valore desiderato scelto, override mappa letti, tre fasi/HUD provati |
| B12 | NPC, boss, mutanti e ambienti | Backlog storico | Obiettivo e comportamento concordati prima di implementare |
| B13 | Alert/focus del volto in gameplay | API presenti, eventi futuri | Evento scelto, HUD visibile e priorità preservate |
| B14 | Animazioni/ricariche/menu/controlli | Backlog storico | Problema concreto e prova concordati |
| B15 | Inventario, chiave Bruno e porta scorrevole | Collegati ai nodi reali; test mappa/restore passati, chiave conservata e drop unico | Playtest utente nella mappa, inclusi bagno libero e battente regia |
| B16 | Salvataggio manuale PC ConnesiOS | PC e adattatori mondo collegati nella mappa; clic GPU e restore anche in processo nuovo passati | Conferma utente nella regia: salvataggio, C/N, Carica e riavvio |
| B17 | Grafica inventario, raccolta e ConnesiOS | Versione blob confermata dall'utente: «funziona tutto»; ConnesiOS già approvato | Revisione nella prova confermata; HUD inferiore da rifare separatamente |
| B18 | C/N, caricamento pausa e slot prova | TESTATO UTENTE demo; integrazione mappa completata, test restore separato passato | Playtest C/N e Carica nella mappa; slot demo/principale distinti |
| B20 | Puzzle rete regia e chiusura aliena | Logica confermata dall'utente; revisione visiva portatile/Fritz/desktop/glifi/cavi/chiave implementata | Conferma nuova resa e ciclo manuale salvataggi; conservare chiusura agganciata e sblocco definitivo |

## Osservazioni e nuove decisioni

**10/10/2026 — B20:** piano autorizzato e implementato. Decisioni utente: porta richiede PPPoE valido/Online, switch alimentato/cablato e WiFi aperto; login admin/admin2026 obbligatorio, PPPoE narcisolo/ottavonano; due cavi totali recuperabili; Windows 10 simulato; alimentazione Connesi per router/switch/caricatore, chiusura aliena autonoma; libro lasciato in regia; sblocco definitivo. Correzione esplicita successiva: chiusura **rimane sulla porta** e segue il battente, nessuna dissolvenza/scomparsa, riapertura senza password. Utente conferma versione precedente funzionante e blocco Bruno non ricorrente. [Implementazione e verifiche](REGIA_NETWORK_PUZZLE.md). Nessun commit/push; nuova conferma estetica/gameplay aperta.

**Chiusura 10/10/2026 — caricamento approvato:** «ok ci siamo» sulla versione finale. Preservare animazione blob centrale, cornice scura/viola e avanzamento; nessuna striscia decorativa superiore o laterale nel caricamento. Decorazioni inventario conservate. Collegamento immagini Carica e ordine menu completati e confermati; vecchi obiettivi UI sotto superati. B07 risolto e testato; B16/B18 mantengono aperta solo conferma completa manuale del salvataggio nella mappa. HUD inferiore rimane rinviata; nessuna nuova attività di gameplay autorizzata dalla chiusura documentale.

**10/10/2026 — immagini menu implementate:** richiesta esplicita di collegarle subito e mettere Nuova partita sopra Carica. Aggiunta associazione CARICA SALVATAGGIO normale/blob nel controller condiviso, posizione Continue indice 1 nel menu iniziale. Runtime verifica entrambe le immagini nei due menu e ordine NewGame/Continue passata. Grafica riusa crop/scala/hover/focus/audio esistenti; loading/slot invariati. Conferma estetica aperta.

**Chiusura 10/10/2026:** utente conferma «perfetto ora funziona» dopo la correzione passaggio: TESTATO UTENTE per attraversamento. **Prossimo obiettivo UI:** collegare `assets/ui/caricasalvataggio.png` e `assets/ui/caricasalvataggio_blob.png` ai pulsanti Carica salvataggio dei menu, con comportamento grafico coerente agli altri. Asset utente presenti, collegamento ancora non implementato. Conservare abilitazione da file valido, caricamento e separazione slot; verificare proporzioni, hover/focus e stato disabilitato. Salvataggio/C/N/riavvio nella mappa restano da confermare dall'utente.

**10/10/2026 — correzione B15 attraversamento:** porta aperta ma player bloccato: diametro capsula 0.80 m superiore al vano circa 0.795 m, urto reale sugli stipiti. Raggio locale della mappa 0.35 tramite RegiaIntegration, altezza/controller/visiva conservati. Aggiunto test sweep player, poiché i test precedenti verificavano apertura/restore ma non passaggio fisico. Conferma utente dopo F8/F6 aperta.

**10/10/2026 — B15/B16/B18 integrati nella mappa:** utente identifica Porta Lab/Porta_011 (DX→SX con chiave), Porta Bagno Regia libera, Porta Regia battente e PCRegia/Collada visual scene group_003/Computer_Low. Collegati componenti approvati, raccolta/drop/persistenza, corretto pannello regia/maniglie e override scomparsi. Test mappa/restore/GPU/demo/passaggio Bruno passati; chiusura del lavoro richiede playtest utente mappa, direzione bagno e salvataggio/riavvio reale. [Nota](REGIA_MAP_INTEGRATION.md).

**10/10/2026 — integrazione regia avviata:** dopo conferma passaggio Bruno, utente richiede chiave/scorrevole bloccata/PC e aggiunge scorrevole bagno regia libera e porta regia a battente. Pivot già preparati dall'utente. Identificare nomi/path delle mesh, associazione delle due porte regia e monitor; E per interazione, chiave Bruno conservata e stati persistenti come componenti approvati. Scorrevole libera deve supportare assenza di required_key; attualmente lo script assume chiave o unlocked, da adattare nella prossima modifica mirata. Nessuna patch tecnica in questo sopralluogo.

**10/10/2026 — prossima sessione:** l'utente conferma due obiettivi: completare la bocca Bruno (B19) e integrare nella scena principale PC/salvataggio, inventario, chiave/drop boss e porta scorrevole (B15/B16/B18). Non limitare la ripresa alla bocca. Identificare i nodi reali, collegare i componenti già approvati e provare la persistenza nella mappa; nessuna integrazione realizzata nella chiusura documentale.

### 2026-10-10 — conferma finale scena di prova

L'utente conferma «funziona tutto» dopo l'ultima consegna. Inventario blob e flusso salvataggio/caricamento/C/N nella scena autonoma passano a TESTATO UTENTE. Conferma generale senza elenco delle prove eseguite: non attribuire automaticamente verifiche specifiche del riavvio. Integrazione nella mappa e nuova HUD inferiore restano aperte; nessuna nuova attività di gameplay avviata con questo aggiornamento documentale.

### 2026-10-10 — inventario blob e C/N

ConnesiOS «perfetto»: conservarne la grafica. Inventario industriale respinto, riferimenti boss/menu/pausa; HUD inferiore rinviata. Carica salvataggio nei menu; C continua dal file valido della scena, N ricomincia sempre conservando il file. Slot prova inventory_save_test.cfg indipendente da savegame.cfg. Queste scelte sostituiscono l'estetica industriale e N/checkpoint. Salvataggio ancora non TESTATO UTENTE, prove tecniche completate.

### 2026-10-10 — riscontro prova e rifinitura UI

L'utente conferma che la scena di prova funziona; **non ha provato il salvataggio** e sceglie di provarlo nella mappa. Prima richiede inventario coerente con la HUD, notifica raccolta in un posto apposito e ConnesiOS ispirato a connesi.it. Realizzati dossier metallico/carta, card ancorata sopra la HUD e monitor verde/blu/bianco; nuova estetica ancora da confermare. Questo intervento prepara l'integrazione SAFE successiva, senza inserire autonomamente componenti nella mappa. Dettagli nella [nota inventario](INVENTORY_SAVES_CONNESIOS.md).

### 2026-10-10 — inventario e salvataggio dalla regia

Piano approvato e implementato prima in scena autonoma: raccolta E, inventario I, chiave alla morte finale di Bruno senza consumo allo sblocco, porta scorrevole separata. Salvataggio **solo manuale al PC**, uno slot e nessun autosave; zoom dedicato 0,75 s, monitor ConnesiOS/SubViewport, Salva/Esci/Esc, pausa e ripristino input/HUD. N dopo morte ripristina l'ultimo checkpoint corrente; senza checkpoint si riparte, Continua legge il disco. Nuova partita conserva il vecchio slot fino alla prossima scrittura. Skip intro rinviato. Queste scelte prevalgono su eventuali ipotesi precedenti di autosave.

La mappa resta fuori dall'allestimento iniziale: attendere identificazione PC regia e porta definitivi. Sistema e adattatori documentati in [INVENTORY_SAVES_CONNESIOS.md](INVENTORY_SAVES_CONNESIOS.md). Runtime automatizzato e monitor D3D12 verificati, nessuna conferma utente o prova della mappa definitiva ancora ricevuta.

### 2026-10-08 — maglietta BetterBuozzi

Richiesta utente: scritta “connesi” sulla maglietta. Implementata una variante separata, minuscola blu scuro sulla porzione bianca integra del petto, collegata al materiale della scena boss. Originale preservato; testo verificato in rendering della mesh di riposo. Posizione scelta come default comunicato; conferma estetica e verifica durante animazioni ancora aperte. [Nota e prompt](BETTERBUOZZI_CONNESI_TEXTURE.md). Nessun commit/push.

### 2026-10-08 — materiale onda di Bruno

Scelta utente: onda più chiara e pulsante, movimento da blob **morbido e gelatinoso**, viola schiarito verso il lilla. Implementazione autorizzata con “Implement the plan”.

Prima versione: pulsazione 1,2 Hz / 18%, deformazione radiale massima 0,06 unità locali / velocità 0,8, attenuata alle punte. Core/Shell sincronizzati; alpha 0,85/0,25, luminosità 1,8/0,95, distorsione 0,025/0,035. Shader attivo e materiali aggiornati, logica gameplay conservata. Anteprima corretta per usare start_wave() e disabilitare danno.

Godot 4.7.2: anteprima headless avviata, shader/materiali controllati con GPU, immagini frontali/laterali, dissolvenza e attenuazione verificate in Forward+ D3D12. Non ancora TESTATO UTENTE né provato nel combattimento reale. La rifinitura B03 resta aperta; nessun commit/push. Dettagli nel registro sessioni.

Script molto estesi e copie precedenti aumentano il costo di manutenzione; non autorizzano refactor, eliminazioni o semplificazione arbitraria di Bruno/cinematica/armi/HUD. Identificare il riferimento attivo e il problema concreto.

B05–B09 derivano da analisi statica, non da bug riprodotti in gioco. I test storici di armi/volto rimangono conferme della baseline provata, senza certificare modifiche successive.

### B19 — bocca Bruno, 10/10/2026

**Prova mappa:** utente conferma bocca funzionante e segnala blocco del cammino. A/B riproduce blocco anche senza bocca; individuato collider Parete_013 obsoleto rispetto alla mesh corrente. Corretto solo quel collider nella mappa, test passaggio passato. Conferma utente del ripristino cammino aperta; [nota dedicata](BRUNO_PASSAGE_COLLISION.md). Nessuna riduzione del collider boss o modifica AI.

**Integrazione autorizzata e implementata:** V2 approvata «ok ci siamo». Componente nella scena boss collega tutti i veri player vocali per intro, combattimento, ferite/cadute e morte. Avvio mappa verificato; playtest completo utente della mappa aperto. Sequenza concordata: questa prova, poi integrazione B15/B16/B18 (porta/chiave/PC/salvataggio).

**Revisione successiva richiesta:** parlato più realistico, risata più ampia e altri movimenti della bocca. Implementati nella preview aumento dell'escursione e shape round/smile, risata temporizzata secondo il riferimento intro. Variante precedente conservata; conferma utente della nuova resa aperta. Le forme sono espressive, non fonemi riconosciuti; integrazione nella cinematica reale ancora successiva.

Implementata [prova isolata](BRUNO_MOUTH_PREVIEW.md), apertura discreta pilotata dall'ampiezza della sola voce, nuova testa con morph e cavità. Test audio/runtime/GPU passati; taglio ricalibrato dopo il primo riscontro. Successiva conferma «ok bellino»: TESTATO UTENTE, gradimento generale. **Rifinitura aperta per la prossima sessione:** movimenti più ampi mentre parla; valutare forme come “O” senza promettere labiale fonetico (RMS non identifica vocali). L'utente accetta la versione attuale se le forme aggiuntive non sono fattibili/convincenti. Nessuna implementazione ulteriore in questa chiusura. Integrazione nella cinematica reale successiva, da concordare; nessuna modifica alla mappa.

Per una nuova decisione registrare: data, richiesta/conferma utente, scelta, sistemi/file, prova, eventuale sostituzione della decisione precedente. Separare “implementato”, “testato” e “registrato in Git”; collegare il completamento a una voce del registro.
# **17/10 — Regia Broccolo:** seconda camera/player seguono waypoints sicuri verso il punto di svolta della prima ripresa, invece di arretrare lungo un solo vettore; percorso mappa4,8m, endpoint libero a0,39m dal target. Dolley iniziale ruota progressivamente; idle facing è ritardato all'uscita dal campo visivo. Salto finale avanza fino a1m. Mappa `--cinematic-only` failures0. Prossimo: playtest utente, poi si torna alla boss fight in scena di prova.
**19/10 — Illuminazione Broccolo:** tinta viola ambientale limitata alla boss fight, valori originali ripristinati; forza e colore target configurabili nell'Inspector. Resa da confermare nel playtest.
**19/10 — Esito e rifinitura Broccolo:** tinta viola in combattimento confermata; default Inspector della seconda presentazione aumentato di ulteriori10cm a destra (0,45m). Da verificare insieme alla scena completata.
