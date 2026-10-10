# Project Blob — documentazione di continuità

Preparata l'8 ottobre 2026 dal PDF e dall'ispezione locale. Serve a riprendere il lavoro distinguendo baseline Git, working directory e test storici.

## Da dove ricominciare

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
