# Regia — effetti audio e sincronizzazione

Implementazione locale 11/10/2026, richiesta esplicita dell'utente di collegare gli effetti inseriti in `assets/audio/edificio`. Originali conservati; estratti in `assets/audio/edificio/gameplay`. Verificati decodifica, durata, silenzi e livello mediante FFmpeg/ffprobe, e riproduzione PCM nel motore. **Non effettuato ascolto diretto dall'agente:** timbro e bilanciamento finale richiedono prova utente.

## Associazioni

| Evento | Originale | Estratto / trattamento | Momento |
|---|---|---|---|
| Pulsante alieno, compreso reset | button_digital.mp3 | Originale 0.096 s | Pressione effettiva, anche senza rete |
| Sblocco alieno | apertura_porta_electric.mp3 | door_unlock.mp3, 8.30–9.10 s, +16 dB, fade finale 0.12 s | Primo passaggio LED verde / codice corretto |
| Apertura uscita aliena | apri_porta.mp3 | door_open.mp3, primi 1.30 s, −9 dB, fade finale 0.10 s | Inizio battente, dopo eventuale arretramento |
| Chiusura uscita aliena | porta_chiusa_metallo.mp3 | door_close.mp3, 0.44–1.00 s, −9 dB | Battuta reale, soglia angolo 0.6° già presente |
| Mouse portatile | mouse_click.mp3 | gameplay/mouse_click.mp3, 0.14–0.30 s, +2 dB | Pressione sinistra dentro schermo attivo |
| Tastiera portatile | tastiera_click.mp3 | keyboard_click.mp3, 0.05–0.28 s, −12 dB | Input nei campi attivi, inclusi Invio/cancellazione |
| Cavo Ethernet / caricatore | cable_connect.mp3 | gameplay/cable_connect.mp3, 0.045–0.265 s, +2 dB | Ethernet alla fine posa 0.6 s; caricatore alla comparsa immediata |
| Sfoglia libro | flip_page.mp3 | page_turn.mp3, da 0.10 s, atempo 1.2, durata uscita 0.60 s, +2 dB | Inizio tween pagina 0.6 s |
| Scorrevoli laboratorio e bagno regia | sliding_door.mp3 | sliding_motion.mp3, da 0.15 s per 2.18 s, +3 dB | Inizio apertura/chiusura, stop all'arrivo del pannello |

Scorrevoli: il nuovo effetto è assegnato a entrambe le porte della mappa tramite RegiaIntegration. Movimento e velocità conservati; la riproduzione termina quando termina lo scorrimento e viene fermata al restore. SFX spaziale limitato a 12 m. Menu cavi corretto in «Collega allo switch» / «Scollega dallo switch».

L'estratto elettrico è scelto dalla porzione con segnale più evidente di un file di 11.832 s e picco originale −22.6 dB; non è una scelta confermata all'ascolto. È sostituibile senza cambiare le regole del puzzle.

## Implementazione

`regia_audio.gd` carica e conserva gli AudioStreamMP3; usa risorse importate quando disponibili e dati MP3 locali prima dell'import. Quattro player riutilizzabili per tipo, per limitare sovrapposizioni della digitazione; pool liberato con il proprietario. Nessun bus nuovo nel gioco: SFX, livelli SettingsManager conservati. Mouse/tastiera/pagine in 2D nella vista ravvicinata; bip/sblocco/cavi in 3D dal rispettivo oggetto. Porta riusa DoorAudio SFX spaziale esistente; script base door.gd invariato, nuovi stream solo all'uscita aliena.

Nessun effetto ripetuto al restore o alla ricostruzione delle mesh. Il suono del cavo viene emesso dal callback finale del tween solo se il collegamento è ancora presente. Caricatore emesso solo dall'interazione riuscita che cambia connected false→true. Pausa normale sospende gli effetti; pausa intenzionale di PC/libro mantiene audio dei comandi. Nessun beep su indice invalido o tastiera già sbloccata. Modifiche programmatiche ai campi non producono digitazione. Chiudere il libro libera anche il suono/tween con il pannello.

Gli estratti si rigenerano con FFmpeg: `ffmpeg -ss INIZIO -i ORIGINALE -t DURATA_USCITA -af FILTRI -codec:a libmp3lame -b:a 128k DESTINAZIONE`. Per lo sfoglio `-t 0.60` limita l'uscita dopo `atempo=1.2`. Conservare gli originali. Nessuna build/export verificata: conservare nel pacchetto tutti gli MP3 e le risorse/import necessari.

## Verifiche e prova

Esiti finali 11/10: `REGIA_AUDIO_TEST failures=0`, capture 4096 frame con picco 0.549139; `REGIA_NETWORK_MAP_TEST failures=0` headless e poi GPU Forward+ D3D12 RTX4060 con le nuove asserzioni di sincronizzazione. Log regia_audio_test/regia_audio_map_test/regia_audio_gpu_map in `.godot`. Restano messaggi storici certificati/SparksElectric e, all'uscita del test dedicato, 7 ObjectDB/2 risorse: esiti funzionali distinti da pulizia globale. Prova sonora utente aperta.

`regia_audio_test.gd` verifica stream brevi decodificabili, clic sullo schermo/fuori/rilascio, digitazione reale focalizzata e modifica programmatica silenziosa, bip senza WiFi, indici invalidi/sbloccato, audio all'inizio sfoglio e nessun doppio suono durante tween, restore silenzioso, pool limitato, pausa/ripresa. Capture temporaneo sul bus SFX conferma campioni PCM non nulli, rimosso a fine test. Non modifica impostazioni o slot utente.

`regia_network_map_test.gd` verifica assegnazione stream porta, dodici bip ai clic fisici, caricatore unico, clic cavo al termine tween, sblocco unico, chiusura a battuta, nessuna apertura sonora prima dell'arretramento, ripristino silenzioso; conserva controlli puzzle/porta/passaggi/kit/save. Suite mappa in sequenza.

F8 → map_test → F6 con audio attivo: ascoltare bip, reset, sblocco, apertura/chiusura, Ethernet/caricatore, Chrome/campi e sfoglio. Provare digitazione rapida, Esc, pausa/ripresa e Carica: nessun suono di collegamento/sblocco al ripristino. Valutare soprattutto estratto elettrico e bilanciamento con ambiente/Bruno. Risultati tecnici aggiornati in SESSION_LOG; gradimento audio utente ancora aperto.
