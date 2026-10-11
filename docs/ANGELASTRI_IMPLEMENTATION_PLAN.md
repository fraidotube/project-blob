# Angelastri — passaggio di consegne e piano operativo

## Ripartire da qui — 11/10/2026

**Ripresa prevalente:** utente conferma prima performance senza freeze/sparizione e autorizza fase combattimento con IA/bilanciamento delegati, due melee/morso, proiettili sempre innocui/schivate e racchetta. Implementazione e prove in [ANGELASTRI_COMBAT](ANGELASTRI_COMBAT.md); F7 salta direttamente alla passeggiata, poi avvicinamento/seconda cinematica/fight. Test isolati asset reali e regressione inventario passati. Le indicazioni sotto su combattimento ancora futuro descrivono le fasi storiche.

**Fase corrente evento:** utente approva la resa in mappa e autorizza contatore, terza uscita, regia mobile e faro, restituzione FPS/passeggiata. Correzione esplicita: prima performance verso camera TikTok immaginaria, non player; secondo dialogo rivolto al player. [Guida evento](ANGELASTRI_ENCOUNTER.md). Disabilitati i tasti aggiunti. Test dal checkpoint post-Bruno; combattimento e racchetta arma ancora fase successiva, uso solo dopo avvio fight.

**Passo corrente:** dialogo studio approvato «perfetto, da paura». Preparata [prova nella mappa](ANGELASTRI_MAP_PREVIEW.md) con F10 intro/quattro danze mobili, F11 discorso principale, F12 rimozione. Prima osservare questa resa, poi implementare dinamica dell'incontro. Le richieste di ulteriore approvazione studio sotto sono storiche.

**Dialogo senza tagli e finale combattimento:** utente richiede gesti completi/passaggi dolci e stabilità di posizione, secret 3 s prima, nuovo idle poi talk_to_combat. Preview principale programma i gesti cumulando durate reali e attende fine clip: niente interruzioni a metà, meno cambi. AnimationPlayer continuo con crossfade 0.55 s, senza seek/pausa per frame; sole copie private dei track bacino X/Z rese stazionarie nel dialogo, balletto non modificato. Secret a 44 s, clip completa 10.9 s e posa finale fino a fine voce. Fine dialogo → idle_new intero 8.3333 s → talk_to_combat intero 1.1667 s → combat_ready/segnale di handoff nella preview, nessuna AI ancora implementata. Idle_new_breathing (9.9333 s) verificata e conservata. Cue frasi precedenti frammentati superati; ascoltare nuova resa F6 prima mappa/combattimento.

**Nuove talking nel principale:** utente aggiunge talking/talking2/talking3/talking_secret alla scena ufficiale e richiede valutarle/usarle, secret SOLO nella voce bassa finale. Clip controllate GPU a 25%/65%: talking (3.9333 s, entrambe mani), talking2 (3.7667 s, una mano), talking3 (10.2667 s, gestualità ampia), talking_secret (10.9 s, inclinazione/mano vicina viso). Principale ora alterna le tre talking nelle spiegazioni/racconto, conserva pointing/angry/salute/risata, usa talking come continuità tra gesti invece di looking durante parlato. Secret solo finestra finale provvisoria 47–54 s, export main_secret_start/end; dopo 54 s talking3 per ultima frase e poi looking. Intro/balletto preservati; i tempi esatti voce bassa restano da confermare con ascolto utente.

**Prova corrente: discorso principale.** Utente approva canto articolato («funziona bene») e chiede prima preview completa del discorso, soltanto dopo balletto e sequenza nella mappa. Nuova `scenes/levels/angelastri_dialogue_test.tscn`: F8, aprire, F6 → voce/gesti/bocca automatici, poi looking. Riusa controller preview con preview_main_dialogue=true; vecchia intro/balletto approvata conservata nella sua scena. Gestualità iniziale da CUES[1] (looking, pointing, angry_point, talk_to_combat, risata, salute, pointing2, head_nod, opening); fra gesti finiti torna looking, risata attiva sorriso. Tempi BOZZA basati sul TXT, senza ascolto verificato/timestamp frasi: da correggere col riscontro, non sincronizzazione semantica definitiva.

**Vincolo successivo mappa:** balletto deve spostare Angelastri realmente nello spazio, come richiamato dall'utente; verificare traslazione/rotazione e continuità tra quattro clip, piedi/pavimento/ostacoli/camera e posizione finale. Camera preview che segue bacino non prova locomozione del CharacterBody in mappa; non congelare o ricentrare automaticamente gli spostamenti. Mappa resta attività successiva alla prova dialogo, non implementata qui.

**Bocca canto articolata:** dopo riscontro utente «non rimanere sempre aperta», preview aggiunge SingingArticulation locale dopo il controller RMS (priority 10). Dal cue 73.5 s modula apertura e forme con impulsi di articolazione stilizzati a circa 2.8 Hz e variazione lenta, interpolazione attacco/rilascio 0.03/0.045 s. RMS rimane ampiezza/limite e segue fade; ciclo raggiunge quasi chiusura anche col mix musicale continuo. Non riconosce sillabe reali né fonemi. Intro e componenti condivisi inalterati, pausa/stop/replay conservati. Test verifica escursione >0.15 e almeno tre chiusure in circa due secondi, non soltanto apertura.

**Seconda indicazione:** richiesta successiva utente «la seconda volta che usa pointing usa pointing2». Intro primo pointing a 12 s; alla fine della clip (3.6 s) parte pointing2, quindi default 15.6 s, poi opening a 18 s. Nessun loop pointing. Canto a 73.5 s musica conservato; riscontro complessivo F6 aperto.

**Canto durante balletto:** utente approva «PERFETTO» e indica ingresso voce nella musica a 1:13.5, cioè 73.5 s dal suo avvio. Preview singing_start_seconds=73.5: prima bocca chiusa sul balletto, poi RMS musica fino alla fine/fade. Stesso controller capture commuta dalla voce intro al player musica, bus invia a Music, niente doppia riproduzione; fine/replay ripristinano voce e bocca chiusa. Si segue il mix intero (anche strumenti), non isolamento vocale/fonemi o riconoscimento automatico: limite spiegato all'utente. Istante fornito dall'utente, non da ascolto agente.

**Ultima scelta utente:** ritardo danza 1.0 s (2 s giudicati troppi); idle riservato al combattimento, escluso dalla presentazione. Attesa musicale e post-balletto usano looking; dopo danza looking in loop sulla sola libreria privata, ingresso morbido 0.6 s e pausa/ripresa preservate. Nessuna alternanza verso idle. Fine musica/fade adeguata a 112.3 s dal suo avvio. Pointing a 12 s invariato. Headless test passato, nuova resa F6 da ricevere.

**Rifinitura dopo «bellissima»:** utente approva movimento/sequenza, richiede danza leggermente dopo attacco musicale, primo pointing più tardi e idle/looking più dolci. Defaults preview scelti per prova: dance_start_delay=2.0 s, intro_pointing_time=12.0 s (prima 11), rest_blend_seconds=0.6 s; export regolabili nel controller della stessa scena. Durante lead-in musicale idle, danze originali invariate; fade ultimo secondo, fine musica a 113.3 s dal suo avvio. Rest ora riproduce realmente idle in loop privato e looking con blend continuo in entrambe le direzioni; nessun seek/pausa per frame nel rest, pausa/ripresa esplicite preservate. Tempi da valutare audiovisivamente, non timestamp della frase/beat verificati.

**Correzione dopo prova utente:** corpo fermo riprodotto, blend congelato sotto pause rimosso dai passaggi audio-driven. Nuovo test confronta le ossa a tempi diversi per tutte quattro danze. Intro usa pointing nel tratto muro/contatori/asfalto (bozza 11–18 s); tempo esatto frase ancora da ascoltare/confermare. Le precedenti conferme tecniche basate su stadi/nome/tempo non provavano il movimento del corpo. Riprovare stessa scena F6, autoplay invariato.

**Traccia lunga prevalente:** utente sostituisce thriller.mp3 durante il lavoro: ora 125.410249 s (FFprobe), sufficiente per le quattro clip 111.3 s. Nessun loop necessario; musica continua una volta, fade tra 110.3 e 111.3 s, poi idle/looking. Preview legge i byte MP3 direttamente in AudioStreamMP3 privato: cache import Godot era ancora sul vecchio file di 91 s. Originale nuovo preservato. Note di loop sotto descrivono la variante precedente.

**Ultimo aggiornamento utente:** aggiunte thrller_3/thrller_4 nella scena ufficiale. Prova automatica ora intro → quattro danze 1/2/3/4 → idle/looking. Durate 29.8333 / 18.8333 / 25.5667 / 37.0667 s, totale 111.3 s. Thriller originale dura 91.0513 s: copia privata MP3 in loop nella sola sequenza per coprire ultimi 20.25 s, clock audio continuo che compensa il ritorno del playback al principio. Fade soltanto nell'ultimo secondo della quarta danza. Raccordo musicale da ascoltare/approvare; nessuna modifica asset o velocità clip. Le indicazioni sotto a due danze sono storiche.

**Prova automatica prevalente:** utente chiarisce che vuole osservare il primo pezzo completo senza comandare le clip. F6 sulla stessa scena avvia da solo intro/gesti/bocca → Thriller con thrller_1 poi thrller_2 sul medesimo audio continuo → fade nell'ultimo secondo → idle ciclico, looking ogni 10 s e ritorno idle. Pannello ridotto a rivedi/pausa/vista; Spazio mette in pausa. Le istruzioni manuali sotto sono storiche per la modalità avanzata (`automatic_preview=false`), usata dalla fixture. Tempi gesti intro ancora da affinare sul parlato; nessun discorso principale/combattimento avviato. Intervallo looking di 10 s scelto per questa prova, non parametro gameplay definitivo.

**Aggiornamento fase 1:** preview estesa con figura intera che segue il bacino, volto, rotazione/zoom/reset, tutte le 27 clip con durata, pausa/riavvio/seek/velocità su libreria privata. Audio reali completi selezionabili, Thriller su Music separato dalla bocca. Due danze una volta a velocità originale: 29.8333 + 18.8333 = 48.6667 s, clock audio comune e dissolvenza finale di 1 s; il resto dei 91 s musicali non viene usato nella sequenza. Dialoghi con prima bozza di gesti, basata sui TXT senza timestamp: tempi NON confermati dal parlato. Cue aggiungibili/sostituibili nella preview, solo RAM, stampati nell'Output come ANGELASTRI_DRAFT_CUES. Nessuna integrazione mappa. Validazione tecnica passata; ascolto e visione continua utente ancora necessari prima di chiudere la fase.

F8 → `scenes/levels/angelastri_mouth_test.tscn` → F6. Scegli Intro/Discorso/Risata e premi «Dialogo + gesti / Balletto + Thriller»; scegli Thriller per le due danze. «Avvia audio» ascolta soltanto. F cambia volto/figura intera, destro ruota, rotella zoom; clip singole nel menu. Il pulsante trascrizione legge i TXT reali. Per modificare un gesto seleziona clip e secondo, poi aggiungi/sostituisci cue e riavvia la sequenza. Annotare i cue prima di chiudere: non sono salvati su disco.

L'utente ha approvato bocca e denti V2 («ok perfetta») e richiesto l'evento, le cinematiche e il combattimento descritti sotto. Ha poi scelto esplicitamente di procedere **per fasi: prima modello e animazioni, poi cinematiche sincronizzate, infine combattimento**. Questa sessione salva il contesto; non implementa queste nuove fasi.

**Primo lavoro della nuova sessione: realizzare soltanto la fase 1**, nella preview isolata già esistente. Non chiedere nuovamente quale obiettivo scegliere. Leggere prima i documenti di continuità indicati in AGENTS, questa guida, ANGELASTRI_MOUTH e architettura/procedura di test. Leggere integralmente script coinvolti e parti pertinenti delle scene prima delle modifiche.

Baseline locale verificata alla chiusura: workspace `D:/ProjectBlob/Game`, branch `dev/prototype-0.1`, HEAD `2ac4a5fb0953e633915ed862b7942ec3d86771c5`, staging vuoto. Molte differenze locali preesistenti, incluse eliminazioni SilverDelivery e asset non tracciati/ignorati: conservarle e confrontare locale/Git alla ripresa. Nessun commit/push autorizzato. Git non costituisce backup degli asset non tracciati o ignorati. Non ripristinare la scena Angelastri o il player da vecchie copie: l'utente li ha salvati successivamente con nuove animazioni e RacketSocket.

## Stato verificato e risorse reali

- Modello ufficiale `assets/models/enemies/Angelastri/sgt_Angelastri.glb`, scena `scenes/enemies/angelastri.tscn`. Non rinominare secondo le grafie iniziali della chat.
- Testa attiva `assets/models/enemies/Angelastri/mouth_preview_v2/angelastri_head_mouth.glb`; solo arcata superiore rialzata 1.2 mm. Prima variante conservata. Componente `scripts/characters/angelastri_mouth.gd`, nodo MouthPresentation, mesh `sgt_Angelastri/Armature/GeneralSkeleton/mixamorig_Neck/Testa`. Voce opzionale tramite `bind_voice`; riuso BrunoMouthMotion RMS, non riconoscimento fonemi. Corpo/rig/originale preservati. Nessun altro ritocco estetico richiesto.
- Preview `scenes/levels/angelastri_mouth_test.tscn`, controller `scripts/debug/angelastri_mouth_preview.gd`; F8, aprire scena, F6. Attualmente primo piano, selezione clip, manuale M/slider, forme 3/4, viste 1/2, confronto O; Spazio usa ancora voce Bruno provvisoria limitata a 12 s, solo nella preview.
- Test `scripts/tests/angelastri_mouth_test.gd`: le precedenti verifiche bocca GPU/headless sono passate; il conteggio fisso di 26 animazioni è ora obsoleto. Non interpretare quel futuro fallimento come regressione della mesh.
- Nella scena attuale sono caricate 27 clip della libreria `mie/`, più `Armature|mixamo_com|Layer0` e `mixamo_com`: 29 complessive. Verificata la caricabilità, **non ancora la resa visiva di tutte le clip**.

Nomi esatti delle 27 clip, tutti con prefisso `mie/`:

`angry_point`, `bite_neck`, `button`, `caduta`, `death`, `dodging`, `dodging_right`, `ducking`, `head_nod`, `hit_reaction1`, `hit_reaction2`, `idle`, `looking`, `opening`, `pointing`, `pointing2`, `quick_bow`, `risata`, `running`, `salute`, `scream`, `talk_to_combat`, `thrller_1`, `thrller_2`, `walking`, `zombie_attack1`, `zombie_attack2`.

Le grafie **thrller_1/thrller_2** sono effettive, non thriller1/thriller2. Risorse sotto `assets/models/enemies/Angelastri/Animation`. Leggere le durate dal runtime, senza inventare lunghezze o assumere che coprano tutta la musica.

Quattro audio effettivi, tutti sotto **assets/models/enemies/Angelastri/**, non assets/audio:

| File | Durata precedentemente misurata | Impiego richiesto |
|---|---|---|
| Angelastri_intro_vampire.mp3 | 20.827729 s | Prima introduzione prima del balletto |
| Angelastri_discorso_principale_vampire.mp3 | 56.850604 s | Presentazione prima del combattimento |
| thriller.mp3 | 91.051293 s | Balletto, poi dissolvenza |
| risata_vampire.mp3 | Non misurata | Risate lontane durante l'evento |

Non è stato verificato l'ascolto semantico dei dialoghi: non dichiarare di averli ascoltati. Per associare gesti alle frasi servono ascolto verificabile oppure trascrizione con riferimenti temporali. RMS può muovere la bocca senza questa informazione.

Player salvato: `scenes/player/player.tscn`, BoneAttachment3D `Head/Camera3D/WeaponHolder/LowWorldViewModel/smesh_arms_male/rig_arms/Skeleton3D/RacketSocket`, bone `Hand.R`, indice 23; figlio `Racket_Wilson_Blade`. Preservare transform utente. Collocazione strutturale verificata; presa/posa in movimento ancora da verificare.

## Fase 1 — modello, animazioni e anteprima audio

- Estendere la preview esistente, senza creare eventi nella mappa o AI. Default a figura intera, modalità primo piano, rotazione/zoom e reset dell'inquadratura; mantenere bocca V2 e confronto originale.
- Elencare automaticamente tutte le clip mie, nome esatto e durata. Aggiungere riproduzione/pausa, riavvio, posizione temporale e velocità. Qualsiasi modifica al loop avviene su copie private della libreria, mai sulle risorse originali.
- Sostituire la voce provvisoria Bruno con selezione intro/discorso/risata reali, riproduzione completa e bocca RMS. Niente autoplay. Thriller ascoltabile separatamente sul bus musica, senza pilotare la bocca.
- Aggiungere prova `mie/thrller_1` → `mie/thrller_2`, una volta a velocità originale; osservare transizione e durate. Sincronizzazione musicale definitiva nella fase 2.
- Aggiornare il test eliminando il vincolo storico 26; controllare libreria disponibile, bocca/materiali, audio/pausa/stop e rilascio bus. Verificare tutte le clip visivamente, soprattutto piedi, deformazioni, gesti, schivate, duck, morso, attacchi e balletti. Test statici o smoke test non equivalgono a playtest.
- Registrare risultati, limiti e riscontro utente. Completare questa fase prima di integrare cinematiche. Non modificare controller Bruno, armi, HUD o mappa per la preview.

## Fase 2 — evento e cinematiche concordate

1. Prima connessione del Fritz con **un cavo verso PC oppure switch** arma l'evento, una sola volta. Risate lontane intermittenti; dopo un'attesa casuale stacco della corrente al contatore, spegnendo tutti i dispositivi dipendenti.
2. **Primi due blackout:** uscita dal laboratorio, soltanto quadro dei contatori aperto; Angelastri assente. Il giocatore può ripristinare la corrente. Il blackout successivo si arma solo dopo ripristino **e rientro effettivo nel laboratorio**, poi breve attesa; non mentre è ancora fuori.
3. **Terza uscita:** Angelastri vicino ai contatori, sportelli aperti. Attraversamento della soglia del lab verso fuori avvia la cinematica, telecamera verso contatori/Angelastri. Intro parlata con Angelastri_intro_vampire; poi Thriller con thrller_1 e thrller_2 di seguito. Musica sfuma al termine, idle poi looking, controllo restituito.
4. Avvicinandosi, quando Angelastri **vede realmente** il giocatore, nuova cinematica verso il nemico: discorso principale, gesti disponibili sincronizzati alle frasi. Alla fine parte il combattimento.

Dettagli da definire nella fase 2, non blocchi per la fase 1: intervalli casuali/raggio risate, durata breve attesa dopo rientro, geometria della soglia, tempi musicali effettivi, cue dei dialoghi, distanza/FOV/linea di vista. Non scegliere questi parametri fingendo che siano già concordati.

Punti d'integrazione verificati: `scripts/interactables/connesi_power.gd` espone power_changed(bool), is_power_on, turn_on/turn_off. Usare il sistema esistente invece di spegnere arbitrariamente nodi. Quadro sotto `connesi_building_test2/ContatoriSx`, sportelli `Contatori_Sx_SportelloDx` e `Contatori_Sx_SportelloSx`; verificarne gerarchia e coordinate prima dell'intervento. Porta esterna lab `connesi_building_test2/Porta Lab Esterna `, con spazio finale. Distinguere attraversamento verso fuori da semplice body_entered.

Controller Angelastri separato: consultare integralmente `scripts/cinematics/bruno_intro_controller.gd` per i contratti di camera/input/HUD, senza riscriverlo. Persistenza futura: conteggio blackout, rientro/riarmo, avanzamento e completamento presentazioni, stato nemico; restore non deve ripetere intro o blackout già consumati. Gestire pausa/morte/cambio scena e impedire salvataggi nei momenti non ripristinabili, preservando i contratti SaveManager.

## Fase 3 — combattimento e racchetta concordati

- Una sola fase zombie; usare movimento e attacchi esistenti, schivate dodging/dodging_right e ducking. Diversi attacchi, incluso bite_neck da vicino: player bloccato per tutta l'animazione, con rilascio sicuro anche su interruzioni.
- Proiettili senza danno. Solo corpo a corpo danneggia: mani nude o racchetta usata come clava con portata maggiore. Distinguere esplicitamente danno da proiettile e melee; il weapon attuale usa take_bullet_hit con fallback take_damage e melee take_damage, quindi non rendere immune anche il melee per errore.
- Inventario racchetta: «Usa come arma», equipaggiamento su RacketSocket; «Riponi» dal menu I; tasti 1–4 cambiano arma e ripongono. Dal primo utilizzo come arma, tasto 5 riequipaggia; rispettare possesso e persistenza.
- Preservare enum/slot storici armi 0–3 e compatibilità dei vecchi salvataggi. Rileggere integralmente weapon.gd, player, UI inventario e adattatori salvataggi prima di scegliere l'estensione. RacketSocket e modello già presenti non significano che il sistema arma sia già implementato.
- Da definire nella fase 3: HP/danni, tempi/raggi attacchi, probabilità/cooldown schivata, reazioni, sconfitta/drop e ripristino post-combattimento. Non implementare questi dettagli nella fase 1.

## Vincoli e chiusura

Audio regia, sliding_door alle scorrevoli, testo «allo switch», bocca Bruno e bocca Angelastri approvati: preservarli. Intervento mirato → verifica → consolidamento. Mappa molto pesante: test in sequenza, non istanze concorrenti. Usare slot di fixture, mai sovrascrivere salvataggi utente. Nessuna nuova dipendenza da file .godot temporanei. Aggiornare stato/backlog/architettura/registro a ogni fase; nessun staging/commit/push senza richiesta.
