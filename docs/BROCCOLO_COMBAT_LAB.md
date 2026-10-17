# Broccolo — laboratorio boss fight (17/10/2026)

## Sfera energetica e bruciatura — prova18/10

Utente approva anche il lampo arancione e richiede sfera piu bella, con effetto simile all'aura, e giocatore incendiato per alcuni secondi quando viene colpito. Prova ancora nel laboratorio, senza caricamento o aggiornamento mappa.

Sfera: nucleo azzurro/bianco pulsante, anello rotante, involucro infuocato e scia di scintille arancioni. `scenes/effects/broccolo_energy_visual.tscn` riusa IDENTICA PowerVFX approvata senza modificarla; alone orientato lungo il volo e particelle in coordinate mondiali per lasciare la scia. All'impatto si espande e si dissolve in0,4s insieme al burst esistente. Collisione resta sferica0,065m, velocita/raggio/danno restano quelli della mossa. Il visual e lo shader FPS vengono preparati prima della lotta.

**Impatto diretto sul player:** danno iniziale della mossa7o9, poi bruciatura3s con3danni ogni0,75s (4tick,12extra). Esplosioni vicine conservano danno area senza incendiare. Sweep identifica il collider reale; LOS impedisce danno e incendio attraverso pareti. Una sola condizione per player, i nuovi impatti rinnovano durata senza aggiungere tick paralleli o rinviare il tick gia in corso. Il danno usa take_damage reale, quindi HUD, flash/voce e morte esistenti. Morte, F3 e sconfitta boss spengono la condizione; F7 sospende danno e VFX.

Fiamme3D attorno al corpo quando osservato dalla camera studio; nella camera FPS viene usato un effetto animato ai bordi, senza il guscio davanti alla mira. Overlay sotto HUD e senza catturare input. Nessuna modifica ai controller player/hazard/HUD storici: il fuoco ambientale attuale resta danno nell'area, mentre il nuovo stato e un figlio del solo player laboratorio.

**Prova rapida:** F6 `broccolo_combat_test.tscn`, Tab: **Lancio sfera sul selezionato** usa throw reale; **Prova bruciatura in FPS** spegne AI, torna FPS e attiva solo l'incendio per valutarlo. Nessuna dotazione iniziale o salute viene riassegnata. I3s sono tuning iniziale modificabile.

**Inspector:** root laboratorio collega Energy Visual Scene e Burn Status. Player/BroccoloBurnStatus espone target/camera, durata, danno/intervallo tick, altezza e tinta; nodo ai piedi del player (Y−0,9). Scene EnergyVisual: Aura Size/Flame Color, mesh/materiale Core e Orbit nativi; BodyFlames/Aura istanziano la risorsa condivisa. In mappa entrambi i link root restano null: proiettile precedente e nessuna bruciatura finche non si trasferisce il pacchetto approvato.

`broccolo_energy_burn_test.gd`: impatto fisico reale/danno singolo,4tick, rinnovo non cumulativo, pausa, scadenza, stop, morte, muro reale dell'arena, AoE senza incendio, overlay FPS e serializzazione/applicazione nondefault1s/2danni/0,25s. GPU produce `.godot/broccolo_energy_sphere.png` e `.godot/broccolo_player_burning_fps.png`. Regressione ruoli aggiornata a distinguere danno iniziale da danno periodico. Mancano ancora audio dedicati energia/esplosione; non assegnati suoni arbitrari.

## Prova effetti 18/10 — prima approvazione nel laboratorio

Aggiornamento: aura di trasformazione gradita dall'utente. Alla duplicazione ora anche **lampo arancione0,22s**, intensita0,65, fade finale80ms sul principale e sulla copia; poi restano particelle e bordo. Se il principale e ancora dorato, torna alla tinta precedente dopo il lampo senza spegnere l'aura. Copy Flash Seconds/Strength sul root PowerVFX regolano durata/intensita. Prova ancora solo nel laboratorio, stessa risorsa da trasferire dopo conferma.

Utente conferma che la battaglia in mappa funziona e richiede nuove nascite dal corpo, particelle, alone copie leggibile e trasformazione con aura dorata ispirata a un power-up anime. **Provare solo qui; trasferire IDENTICI in mappa dopo approvazione.** Nessun caricamento/playtest mappa per questa fase.

Aprire `scenes/levels/broccolo_combat_test.tscn`, F6. La trasformazione parte all'avvio, con fiamme dorate animate, scintille/striature ascendenti e onda circolare; prosegue1,4s dopo la riduzione. Tab apre lo studio: **Ripeti trasformazione / aura dorata** seleziona il principale e la ripete senza ricaricare; **Emetti / rigenera copie** prova la nascita (aspettare la fine della riduzione). La camera studio lascia piu spazio all'aura.

Nuova fase emerge: copia e capsula iniziano esattamente sul principale, modello iniziale15% della miniatura; per0,5s cresce ed esce con movimento fisico lungo la direzione casuale, poi inizia la fuga/corsa. Collisioni ambiente attive e nessun teletrasporto in avanti. Particelle arancioni sulla sorgente e sulla copia; niente doppi gusci che nascondano il modello. Colpire durante la nascita conserva i2impatti validi e la protezione hit, completando subito la scala visiva per non lasciare copie minuscole.

Unica risorsa `scenes/effects/broccolo_power_vfx.tscn`, collegata a **MainBroccolo / Preview Vfx Scene solo nel laboratorio**; pool eredita lo stesso riferimento. In mappa il riferimento resta null e usa il comportamento approvato precedente, compreso bordo0,08. Non duplicare/ricreare gli effetti per la futura integrazione: usare questa scena e gli stessi parametri; il collegamento all'ultima riduzione della cinematic va fatto dopo approvazione, senza cambiare la resa. Script cinematic, controller mappa e map_test intatti in questa fase.

Per tuning aprire la scena PowerVFX: root per colore/durata/glow trasformazione, tempo emersione, durata getto e bordo copie (Strength0,4, Width0,006m, Glow2, minimo pulsazione0,7); figli Sparks/Streaks per quantita/dimensioni/lifetime native, Flames/GroundRing per mesh/materiali. Particelle con sfumatura radiale procedurale, nessun asset esterno. Massimo72particelle per componente; componenti persistenti creati insieme al pool e preparati nella SubViewport, non istanziati al rilascio. F7 sospende timer/fiamme/particelle; il ritorno al pool spegne tutto.

Verifiche: nuova `broccolo_vfx_lab_test.gd` passata headless e GPU Forward+ D3D12; capture `.godot/broccolo_vfx_transform.png`, `power_tail`, `birth`, `orange` con prefisso broccolo_vfx. Controlla origine identica, emersione prima della corsa, effetti su sorgente/copia, bordo visibile, coda della trasformazione, pausa/spegnimento, muro fisico e durata nondefault0,7s, hit durante nascita, reset pool e versione legacy senza profilo. Regressione combattimento passata; nessun playtest manuale o approvazione estetica ancora dichiarati.

**Ultimo audio approvato come richiesta:** solo `esclamazione1…4_mostro.mp3` per principale e copie; escluse le versioni senza `_mostro`. Reazioni ai colpi ora `colpito1/2/3_mostro.mp3`, senza ripetizione consecutiva, pitch originale, voce/bocca sincronizzate anche sul colpo letale. Si saltano in riproduzione i silenzi iniziali misurati (45/80/105ms), senza modificare gli MP3. Guadagno reazioni+8dB per i file registrati a basso livello. Passi aumentati da−15a−4dB, unità attenuazione6m e portata16m;3voci consentono le code senza riavviare lo stream a ogni passo. Tutto configurabile su LabAudio. Test PCM a4m: picco passi0,0141 prima→0,1004 dopo, test feedback passato; ascolto finale sempre dell'utente.

## Integrazione mappa e copie preparate (18/10)

La richiesta utente successiva autorizza il passaggio alla mappa reale. `map_test.tscn/BroccoloEncounter/BroccoloMinionSpawner` istanzia `scenes/enemies/broccolo_map_combat.tscn`: riceve il configure gia previsto dopo la seconda presentazione e avvia principale/copie del laboratorio. Le cinematiche non sono modificate. HUD condiviso con ritratto Broccolo e colori blu durante il combattimento, valori precedenti ripristinati alla fine. Nessun indizio/drop aggiunto in questa fase.

Le copie sono costruite una volta prima dello scontro, nascoste/disabilitate fino all'emissione, poi riutilizzate dopo dying e dissolvenza. Reset di salute, animazione, audio, recuperi e locomozione a ogni emissione; ruoli stabili. La bocca GLB viene letta una volta e condivide solo la mesh: blend shape ed espressioni restano per istanza. Con GPU attiva una piccola SubViewport prepara anche mesh/aura/VFX sotto il livello. Il costo viene anticipato alla preparazione, non ripetuto al respawn.

Navigazione locale multiquota campionata sulla fisica reale, costruita in porzioni con budget configurabile; pavimenti e scale sono collegati quando la capsula puo passare. Solo i tre battenti autorizzati sono esclusi dal grafo per considerarli passaggi apribili; le collisioni fisiche restano attive. Vicino a una grigliata chiusa, se il player e dall'altra parte, un Broccolo salta e richiede l'apertura al momento configurato. La porta conserva audio, sweep e protezione del player; questa richiesta non muove o blocca i suoi controlli. Solo WarehouseGrid013/014/015 sono abilitate, nessun accesso a CED, serrature o porta scale.

Le tre soglie hanno anche un collegamento esplicito fra i pavimenti sui due lati, ammesso soltanto dopo sweep libero della capsula; evita che una fila mancante nella griglia produca un giro lungo attorno al varco. Se un altro punto vicino al target e separato dal grafo raggiungibile, la navigazione ammette un percorso parziale verso il limite piu vicino; salto e recupero incastri possono completare l'avvicinamento. Il campionamento e conservativo: disposizione di mobili e scale resta da valutare nel playtest, senza promessa di navigazione perfetta in tutto il livello.

Inspector: aprire `broccolo_map_combat.tscn` per cap/cooldown, Roles, volume di navigazione, budget millisecondi, riferimenti porte e altezza/tempo/distanza salto. Nella mappa selezionare WarehouseDoors/PortaGrigliata013, 014 o 015 per Enemy Jump Open Enabled. ID stabile del combattimento `main.broccolo.combat`: salvataggi bloccati durante lo scontro e vittoria conservata; nessun reset della dotazione del player.

Verifica finale18/10: `broccolo_pool_test.gd` passato su GPU (singola testa, morph indipendenti, identita/reset copia; emissioni0,69/0,573ms). `broccolo_map_combat_test.gd` passato su mappa reale:4785punti,3portali,8punti completi attraverso013, salto/apertura da entrambi i lati delle tre porte, passaggio capsula e inseguimento automatico, handoff e stato vittoria. Regressione laboratorio passata. Log finale `.godot/broccolo_map_combat_final_pass.log`; renderer Dummy segnala material null durante teardown, assente nella suite pool GPU. Playtest manuale/mix/fluidita percepita restano dell'utente.

## Aggiornamento ruoli, audio e regole hit

Ultima richiesta utente prevalente: copie protette **durante tutta la reazione al colpo**; appena finisce tornano vulnerabili, senza recupero aggiuntivo. Occorrono sempre2impatti validi, distanziati dalla reazione. Il danno avvia subito la clip a tempo0 senza blend ritardato: running_hit_short per l'assaltatore in corsa, running_hit per altri corpi in movimento, hit_fromstand da fermo. L'ultimo impatto valido avvia direttamente dying. Il bordo arancione rimane tenue e non rappresenta invulnerabilità permanente.

Dimensioni aumentate0,17→0,20 (~36–38cm). Principale2,4m/s. I3ruoli sono nodi sotto **BroccoloCombatTest/Roles** e si rigenerano mantenendo il tipo mancante:

| Ruolo | Corsa | Comportamento |
|---|---:|---|
| Assaltatore |3,8m/s| Percorso diretto quando libero, altrimenti navigazione; niente scenette/inversioni lunghe, pausa attacchi0,35s |
| Lanciatore |2,2m/s| Solo throw/trow2/trow_grenade; cerca distanza4m, pausa1,8s dopo il gesto, nessun melee automatico |
| Aggiratore |2,8m/s| Waypoint laterale a2,6m, fase larga2,2s prima di chiudere; melee e occasionali scenette |

La barra e gli HP del principale scendono **soltanto colpendo lui** nelle finestre valide. Il boss a salute piena preferisce stare a4m e attaccare con pausa4s; perdendo salute chiude progressivamente fino a0,55m e la pausa scende verso0,55s. Le scenette vulnerabili restano disponibili; almeno ogni terza scenetta viene scelta una danza (salsa/dancing/dancing2/dancing3).

Recupero incastri: se vuole muoversi ma non avanza, tenta fino a2salti dopo0,4s; dopo1,6s prova una deviazione laterale/indietro per0,9s, poi riprende la navigazione. I parametri sono sul componente attore; il monitor conserva l'intenzione di movimento anche se lo steering si ferma contro un ostacolo.

Audio: quattro `esclamazione1…4.mp3` sul principale, quattro `_mostro` sulle copie; selezione casuale senza ripetizione consecutiva, una sola voce per volta, bocca collegata al sistema RMS esistente. Il gesto continua se la voce dura più della clip. Voci interrotte al colpo/morte/stop e sospese con F7. `LabAudio` usa suoni 3D sul bus SFX: gli stessi passi tile del player con pitch1,7/volume−15dB, salto/atterraggio del player più acuti, punch2 per colpi connessi e zombie_hit per reazioni. I passi dipendono dal movimento fisico reale, non da timer durante l'idle. Stream, pitch, volume, stride e intervallo sono serializzati su `broccolo_lab_actor.tscn/LabAudio`.

Sfera energetica prototipo: parte al timing della mossa, va diritta a5m/s verso il punto del player al rilascio; sweep sferico contro player/ambiente, esplosione a impatto o scadenza3s, raggio1,2m e danno7 (9 per trow_grenade), controllo occlusione per non colpire attraverso muri. Nessun danno a copie/principale. Stop/defeat eliminano i proiettili rimasti; F7 li sospende. Il pulsante studio **Lancio sfera sul selezionato** permette la prova manuale. Timing/velocità/raggio/danno sono sui nodi Moves; l'effetto luminoso è provvisorio. Mancano suoni dedicati di carica/lancio energetico ed esplosione: i colpi fisici già disponibili non sono stati spacciati per esplosioni.

Test `broccolo_roles_audio_test.gd`: ruoli/velocità, barra indipendente dalle copie, hit immediato e protezione, aumento aggressività, quattro MP3 per gruppo/voce/bocca/pausa, balletto, lancio automatico singolo e danno, occlusione esplosione, aggiramento, passi acuti e salto→cambio rotta da blocco. Passato headless; suite FPS reale e regressione GPU passate. Ascolto e bilanciamento del mix restano al playtest utente: Audio Dummy e proprietà degli stream non dimostrano il gradimento sonoro. Le sezioni precedenti sotto conservano il contesto; in caso di divergenza valgono queste regole aggiornate.

Aprire `scenes/levels/broccolo_combat_test.tscn` e avviare con F6. La scena parte direttamente in **FPS giocabile con combattimento automatico**: principale a grandezza originale, riduzione luminosa fino a scala0,17 (circa30cm), poi inseguimento e copie. Muoversi e usare le armi con i comandi abituali; Tab apre lo studio. Non carica la mappa e non usa le due cinematic approvate. Sul root Start In Fps e Auto Combat permettono di tornare all'avvio manuale.

## Prova manuale

Il pannello studio permette di selezionare principale/copie, provare tutte le34clip della scena aggiornata dall'utente, aprire una scenetta, colpire il selezionato, eseguire FlyingKick e vedere onda/emissione. **Gioca in FPS e combatti** riattiva player e lotta insieme. La visuale ravvicinata segue il selezionato; il pulsante vista alterna con l'arena. Le clip in anteprima non infliggono danno. Per rivedere shrink usare Ricomincia/F8. In studio il viewmodel FPS è nascosto per non coprire il personaggio.

- **Tab:** studio con mouse libero / player FPS e armi reali.
- **F2:** ciclo completo; il principale insegue e genera fino a3copie.
- **F3:** ferma AI/emissioni e torna allo studio.
- **F4:** scenetta del principale, apre la finestra vulnerabile se il recupero è finito.
- **F5:** colpo di prova sul bersaglio selezionato.
- **F6:** riempie i posti disponibili con emissioni dal principale.
- **F7:** pausa/riprendi attori e loro animazioni, emissione e countdown rigenerazione.
- **F8:** ricarica il laboratorio.

Il principale usa30HP. È vulnerabile solo durante le scenette; inseguimento, attacco, trasformazione e reazione sono protetti dall'alone blu pulsante. Dopo un colpo il recupero dura l'intera reazione più1s. Anche forzare una scenetta non scavalca questo recupero. Le copie contano2colpi utili: una raffica potente non equivale a due impatti; rimangono vulnerabili anche durante attacco e reazione. Non contribuiscono al danno sulla barra boss. Dopo il secondo colpo riproducono dying, poi scompaiono con anello/particelle blu. I corpi in morte occupano ancora il posto fino alla rimozione; allora parte il cooldown6s, seguito da emissioni ogni0,7s.

Aggiornamento copie: bordo **arancione molto tenue** (intensità0,08) indipendente dalla vulnerabilità; anche burst di emissione/morte arancione. Le direzioni sono casuali e separate di almeno55° con3copie, compatibilmente con lo spazio fisico; poi ogni copia corre verso l'esterno per0,8s prima di inseguire il player. Non vengono generate attraverso ostacoli. Il vecchio burst blu riguarda ora il principale.

## Nuova locomozione

Le sei nuove clip sono lette dalla scena modello salvata dall'utente e caricate come copie in_place private. `running` è ciclica; `idle_to_run` avvia la corsa, `running_to_stop` frena prima dell'attacco/fermata, `running_jump_to_run` recupera l'atterraggio. `running_change_direction` è una vera inversione di circa180°, dura2,15s e si attiva per cambi di almeno120° con cooldown2,5s: il controller ruota il corpo e rimuove l'escursione yaw del bacino soltanto dalla propria copia runtime, evitando una doppia inversione. Pitch/roll restano nella posa. La camminata resta per le distanze brevi. Il ritmo dei cicli running/walking si adatta alla velocità e allo spostamento nativo della clip alla scala scelta (limite0,5–2,5×). Le transizioni conservano le durate native:0,8s partenza,0,9s frenata,0,5s recupero. `waving` (3,167s) è aggiunta alle scenette vulnerabili.

FlyingKick usa un impulso e un avanzamento con collisioni; una seconda mossa sperimentale JumpSlam usa la clip esistente jump come ricaduta offensiva. Entrambe emettono la stessa geometria d'onda frontale di Angelastri, abbassata alla miniatura e con portata corrispondente al danno. Il controllo del colpo richiede portata, fronte e linea libera. Il sangue dei colpi usa `melee_feedback.gd`, condiviso con Angelastri; gli impatti melee restano prodotti dalle armi esistenti, senza duplicarli nel boss.

Il player locale ha500HP, pistola/SMG/torcia e500colpi di riserva per arma, configurati solo nell'istanza del test. Non vengono assegnati item di progressione e non si avviano nuove partite/restore o salvataggi. La barra è l'istanza dell'HUD condiviso, con override locale `assets/ui/broccolo.png` e colori blu; HUD, player e armi originali non sono modificati.

## Inspector

- **BroccoloCombatTest:** Start In Fps, Auto Combat, Actor Scene, Max Copies, Regeneration Seconds, Emission Interval, Emission Distance, Emission Separation Degrees, griglia locale e collegamenti Boss/Player/HUD.
- **MainBroccolo:** salute, scala, durata shrink, recupero, velocità/distanze, clip di locomozione, soglia/cooldown inversione, gravità, altezza ostacoli, cadenza attacchi/scenette. Per i valori delle copie aprire `scenes/enemies/broccolo_lab_actor.tscn`, oppure assegnare ad Actor Scene una variante ereditata: Copy Aura Strength/Color e Scatter Seconds regolano bordo e dispersione iniziale.
- **broccolo_lab_actor.tscn → Moves:** duplicare una mossa figlia, dare un nome e scegliere una clip verificata `mie/...`, tipo Attacco/Scenetta, timing, portata, danno e impulso. I figli sono la configurazione serializzata, senza tabelle rigide di tuning. La clip deve esistere: errore esplicito se manca.
- **Arena:** ostacoli fisici e visuali sono nodi modificabili; spostare il corpo StaticBody. Il grafo si ricostruisce all'avvio. Luci, camera e materiali usano proprietà native. Nessun `@tool` o scrittura degli asset durante l'editing.

Il corpo fisico scala con Miniature Scale. Il parametro non altera gli asset originali. Le AnimationLibrary e ogni Animation sono copie private runtime; il laboratorio usa le versioni in_place, preserva l'offset modello e resetta le bone pose della scena per eliminare la posa telefono salvata.

## Navigazione e limiti

Griglia AStar3D ricavata dai pavimenti fisici della sola arena, con verifica spazio capsula, quote e collegamenti; il movimento effettivo usa CharacterBody3D e salti verificati contro l'ostacolo. Sono presenti due pareti, un ostacolo20cm, gradini e perimetro. Il percorso aggira la parete alta; il corpo salta gli ostacoli bassi invece di attraversarli. Le scenette alternano danze e cover sneak: vicino a una parete il cover usa una tangente e movimento laterale; senza parete usa la prima danza. Non è arrampicata verticale. I salti e gli spostamenti originali Y delle pose vanno valutati a vista insieme alla fisica.

**Attacchi:** FlyingKick è l'attacco esplicito disponibile; JumpSlam è una reinterpretazione sperimentale di jump, non una nuova animazione. Ulteriori attacchi richiedono scelta delle clip con l'utente. `running_hit` rimane una reazione, non viene usata per correre.

**Lanci:** ora implementati come prototipo sul ruolo Lanciatore, tramite `broccolo_lab_energy.gd`; vedi aggiornamento sopra. Non riutilizzano il controller telefono cinematico.

La navigazione non è ancora adattata al magazzino: porte mobili, scale reali, navmesh della mappa, anti-incastro prolungato e accessibilità di passaggi stretti richiedono la fase successiva dopo il playtest. Non sono implementati drop, puzzle o persistenza boss. Morte del principale ferma emissione e AI delle copie; F8 riparte per la prova successiva.

## Verifiche

`--headless --path D:/ProjectBlob/Game --audio-driver Dummy --script res://scripts/tests/broccolo_combat_lab_test.gd`.

Suite con player/modelli/HUD veri: shrink, finestre danno/recupero, attacco protetto, due colpi su copia anche con danno100, morte differita/rimozione, origine copie, cap/cooldown, percorso attorno alla parete, salto fisico20cm, un solo danno per attacco, campionamento28clip, configurazione Inspector nondefault impacchettata/salvata/reistanziata in `.godot`. Nessuno slot utente scritto. Test headless finale e GPU Forward+ D3D12 passati con `BROCCOLO_COMBAT_LAB failures=0 graph=1655`. Headless finale verifica anche morte principale/stop emissioni e comandi studio che non riattivano i morti; GPU precedente a quest'ultima protezione, con scala/bordo/catture finali. Avvisi ambientali CA store e scrittura cache shader GPU riportati nel registro; nessun errore di compilazione shader o assert.

Le immagini `.godot/broccolo_lab_protected.png`, `broccolo_lab_vulnerable.png` e `broccolo_combat_lab.png` sono catture GPU di fixture. Non sostituiscono playtest audiovisivo, giudizio sulle mosse o verifica nella mappa. Le cinematic congelate non sono state modificate né ritestate.

Aggiornamento running: suite estesa a presenza clip/ciclo running, partenza/inversione/frenata/atterraggio, scala maggiore e aura arancione/direzioni distinte. `broccolo_lab_fps_test.gd` verifica l'avvio FPS automatico, ondata iniziale, input reale di movimento e due spari attraverso il vero WeaponRay con consumo munizioni e morte copia. Entrambe le suite passate; snapshot GPU delle sei clip in `.godot/broccolo_run_*.png`. Il playtest resta aperto per naturalezza delle transizioni e tuning nella mappa.
