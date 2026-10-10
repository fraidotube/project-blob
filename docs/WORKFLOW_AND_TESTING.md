# Project Blob — procedura di lavoro e verifiche

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
