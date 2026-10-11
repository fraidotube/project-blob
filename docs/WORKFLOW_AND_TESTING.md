# Project Blob — procedura di lavoro e verifiche

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

- Riassumere cambiamento, motivo, prove e limiti; distinguere statico/runtime/storico.
- Aggiornare registro, stato, backlog e architettura dove necessario; baseline storica inalterata.
- Indicare file e prossimo passo. Non dichiarare completamento quando mancano i test necessari.
- Per documentazione: completezza fonte, link e diff; non occorre playtest.
- Commit/push separati dal completamento tecnico e subordinati alla richiesta utente.
