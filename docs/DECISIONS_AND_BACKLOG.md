# Project Blob — decisioni e attività aperte

Aggiornamento 08/10/2026. Riferimenti: [baseline](BASELINE_SAFE_2026-10-08.md), [stato locale](CURRENT_STATE.md), [registro](SESSION_LOG.md).

## Decisioni da preservare

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

## Osservazioni e nuove decisioni

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
