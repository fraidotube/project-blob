# Project Blob — istruzioni di continuità

## Prima di lavorare

Leggere [l'indice](docs/README.md), [la baseline SAFE](docs/BASELINE_SAFE_2026-10-08.md), [gli standard tecnici](docs/PROJECT_BLOB_STANDARDS.md), [lo stato locale](docs/CURRENT_STATE.md), [decisioni e backlog](docs/DECISIONS_AND_BACKLOG.md) e l'ultima voce del [registro sessioni](docs/SESSION_LOG.md). Consultare poi architettura e procedura di test per il sottosistema coinvolto.

I documenti conservano il contesto e non autorizzano nuove attività di gameplay. Definire con l'utente un obiettivo concreto; una richiesta esplicita vale come scelta dell'obiettivo, senza domandarla di nuovo.

## Contratto SAFE

- Verificare branch, HEAD, stato Git e file locali reali prima di interventi rilevanti. Non assumere che il remoto descriva la working directory.
- Leggere integralmente gli script e le parti pertinenti delle scene prima di modificarli. Se locale e baseline Git differiscono, fermare la modifica e confrontare le versioni prima di intervenire; non sovrascrivere il lavoro locale.
- Una modifica mirata alla volta: diagnosi → intervento → test → consolidamento. Non riscrivere arbitrariamente i controller estesi di Bruno, armi, cinematica o HUD.
- Conservare player/FPS, HUD, porte, interazioni, pickup, pistola, SMG, torcia, audio, VFX, AI, boss, cinematica e ambiente. Preservare geometria visiva, metadati e gruppi funzionali durante ottimizzazioni fisiche.
- Non inventare nomi, nodi, path, API, animazioni o segnali. Verificarli nei file; dichiarare ciò che non è verificato.
- Non usare PowerShell/Python per patch automatiche ai file del progetto. Se si consegna uno script `.gd`, fornire il file completo, senza frammenti da incollare.
- Mai `git add .` o `git add -A`. Staging solo su path espliciti concordati e controllo di `git diff --cached`.
- Nessun commit o push autonomo. Una baseline significa identificare e documentare lo stato ripristinabile; crearne un commit richiede richiesta dell'utente.
- Non includere asset commerciali nel repository senza verifica della licenza. Git non salva automaticamente asset locali non tracciati o ignorati.
- Un controllo statico non equivale a un playtest. Le conferme storiche non dimostrano il funzionamento di nuove modifiche.

## Configurazione e manutenzione dall'Inspector

- Regola approvata dall'utente il17/10/2026: i nuovi componenti configurabili devono esporre nell'Inspector i parametri di tuning e i collegamenti necessari al lavoro sulla scena, con gruppi chiari, descrizioni `##`, unita e intervalli sensati. Non esporre indiscriminatamente lo stato interno runtime.
- Estensione esplicita dello stesso giorno: la regola vale in generale per tutti gli script di gameplay, in particolare player, armi, salute/energia, dotazione allo spawn e altri valori importanti. Conservare i valori attuali e distinguere le impostazioni iniziali dallo stato dei checkpoint; nessuna dotazione iniziale va riassegnata durante un caricamento. I valori nativi gia' disponibili sui nodi (luci, raggi, camera, audio) vanno documentati senza duplicarli inutilmente negli script.
- Evitare configurazioni di gameplay nascoste in tabelle rigide nello script quando devono essere modificate dal designer: usare nodi/componenti o risorse serializzate nella scena. Documentare quale nodo selezionare e come duplicarlo.
- Gli ID di salvataggio devono essere unici e stabili; segnalare riferimenti mancanti o duplicati. Preservare ID e valori approvati durante le migrazioni.
- Gli strumenti `@tool` devono essere innocui nell'editor: nessuna riparentazione, costruzione fisica o modifica distruttiva degli asset durante l'editing. Verificare almeno serializzazione e applicazione runtime dei parametri modificabili.
- Applicare la regola ai prossimi sviluppi e ai componenti toccati; non usarla come autorizzazione a riscrivere i sistemi storici fuori dall'obiettivo richiesto. Vedere [la guida Inspector](docs/INSPECTOR_CONFIGURATION.md).

## Fine sessione

Aggiornare `docs/SESSION_LOG.md` con attività, file, verifiche, limiti e prossimo passo. Aggiornare stato, backlog e architettura dove cambiano. Non alterare retroattivamente la baseline storica. Seguire [la procedura](docs/WORKFLOW_AND_TESTING.md).

Le istruzioni esplicite dell'utente prevalgono sulle procedure locali. Non introdurre approvazioni ulteriori per azioni già autorizzate.
