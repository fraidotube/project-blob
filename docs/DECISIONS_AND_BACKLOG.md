# Project Blob — decisioni e attività aperte

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
