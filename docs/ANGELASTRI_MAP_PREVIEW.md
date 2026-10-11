# Angelastri — prova nella mappa

**Questa guida è storica:** dopo approvazione della preview è attivo l'[evento automatico contatore/terza uscita](ANGELASTRI_ENCOUNTER.md). F10/F11/F12 sono ora disabilitati su richiesta dell'utente; seguire la nuova guida dal checkpoint post-Bruno.

**Seconda sorgente sottofondo:** vengono sospese sia BackgroundMusic sia AudioManager/MenuMusic (autoplay anche con F6). Stati di pausa precedenti ripristinati a fine presentazione/rimozione; Thriller indipendente resta attiva. Test headless entrambe le sorgenti passato, nuova conferma sonora aperta.

**Revisione marker/audio:** lo spawn ora usa il nodo 3D chiamato esattamente `Angelastri`, cercato nella scena, e si orienta verso il player anche con F10. Salvare il marker nell'editor: se manca, notifica senza comparsa. La vecchia posizione numerica sotto è storica. BackgroundMusic viene sospesa durante la presentazione e ripristinata a fine sequenza/F12/morte/restore; Thriller resta udibile perché non viene silenziato il bus Music. Percorso e visibilità dalla nuova posizione richiedono nuova prova.

Aprire `scenes/maps/map_test.tscn` nell'editor e premere F6 (F8 ferma una prova precedente). Raggiungere il piazzale davanti ai contatori dell'edificio Connesi.

- **F10:** fa apparire Angelastri e avvia automaticamente intro, musica e quattro danze consecutive. Ripremere riavvia dalla posizione iniziale.
- **F11:** avvia il discorso principale dalla posizione attuale di Angelastri, rivolto al giocatore; se assente, lo crea nel punto di prova. Finale secret → idle_new → talk_to_combat → handoff, senza attivare combattimento.
- **F12:** rimuove Angelastri e interrompe la prova.

F9 resta assegnato a Bruno. Il giocatore conserva movimento, visuale e pausa: può girare attorno al personaggio durante la presentazione. Non serve premere tasti per avanzare intro o singole danze.

Spawn relativo a `connesi_building_test2/ContatoriSx`: `(-0.5, 0, 4.5)` metri, appoggiato al terreno tramite raycast; orientamento iniziale +X lungo il piazzale. L'arretramento rispetto ai contatori lascia libera tutta la traiettoria, evitando cabina e arredi. Il percorso è ricavato dal bacino originale delle quattro clip, con offset cumulativi: il nodo del modello si sposta realmente, senza tornare allo spawn a ogni clip. Altezza adattata al terreno. Copie esplicite delle Animation proteggono le risorse originali.

Controller della mappa: `scripts/debug/angelastri_map_preview.gd`; presentazione condivisa con le prove studio: `scripts/debug/angelastri_mouth_preview.gd`, modalità `map_presentation`. Nessuna camera, ambiente o UI dello studio viene aggiunta alla mappa. Il personaggio è una presentazione di debug, senza corpo fisico, AI, trigger blackout o persistenza; rimozione anche dopo morte/caricamento. Bocca, tempi, musica e gesti approvati sono condivisi.

Verifica: `scripts/tests/angelastri_map_preview_test.gd` in Forward+ D3D12, audio Dummy. Controlla comandi, camera/input FPS, movimento e continuità tra clip, ostacoli, avvio secondo dialogo nella posizione finale, pausa, cleanup audio, assenza di persistenza e stato Bruno invariato. Screenshot in `.godot/angelastri_map_*.png`. Modalità `-- --survey` confronta candidate con pavimento, capsule e aree fuoco/fumo. Sono controlli automatici e immagini, non ascolto o playtest manuale dell'effetto completo.

Esito automatico finale: failures=0, nessun ostacolo su 400 campioni; estensione percorso 8.27 × 2.13 m, variazione terreno 0.20 m. Survey del punto finale senza contatti con aree fuoco/fumo. L'illuminazione resta quella della mappa; screenshot iniziale dalla camera di test coperto dal camion, secondo dialogo visibile. Valutare manualmente dalla visuale FPS avvicinandosi ai contatori.

Prossimo passo: valutare la resa audiovisiva nella mappa e rifinire posizione/orientamento se richiesto; solo dopo integrare la dinamica effettiva dell'incontro.
