# Project Blob — documentazione di continuità

**19/10 — Audio e invito interruttore Broccolo:** carica/voce shrink, aura+pop copie, tre lanci, impatto sfera sul danno reale e soundtrack sono collegati; i silenzi MP3 vengono saltati/interrotti in riproduzione. Il comando lampadario pulsa viola entro portata. Playtest audio/luci all'utente; dettagli in [BROCCOLO_COMBAT_LAB](BROCCOLO_COMBAT_LAB.md) e [BROCCOLO_MAP_INTRO](BROCCOLO_MAP_INTRO.md).

**19/10 — Broccolo, seconda cinematic e handoff:** posa spostata a destra con controllo di spazio; nella mappa la presentazione passa direttamente al combattimento senza shrink preliminare, lasciando una sola trasformazione con aura all'avvio del boss. Playtest cinematica/lotta lasciato all'utente.

**19/10 — regia iniziale Broccolo:** [idle continuo fino al cue della risposta](BROCCOLO_MAP_INTRO.md#idle-durante-il-dolly-19-ottobre), poi risposta con anticipo3,5s e camera al marker sul cue13,5s. L'utente prova la cinematic completa; altri boss esclusi.

**18/10 — sfera con aura e player incendiato:** [nuova prova laboratorio](BROCCOLO_COMBAT_LAB.md#sfera-energetica-e-bruciatura--prova1810), proiettile con scia e impatto diretto che brucia3s; Tab / Prova bruciatura in FPS. Mappa conservata fino ad approvazione del pacchetto.

**18/10 — prova effetti Broccolo:** [F6 laboratorio e pulsante Ripeti trasformazione](BROCCOLO_COMBAT_LAB.md#prova-effetti-1810--prima-approvazione-nel-laboratorio). Nascita fisica dal corpo con particelle, bordo arancione leggibile e aura dorata. Solo test fino ad approvazione, poi stessa risorsa IDENTICA nella mappa.

**18/10 — Broccolo nella mappa reale:** [integrazione, pool e tre porte](BROCCOLO_COMBAT_LAB.md#integrazione-mappa-e-copie-preparate-1810). Combattimento del laboratorio collegato dopo la seconda presentazione, copie preparate e riusate, salto/apertura solo013/014/015. Cinematiche preservate. Prossimo playtest magazzino/scale e fluidita.

**17/10 — Broccolo, ruoli e audio:** [laboratorio F6 aggiornato](BROCCOLO_COMBAT_LAB.md): più grandi, assaltatore/lanciatore/aggiratore, sfere prototipo, esclamazioni e passi acuti, danze e principale più aggressivo a bassa salute. Copie protette durante hit secondo l'ultima richiesta. Prossimo playtest FPS/mix audio.

**17/10 — prova Broccolo giocabile:** [F6 apre direttamente FPS e lotta](BROCCOLO_COMBAT_LAB.md), Tab apre studio. Integrate sei nuove animazioni, copie disperse in direzioni casuali con alone arancione tenue, dimensioni circa30cm. Test ciclo/transizioni e movimento/spari reali passati; pronto per playtest utente.

**17/10 — laboratorio boss Broccolo:** [scena F6, controlli, Inspector e limiti](BROCCOLO_COMBAT_LAB.md). Prototipo isolato con shrink/aura blu, finestre danno, copie da due colpi, rigenerazione, ostacoli e VFX; mappa/cinematic congelate. Lanci di sfere esplosive richiesti come fase futura.

**Ripresa corrente 18/10 — Broccolo:** l'utente ha confermato la prima cinematic fluida e uniforme; prima e seconda cinematic sono congelate. Prossimo obiettivo: scena isolata per provare animazioni, corpo boss/aura blu, cloni melee, VFX e ciclo di rigenerazione prima dell'integrazione nel magazzino. Handoff completo in [BROCCOLO_MAP_INTRO](BROCCOLO_MAP_INTRO.md), stato in [CURRENT_STATE](CURRENT_STATE.md), specifiche e decisioni aperte in [DECISIONS_AND_BACKLOG](DECISIONS_AND_BACKLOG.md).

**17/10 — Broccolo, regia seconda fase:** prima camera avanzata a2,8m per liberare l'angolo; durante la danza camera e player arretrano insieme (nel test mappa percorso diagonale sicuro0,63m su1m richiesto), poi la visuale FPS rientra nello stesso punto. Riduzione e avvio del flusso minion restano in coda. Test fixture/mappa passati. [Dettagli](BROCCOLO_MAP_INTRO.md).

**17/10 — Broccolo, avanzamento danza controllato:** fermo durante dialogo e prime due clip; avanza di0,35m solo nella finestra di salto di `mie/dancing`. Fixture e mappa passate, capsule senza contatti. [Dettagli](BROCCOLO_MAP_INTRO.md).

**18/10 — facing della seconda cinematic Broccolo:** compensato il fronte del modello (+Z locale) rispetto al `look_at` standard (-Z); l'allineamento viene applicato dopo il reset della sequenza. Fixture e mappa reale passate con `--cinematic-only`, includendo controllo prima e durante il dialogo. [Dettagli](BROCCOLO_MAP_INTRO.md).

**18/10 — Broccolo, fase due:** prima intro avviata verso la fine del dolly (3,25s); tragitto dell’attore ripianificato dal lato magazzino fino al marker, che resta invariato. Telefono lanciato con rimbalzo fisico fino all’assestamento. Avvicinarsi entro 2,4m avvia il secondo discorso/danza; il segnale finale avvia ondate di 2–3 minion melee da circa20cm. Fixture e mappa passate (`failures=0`, actor/camera contacts=0); playtest visivo necessario. [Dettagli e limiti](BROCCOLO_MAP_INTRO.md).

**18/10 — correzione cinematica Broccolo:** il lancio usa il vettore del gesto della mano. Il secondo incontro conserva la visuale FPS attuale e ruota direttamente verso Broccolo; lui guarda il giocatore e la danza resta sul posto nella corsia stretta. Test headless fixture e mappa, solo fino al discorso, passati; playtest visivo ancora necessario. [Dettagli e limiti](BROCCOLO_MAP_INTRO.md).

**17/10 — ultima correzione telefono Broccolo:** [guida](BROCCOLO_MAP_INTRO.md). L'originale resta immutato e agganciato alla mano; al lancio sparisce e compare una copia separata con traiettoria visiva breve, poi rimossa. Test fixture e mappa completa passati (`failures=0`). La verifica visiva utente resta aperta.

**17/10 — Broccolo, camera e luci corridoio:** alla partenza del filmato si accende il circuito Luci Corridoio Magazzino; la camera percorre l'asse del corridoio in 4s con traiettoria smussata e sweep sferico contro gli ostacoli. Il telefono lanciato viene rimosso 0,8s dopo essersi assestato. Playtest utente da ripetere.

**17/10 — correzione telefono Broccolo (superata):** la copia fisica/atterraggio e' stata sostituita dalla traiettoria breve visiva richiesta dall'utente; vedere l'ultima voce del registro.

**17/10 — Inspector generale, player e armi:** [guida pratica](INSPECTOR_CONFIGURATION.md) estesa a salute, movimento, dotazione iniziale, inventario, munizioni, torcia, audio, interazioni e parametri nativi dei nodi. Defaults conservati e checkpoint prioritari. Standard generale anche in AGENTS; configurazioni nuove e valori personalizzati testati con player reale.

**17/10 — standard Inspector:** porte WarehouseDoors migrate a12configurazioni figlie modificabili nell'editor; gruppi/descrizioni per porte e interruttori, fingerprint configurabile. ID e valori approvati conservati, test mappa/configurazione/editor passati. Regola futura in AGENTS e standard tecnici. [Guida pratica](INSPECTOR_CONFIGURATION.md).

**17/10 — ingresso magazzino e lampadari:** Luce Tonda_006 collegata al nuovo interruttore indipendente; lampadine dei2lampadari accese con il loro circuito grazie alla maschera emissiva originale recuperata dal GLB. Test12luci/6switch/18materiali e renderGPU passati. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — lati Luce Tonda:** controllo emissione esteso dai soli centri ai sei gruppi interi, includendo i corpi laterali.12materiali corridoio +2specchi, originali conservati. [Guida](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — rifinitura approvata come obiettivo dopo playtest:**038 invertita verso giocatore/scale, emissione delle6superfici corridoio e2specchi bagno sincronizzata agli interruttori. Materiali originali conservati, test mappa e regressione luci passati. [Dettagli](WAREHOUSE_ZONE_2026-10-15.md).

**17/10 — magazzino:** collegate anche le grigliate013/014/015 e038 sopra le scale;12porte totali,11luci nei5circuiti esistenti. Test runtime passati, scena/materiali/luci utente conservati. [Guida aggiornata](WAREHOUSE_ZONE_2026-10-15.md). Prossimo playtest dopo riavvio scena.

**15/10 — porte nuova zona:** otto battenti collegati con outline/E, quattro liberi, tre chiavi distinte, CED fingerprint blu/rosso/verde e sblocco10s. Luci/F4 confermati dall'utente. [Guida, nodi e limiti](WAREHOUSE_ZONE_2026-10-15.md). Chiavi non ancora collocate; enigma impronta e boss futuri.

**15/10 — nuova zona magazzino/bagni:** [cinque interruttori collegati, prove e fasi successive](WAREHOUSE_ZONE_2026-10-15.md). Primo passo luci completato; prossime porte, CED fingerprint futuro e boss con indizio, uno alla volta. Reimport GLB confermato dall'utente.

**15/10 — errore export connesi14:** [causa Material.013 dei CamionShell e normal UDIM packed, PNG identico pronto](CONNESI14_EXPORT_MATERIAL_ERROR_2026-10-15.md). Correzione testata in RAM sul materiale isolato; sorgente non modificato.

**Chiusura13/10 — Broccolo approvato:** utente «perfetto salva tutto»; bocca e due presentazioni salvate localmente,28clip. Ripartire dalla [guida](BROCCOLO_MOUTH_AND_PREVIEW.md) per le future fasi mappa/minion. Nessun commit/push.

**Broccolo — 13/10:** [bocca/denti, studio delle23clip, discorso e danza con miniatura](BROCCOLO_MOUTH_AND_PREVIEW.md). Prima fase isolata, prova utente aperta.

**Aggiornamento presentazioni:**28clip, talking reimportate adattate e collegate; due scene F6 per telefonata22s→lancio→camminata e discorso21s→danza3/2/1→20cm, con musica in sottofondo. [Guida](BROCCOLO_MOUTH_AND_PREVIEW.md).

**Broccolo animazioni — 12/10:** [correzione scala del bacino e clip compatibili](BROCCOLO_ANIMATIONS.md), versioni in_place e con_spostamento verificate sul GLB innestato.

**Broccolo revisione — 12/10 sera:** [Diffuse e NORMAL, anteprime e collegamenti Blender](BROCCOLO_TEXTURE.md): sangue approvato, loghi rivisti, PARKSIDE sul gilet e casco bianco; nuova normal dalla texture modificata. Originali e innesto testa preservati; nessuna nuova AI/gameplay.

**Ripresa 12/10 sera:** utente conferma [KONA V2](KONA_CONNESI_LIVERY.md) reimportata e gioco provato integralmente. Nuova correzione [faro Angelastri durante combat](ANGELASTRI_COMBAT.md); conferma manuale di quest'ultima ancora aperta.

**Pulizia asset — 12/10/2026:** [archivio reversibile e controlli](ASSET_ARCHIVE_2026-10-12.md),6.047file/13,89GiB; nemici conservati integralmente. Consultare i registri prima di ripristinare o modificare i file archiviati.

**Texture14 attive — 12/10/2026:** [verifica del GLB e benchmark memoria/tempi](CONNESI14_TEXTURE_BENCHMARK.md). Risparmio231MiB confermato; caricamento e picchi iniziali restano da diagnosticare.

**Texture applicate a connesi14 — 12/10/2026 sera:** [sorgente aggiornato, verifiche e backup](CONNESI14_TEXTURES_APPLIED.md). 26 riduzioni sul salvataggio delle 16:55, tutte le 536 immagini conservate; prossimo export/import Godot prima di misurare il beneficio.

**Reimport14 — 12/10/2026 pomeriggio:** [benchmark nuova mappa e riparazione collider rack](CONNESI14_REIMPORT_BENCHMARK.md). Fluidità sintetica migliorata, caricamento ancora lungo; GLBancora con risoluzioni originali delle texture controllate, sorgente14più recente della copia notturna.

**Connesi14 — 12/10/2026:** [mesh ridotte e copia con26 texture ottimizzate](CONNESI14_TEXTURE_OPTIMIZATION.md). Sorgente intatto, copia locale pronta da confrontare in Blender; asset attivi Godot ancora precedenti.

**Priorità performance 11/10/2026:** [audit Blender e benchmark della mappa](PERFORMANCE_AUDIT.md). Richiesta ottimizzazione prima del gameplay; `connesi13.blend` analizzato senza modificarlo. Consultare questo punto prima delle priorità storiche sotto.

**Chiusura 11/10/2026:** utente conferma «ok ci siamo» dopo prova in game del sangue corretto. Evento Angelastri, combattimento/racchetta, mirino condiviso e VFX sono il punto di ripresa approvato. Leggere la chiusura in SESSION_LOG e [ANGELASTRI_COMBAT](ANGELASTRI_COMBAT.md); F7 patrol/F11 fight diretta. L'utente richiede ora commit/push di codice, scene e documenti; asset locali e limiti di riproducibilità annotati nel registro.

**Ripresa combattimento Angelastri:** [F7 passeggiata, secondo incontro, IA/racchetta e prove](ANGELASTRI_COMBAT.md). L'utente conferma prima performance senza freeze/sparizione; fase combat implementata e testata in fixture isolata, prossimo playtest mappa.

**Evento Angelastri:** [sequenza contatore/terza uscita, regia TikTok, faro e prova dal salvataggio](ANGELASTRI_ENCOUNTER.md). Preview mappa approvata; ora evento automatico, F10/F11/F12 disabilitati. Combattimento/racchetta arma fase successiva.

**Prova Angelastri in mappa:** [controlli F10/F11/F12 e percorso nel piazzale](ANGELASTRI_MAP_PREVIEW.md). Intro/balletto e dialogo studio approvati dall'utente; ora prova in `map_test`, prima della dinamica dell'incontro.

**Ripresa Angelastri — 11/10/2026:** [passaggio di consegne e piano per fasi](ANGELASTRI_IMPLEMENTATION_PLAN.md). Bocca V2 approvata; prossimo lavoro: sola preview del modello e delle 27 animazioni mie. Poi cinematiche (due blackout senza nemico, comparsa alla terza uscita), infine combattimento/racchetta. Questa priorità supera le indicazioni storiche sotto.

[Bocca Angelastri](ANGELASTRI_MOUTH.md): modello ufficiale, variante con denti, prova F6 e animazioni preservate.

[Audio regia](REGIA_AUDIO.md): effetti edificio, estratti, sincronizzazione con tasti/porta/cavi/pagine, test e prova sonora.

Preparata l'8 ottobre 2026 dal PDF e dall'ispezione locale. Serve a riprendere il lavoro distinguendo baseline Git, working directory e test storici.

## Da dove ricominciare

**Ripresa confermata 11/10/2026:** l'utente ha provato le ultime rifiniture in mappa e conferma «ok funziona tutto». Preservarle. Alla prossima sessione leggere [CURRENT_STATE](CURRENT_STATE.md), l'ultima voce [SESSION_LOG](SESSION_LOG.md) e la [guida regia](REGIA_NETWORK_PUZZLE.md); continuare con il prossimo obiettivo scelto dall'utente senza rifare il lavoro completato. La prova esplicita di PC/Carica/C-N/riavvio resta aperta. Nessun commit/push.

Le voci datate qui sotto sono cronologia; le priorità e le conferme ancora aperte descritte in esse sono superate dal punto di ripresa qui sopra, salvo il ciclo completo di salvataggio.

**Ultima ripresa:** portatile ingrandito verso la sedia, caricatore raccoglibile e kit recuperabile dopo Arresta il sistema; icone/esame per tutti gli oggetti, libro e appunti aperti 3D. Leggere ultima SESSION_LOG e [guida regia](REGIA_NETWORK_PUZZLE.md); il nuovo ciclo è E caricatore → deposito PC → E collegamento/accensione/uso → enigma → Start/Arresta → E raccolta. Nessun commit/push.

**Ripresa prevalente dopo il playtest:** logica puzzle confermata dall'utente; nuova revisione visiva di portatile/Fritz/desktop/glifi/cavi/chiave documentata in [REGIA_NETWORK_PUZZLE](REGIA_NETWORK_PUZZLE.md). Leggere CURRENT_STATE e ultima sessione per gli esiti; provare F8/F6 map_test. Le note precedenti su istruzioni non lette sono storiche. Nessun commit/push.

**Ultima chiusura dopo crash della finestra, 10/10/2026:** istruzioni finali non lette dall'utente, ora salvate nella [guida di consegna](REGIA_NETWORK_PUZZLE.md#istruzioni-di-consegna-per-la-prossima-sessione). Leggere CURRENT_STATE e l'ultima voce SESSION_LOG; ripresentare le istruzioni nella prossima sessione. Puzzle implementato e verificato tecnicamente, playtest utente ancora aperto. Crash segnalato senza diagnosi; nessun commit/push.

**Ripresa prevalente 10/10/2026:** implementato il nuovo [puzzle di rete regia](REGIA_NETWORK_PUZZLE.md), su addon della mappa aggiornato dall'utente. Portatile, alimentatore, cavi, Fritz, appunti, racchetta esaminabile, porta aliena e due interruttori; test tecnici nel registro, playtest utente aperto. Chiusura aliena resta agganciata alla porta dopo sblocco. Preservare sistemi approvati; nessun commit/push. La precedente segnalazione Bruno è archiviata dopo conferma utente.

**Chiusura attuale 10/10/2026:** utente approva schermata caricamento finale pulita. Menu Carica, ordine Nuova partita/Carica e loader condiviso completati. Leggere il punto di ripresa in CURRENT_STATE e l'ultima voce SESSION_LOG: non ripetere attività già concluse. Prova manuale completa salvataggio nella mappa ancora da confermare; scegliere con l'utente il prossimo obiettivo. I passaggi di consegne più vecchi sotto sono storici.

**Aggiornamento successivo:** immagini Carica salvataggio già collegate nei due menu; Nuova partita sopra Carica nel principale. Resta prova estetica utente e playtest completo salvataggio nella mappa. Consultare ultima sessione, senza ripetere il collegamento degli asset.

**Ultimo passaggio di consegne, 10/10/2026:** attraversamento scorrevole confermato dall'utente. Prossima modifica: collegare le immagini utente `assets/ui/caricasalvataggio.png` e `assets/ui/caricasalvataggio_blob.png` al Carica salvataggio nei menu. Leggere [integrazione regia](REGIA_MAP_INTEGRATION.md) e ultima sessione per distinguere conferme utente e test automatici; il playtest completo del salvataggio nella mappa resta aperto.

1. Leggere [AGENTS.md](../AGENTS.md) e il contratto nella [baseline SAFE](BASELINE_SAFE_2026-10-08.md).
2. Leggere [CURRENT_STATE.md](CURRENT_STATE.md) e ripetere i controlli Git: i valori sono una fotografia datata.
3. Leggere l'ultima voce di [SESSION_LOG.md](SESSION_LOG.md) e [DECISIONS_AND_BACKLOG.md](DECISIONS_AND_BACKLOG.md).
4. Definire l'obiettivo richiesto dall'utente, leggere i file reali e [ARCHITECTURE.md](ARCHITECTURE.md).
5. Applicare [WORKFLOW_AND_TESTING.md](WORKFLOW_AND_TESTING.md) e gli [standard](PROJECT_BLOB_STANDARDS.md).

## Indice

[Integrazione regia nella mappa](REGIA_MAP_INTEGRATION.md): tre porte reali, drop chiave Bruno, monitor PC, persistenza e prove F6.

[Blocco passaggio Bruno](BRUNO_PASSAGE_COLLISION.md): confronto bocca on/off, collider obsoleto della parete e correzione mirata nella mappa.

Nuova prova isolata: [bocca di Bruno](BRUNO_MOUTH_PREVIEW.md), scena F6 e controlli, asset e verifica del taglio labiale.

| Documento | Contenuto | Aggiornamento |
|---|---|---|
| [Baseline SAFE](BASELINE_SAFE_2026-10-08.md) | Trascrizione completa delle sezioni 0–17, inventario di 80 script | Fotografia storica; eventuali errata espliciti |
| [PDF originale](Project_Blob_Baseline_SAFE_2026-10-08.pdf) | Fonte di 10 pagine | Conservare inalterato |
| [Stato corrente](CURRENT_STATE.md) | Git, differenze locali, strumenti, rischi e inventario | Quando cambia lo stato rilevante |
| [Architettura](ARCHITECTURE.md) | Flussi, scene, contratti e parametri | Quando cambiano sistemi o collegamenti |
| [Decisioni e backlog](DECISIONS_AND_BACKLOG.md) | Vincoli, priorità e criteri di completamento | A ogni decisione o cambio di stato |
| [Procedura e test](WORKFLOW_AND_TESTING.md) | Ripresa, Git/asset, prove e consegna | Quando cambia il metodo |
| [Registro sessioni](SESSION_LOG.md) | Lavoro svolto e modello di passaggio | A fine sessione, aggiungendo una voce |
| [Standard tecnici](PROJECT_BLOB_STANDARDS.md) | Impatti, superfici, audio, opzioni, atmosfera | A nuovi standard approvati |
| [Istruzioni agenti](../AGENTS.md) | Regole e lettura dalla radice | A variazioni del contratto |
| [Texture BetterBuozzi connesi](BETTERBUOZZI_CONNESI_TEXTURE.md) | Asset, UV, materiale, prompt e verifiche della maglietta | Quando cambia la scritta o la sua assegnazione |
| [Inventario e ConnesiOS](INVENTORY_SAVES_CONNESIOS.md) | Chiave Bruno, porta scorrevole, PC, checkpoint, test e integrazione futura | Quando cambiano stato salvato o collegamenti |

## Etichette di verifica

- **VERIFICATO GITHUB**: dato accertato sul commit indicato secondo il PDF; questa sessione non ha interrogato GitHub.
- **VERIFICATO LOCALE — ANALISI STATICA**: osservato nei file o con comandi locali; non prova il runtime.
- **TESTATO UTENTE**: conferma esplicita riportata nel PDF o registrata nella sessione indicata.
- **STORICO**: dato precedente non riverificato nello stato attuale.
- **LOCALE NON PUSHATO**: differenza dalla baseline locale Git o dato dichiarato nel PDF; remoto live da verificare separatamente.
- **APERTO / NON VERIFICATO**: risultato o comportamento da accertare.

Il locale descrive i file attuali; il PDF conserva storia e intenzioni; Git conserva solo ciò che è registrato. In caso di differenze confrontare e documentare, senza ripristinare automaticamente una versione.

## Prompt pronto per una nuova sessione

> Stiamo continuando Project Blob, FPS Godot + Blender in `D:\ProjectBlob\Game`, repo `fraidotube/project-blob`, branch di riferimento `dev/prototype-0.1`. Leggi `AGENTS.md` e `docs/README.md`, poi baseline SAFE, stato corrente, decisioni/backlog e ultima sessione. Verifica HEAD e stato Git reale: esistono modifiche locali, asset non tracciati e ignorati. Non sovrascriverli e non inventare collegamenti. Segui l'obiettivo richiesto, leggi integralmente i file coinvolti e fai una modifica mirata con test pertinenti. Distingui controlli statici, test storici e nuove conferme. Nessun commit/push senza mia richiesta. Aggiorna il registro alla chiusura. Inventario/chiave/porta/ConnesiOS sono implementati nella scena autonoma: leggi INVENTORY_SAVES_CONNESIOS.md. La prossima integrazione richiede i nodi reali della nuova stanza reimportata; la mappa locale differisce dalla baseline Git.

## Limiti

Questi file conservano il PDF, gli standard e le osservazioni verificabili della sessione. Conversazioni precedenti non incluse nel PDF, sorgenti Blender esterni e asset locali non vengono ricostruiti o copiati dai Markdown. La documentazione non sostituisce il backup dei file.
# **17/10 — Broccolo, regia aggiornata:** rotazione della camera anticipata lungo il primo dolly; nella seconda cinematic un percorso sicuro di4,8m riporta camera e player vicino alla svolta iniziale (distanza residua0,39m per gli ostacoli). Il salto della danza avanza fino a1m. Idle ruota quando il personaggio esce dall'inquadratura. Test mappa `--cinematic-only` passato; playtest visivo richiesto. [Guida](BROCCOLO_MAP_INTRO.md).
**19/10 — Luci boss fight Broccolo:** tinta viola leggera sulle luci ambientali durante la battaglia; ripristino alla sconfitta o allo stop. Playtest visivo all'utente.
**19/10 — Broccolo:** tinta viola delle luci confermata dall'utente; default Inspector dell'offset della seconda presentazione aumentato di 10 cm.
