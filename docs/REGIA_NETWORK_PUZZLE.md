# Regia — puzzle Fritz, portatile e chiusura aliena

**Audio 11/10/2026:** effetti utente collegati con estratti dedicati, originali conservati. Bip alla pressione, sblocco al codice corretto, apertura dopo arretramento, chiusura a battuta; mouse/input PC, cavo a fine posa, caricatore al collegamento, sfoglio durante tween. [File, tempi, test e limiti](REGIA_AUDIO.md). Nessun effetto replay al restore; bilanciamento/timbro da confermare in prova sonora.

**Conferma/rifiniture 11/10/2026:** utente «tutto perfetto» per la revisione precedente e, dopo il nuovo playtest in mappa, «ok funziona tutto». Portatile ridotto del 16%; Fritz alimentato visivamente da una scatolina bianca/grigia sulla ciabatta, con cavo curvo alla presa DC originale: prop fisso distinto dal caricatore raccoglibile del PC. Uscita aliena verso l'interno della regia sul cardine destro visto dalla chiusura. Apertura con player vicino sul lato regia: arretra fisicamente prima del battente; nessuno spostamento dal lato opposto. Se il percorso dietro al player è ostruito, la porta rimane chiusa; pausa interrompe temporaneamente il movimento. Sblocco permanente e chiusura agganciata preservati. Scorrevole: «Serve una chiave.».

Questa è la resa e il comportamento attualmente confermati dall'utente. Le note precedenti in questa guida spiegano la cronologia; non sono richieste aperte, salvo la prova del ciclo di salvataggio.

**Ridimensionare la chiusura:** modificare la Scale uniforme del nodo `Porta Regia Chiusura` nell'editor e riavviare F8/F6: monitor, dodici tasti, LED e clic seguono la trasformazione; ora anche lo zoom si adegua. Non applicare la scala ai vertici in Blender e non cambiare origine/geometria aspettandosi che le coordinate locali dei montaggi restino valide: in quel caso serve verificarle/riallinearle. La chiusura non è stata ridimensionata in questa sessione; verificata una scala 0.75 soltanto nella fixture di test.

Implementazione locale autorizzata con «Implement the plan», 10/10/2026. Utente dopo il playtest: «funziona la logica», con richiesta di revisione visiva. Revisione implementata, nuova resa ancora da approvare. Nessun commit/push. Il precedente blocco Bruno non si ripresenta secondo l'utente: riaffrontarlo solo in caso di ricorrenza.

**Ultima revisione dopo «molto meglio»:** display portatile grande quanto monitor PC, rivolto alla sedia; rete SX e alimentazione DX. Caricatore raccoglibile/installabile, kit recuperabile dopo arresto a enigma risolto. Tutti i cinque item hanno icona ed esame 3D, descrizioni neutre. Libro/quaderno 3D aperti; libro sfogliabile fino al solo simbolo WiFi, senza spiegazione del cerchio o della password. Questa nota prevale sulle descrizioni storiche dei collegamenti.

## Istruzioni di consegna per la prossima sessione

Salvate su richiesta dell'utente dopo un crash della finestra e conservate per continuità. Ultimo playtest in mappa confermato dall'utente: «ok funziona tutto». La nuova resa e i comportamenti descritti nella voce 11/10 sono confermati; non ripeterne l'implementazione. Il ciclo manuale completo del sistema di salvataggio resta una verifica separata.

**Ripresa prossima sessione:** leggere CURRENT_STATE e ultima voce SESSION_LOG, verificare Git/file locali, preservare tutte le modifiche locali e chiedere quale nuovo obiettivo gameplay affrontare se non è già indicato. Prima di avviare qualunque nuova suite mappa, assicurarsi che l'editor e le prove siano in condizioni normali; eseguire al massimo una suite mappa per volta.

**Avvio della prova:** F8 per fermare l'esecuzione, aprire `scenes/maps/map_test.tscn`, quindi F6. Seguire la sequenza sotto. E interagisce, I apre l'inventario, Esc esce dalla postazione o dall'esame. Inventario → oggetto → Esamina; sinistro ruota, destro sposta, rotella zoom. La chiusura aliena deve restare agganciata alla porta sbloccata e le aperture successive non devono richiedere la password.

**Prova completa del salvataggio nella mappa:** usare il PC ConnesiOS di salvataggio (distinto dal portatile del puzzle), salvare in uno stato intermedio e annotare inventario, cavi, PC, configurazione, luci e porta. Cambiare lo stato, poi verificare Carica da pausa e Carica dal menu. Verificare morte con C per ripristinare e morte con N per ricominciare conservando il file di salvataggio. Infine chiudere il gioco, riavviarlo dal menu principale con F5 e scegliere Carica: deve tornare lo stato salvato. Ripetere il confronto anche dopo lo sblocco definitivo della porta. Non confondere i test automatici già passati con questa conferma manuale ancora aperta.

Il crash della finestra riferito nell'ultima richiesta non è stato investigato; quale finestra e causa restano ignoti. I precedenti crash dei test concorrenti per memoria sono un episodio documentato separato: eseguire una sola suite mappa alla volta. Preservare bocca Bruno, porte già approvate, immagini menu e caricamento. Nessun commit o push autorizzato.

## Provare nella mappa

Fermare il gioco con F8, aprire `scenes/maps/map_test.tscn` e riavviare F6. Il puzzle è collegato solo quando è presente l'addon dell'edificio.

1. Completare Bruno. Raccogliere chiave e racchetta con E: entrambe sono disponibili soltanto alla morte finale. I → Racchetta → Esamina: sinistro ruota, destro sposta, rotella zoom; trovare i quattro simboli sul manico. Esc torna all'inventario, poi al gioco.
2. E sugli appunti vicino al pulpito apre un quaderno 3D con annotazioni a penna PPPoE `narcisolo/ottavonano` e login `admin/admin2026`. E sul libro in regia mostra pagine aliene: sfogliare con frecce/rotella fino alla terza apertura per vedere il simbolo WiFi. Nessuna spiegazione sul cerchio/password. Esc chiude. Non è necessario aver letto un documento per inserire credenziali già note.
3. Recuperare il portatile dal corridoio. L'inventario segnala batteria scarica senza rivelare la posizione del caricatore. In regia, E sul rettangolo viola della scrivania sinistra vicino al Fritz deposita il PC, distinto dal PC ConnesiOS.
4. E sul caricatore originale sotto la scrivania lo raccoglie nell'inventario. E sul PC depositato apre il coperchio e, se posseduto, monta il caricatore consumando l'item: scatolina nera sul tavolo con due cavi verso ciabatta e lato DX del PC. Senza caricatore compare PC scarico, senza zoom; se raccolto in seguito, E sul PC aperto lo collega. Serve corrente Connesi. E successivo accende, poi E attiva lo zoom. Esc restituisce camera/HUD/input.
5. Prendere dalla scatola uno o due cavi. Il limite è due totali, non due per visita. E sul Fritz non collegato o sullo switch propone PC/switch. Con un cavo già collegato, E sul Fritz zooma dall'alto: leggere la legenda originale della mesh e usare Collegamenti per aggiungere/togliere cavi oppure Esc per uscire. Il PC deve essere depositato prima di collegarlo.
6. Dal desktop Windows 10 simulato aprire Chrome. Senza collegamento PC–Fritz e corrente il browser mostra un errore. Digitando i primi numeri di `192.168.178.1` compare il suggerimento; Vai/Invio completa l'indirizzo. Altri indirizzi restano non raggiungibili: non esiste traffico Internet reale.
7. Login admin/admin2026 → Internet/PPPoE. Inserire narcisolo/ottavonano e applicare. Online arriva dopo 3 s solo con uplink Fritz–switch e corrente; configurazione memorizzata anche se l'uplink manca.
8. Scheda WiFi: attivare la radio, disabilitare protezione/password, applicare. Nome rete FRITZ!Box Regia. Il cavo del PC serve per configurare; una volta configurato il router può essere scollegato dal PC.
9. Senza rete pronta, la chiusura mantiene LED rossi e ogni tasto fa lampeggiare l'icona WiFi. Quando PPPoE, switch e WiFi aperto sono operativi, connessione blu/apertura rossa. E zooma su monitor e dodici tasti; cliccare quattro simboli, verifica automatica al quarto. Il pulsante inferiore con iscrizione aliena svuota l'inserimento; codice errato azzera senza penalità. Nessun testo italiano sul display alieno.
10. Codice corretto: apertura verde, ritorno al player e battente aperto. **La chiusura resta visibile e agganciata alla porta**, seguendone apertura/chiusura. E successivi aprono/chiudono normalmente, senza password; perdita di corrente/rete non annulla lo sblocco.

11. Tornare al portatile: Start → Arresta il sistema. Prima dello sblocco risponde «Ancora mi serve, non posso spegnerlo.»; dopo chiude il coperchio e torna automaticamente al player. E sul PC chiuso offre RACCOGLI: PC e caricatore entrano insieme nell'inventario, il cavo PC viene recuperato se collegato. Router/uplink e porta sbloccata conservati. E sul vecchio punto di deposito risponde «Non c'è più bisogno ora.» e non consuma gli oggetti.

Inventario: I → scegliere uno dei cinque oggetti → ESAMINA. Sinistro ruota, destro sposta, rotella zoom; Esc torna all'inventario. Icone native per ogni item, comprese le notifiche; chiave/cavo/caricatore ispezionabili anche nella demo. Portatile e racchetta usano le copie visuali della mappa.

I due interruttori separati governano corridoio e regia, dipendendo dal contatore. Fritz, switch e caricatore richiedono corrente aziendale; chiusura aliena autonoma. Bordo viola `#b86cff` per tutti gli oggetti del puzzle, usando il sistema E/outline esistente.

## Nodi e geometria

L'addon importato contiene `Portatile Regia`, `Caricatore PC`, `Notebook`, `LibroRegia`, `Scatola Cavi`, `Switch Regia`, `Porta Regia Chiusura` e i due interruttori. Fritz è nell'edificio principale. Nome runtime dell'uscita verificato: `connesi_building_test2/Porta Regia_001` (glTF originale Porta Regia.001). Distinta da RegiaSwingDoor già approvata.

`RegiaIntegration/NetworkPuzzle` crea wrapper e collider di interazione runtime, preservando mesh/materiali originali, metadati e gruppi. Portatile: separazione dei triangoli di coperchio/base con UV/normali conservati; cerniera sull'asse locale Y. Scala runtime 2.1 anche nel corridoio; deposito (8.75, 1.0657, 4.90), Y=PI, davanti al monitor/torre della ScrivaniaRegia, piano a quota 0.944448. Display circa 0.5985×0.3717 m, rivolto alla sedia rossa; base contenuta sul piano. Ethernet SX/alimentazione DX con innesti ricavati dal transform importato. Nessuna nuova modifica alla mappa o alle mesh originali.

Chiusura: monitor e dodici etichette sui tasti reali; clic proiettato sul loro piano, nessuna tastiera inventata separata. Due LED sopra la cornice. Wrapper della chiusura figlio del DoorBody dell'uscita, collider della chiusura escluso dopo sblocco, battente ancora fisicamente bloccante quando chiuso. Collider player invariato. Cavi visivi senza collisioni, comparsa di 0.6 s ancorata alla sorgente; caricatore con collegamento visibile immediato.

Racchetta: stesso modello originale, variante locale del materiale del manico e UV cilindriche per una sola sequenza leggibile. Originali texture/FBX conservati. Alla sconfitta copia visuale dalla mano verso il pavimento in 0.6 s, collider interazione a destinazione, nessun nuovo bersaglio AI. Materiale applicato anche alla racchetta tenuta da Bruno senza modificare il controller. Texture `assets/textures/regia_racket_handle.png` e risorsa compressa `regia_racket_handle.res` rigenerate dal tool Godot con il nuovo alfabeto; runtime pre-carica la risorsa Godot, non legge il PNG grezzo.

## Stato e compatibilità

Controller separati: `regia_network_state.gd` (regole), `regia_network_puzzle.gd` (mappa/visivi/interazioni), `regia_network_terminal.gd` (desktop/browser/alieno). Nuovi item regia_laptop/network_cable/bruno_racket registrati dall'autoload inventario prima del restore.

Ora registrato anche regia_charger. Nuovi bool persistenti charger_collected/laptop_shutdown/laptop_recovered; vecchio caricatore già collegato implica raccolta. Recupero verifica tutte le capienze prima di aggiungere gli item e staccare il cavo PC, evitando mezzi kit o duplicati. Arresto/raccolta non annullano il puzzle o la configurazione del router.

Lettura: regia_book_reader.gd genera un libro aperto 3D con copertine/fogli, curvature e pagina animata, in SubViewport separato. Riusa regioni della texture reale del libro e della copertina del notebook; pagine del quaderno ricostruite a righe con Segoe Print. Tre aperture aliene, WiFi soltanto all'ultima, nessun suggerimento esplicito sulla protezione. La geometria degli oggetti nella mappa è conservata.

Partecipante `main.regia.network`, priorità 30 dopo corrente e ambiente boss. Snapshot: raccolta/deposito/apertura/accensione PC, caricatore, due cavi totali e collegamenti, PPPoE/WiFi/protezione/password, sblocco definitivo, racchetta/disponibilità/raccolta/posizione, letture e luci. Online e LED derivati da alimentazione/stato; dopo restore, nuova negoziazione di 3 s. Tentativo password parziale non persistito. ID porta `main.door.regia_exit` usa l'adattatore battente esistente.

SaveManager e formato ConfigFile versione 1 conservati. N ricomincia, C/Carica ripristinano; nessun autosave. Salvataggio impedito durante posa cavi/drop/ritorno dopo sblocco, movimento porta o negoziazione. Per vecchi checkpoint senza stato puzzle: nuovi elementi iniziali; se Bruno è già sconfitto si recupera una sola racchetta al completamento del restore.

GameplayUI estesa con documenti/scelte ed esame 3D; le nuove postazioni dichiarano `requires_save_eligibility=false` perché non sono PC di salvataggio. ConnesiOS conserva il controllo storico can_save. Chiusura forzata per cambio scena libera anche pannelli e viewport del puzzle.

## Font e verifiche

Wingdings 3 sostituito su richiesta utente: dodici lettere armene selezionate da Sylfaen locale `C:/Windows/Fonts/sylfaen.ttf`, oppure `assets/fonts/regia_alien.ttf` se fornito. **Font non copiato nel repository**; trasferimento/export richiede disponibilità e licenza adeguata. Tasti, monitor, messaggi e texture racchetta usano gli stessi glifi; indici fissi RegiaNetworkState.PASSWORD conservati, anche per i salvataggi precedenti. Il giocatore non riceve suggerimenti sul manico nell'inventario o nell'esame.

LED Fritz: overlay aderenti alle finestrelle originali mediante interpolazione UV dell'atlante 1600 px. Power/Internet indica alimentazione, WLAN indica radio, Info indica connessione Offline/Online; Fon/DECT e Connect/WPS originali conservati spenti. Nessuna nuova scritta sulla mesh. Vista dall'alto dopo collegamento, con uscita Esc e menu Collegamenti.

Cavi: Curve3D con punti di appoggio sul tavolo, curva libera sotto il bordo e gioco sul pavimento per l'alimentazione; tubi da 3/4 mm e innesti visivi, privi di collider. Percorsi verificati con immagini dedicate della scrivania e del sottopiano. Desktop Full HD con font MSDF, grafica nativa e browser/Fritz ispirati ai quattro PNG in docs; nessun dato della rete domestica incorporato.

Chiave Bruno: `assets/models/edificio/key_with_tag/scene.gltf`, modello reale scalato a 0.34 m e centrato sopra il pavimento. Raccolta e persistenza preesistenti conservate. Attribuzione/licenza in [ASSET_CREDITS.md](ASSET_CREDITS.md).

- `regia_network_state_test.gd`: limiti cavi, recupero, ordine switch/PC, PC scarico/alimentazione, credenziali sbagliate, negoziazione, rete protetta/aperta, codice sbagliato/corretto, sblocco dopo perdita corrente, snapshot e glifi. Passato failures=0.
- `regia_network_map_test.gd`: mappa reale, documenti, deposito/apertura/accensione/zoom/Esc, clic proiettati su Chrome/login/configurazione/WiFi, LED, luci, drop/raccolta/esame racchetta, clic tasti alieni, sweep player chiuso/aperto, chiusura solidale al battente, riapertura senza puzzle, save/restore. Forward+ D3D12 RTX4060: failures=0.
- Varianti `-- --continue-test` e `-- --partial-test`: processo nuovo e snapshot intermedio (switch collegato, PC scollegato, un cavo disponibile, PC depositato ma spento, router non configurato, porta bloccata). Esiti finali nel registro sessione.
- `regia_terminal_render_test.gd`: UI finale da riferimenti utente FritzHome/Login/PPPoE/WiFi, intestazione blu/menu laterale/campi chiari; clic Chrome/login/PPPoE/radio/protezione/Applica reali, nessun dato della rete domestica inserito nel gioco. Passato failures=0; screenshot network_ui_login/internet/wifi.
- Regressione demo inventario/save/C/N: INVENTORY_SAVE_TESTS_OK. Passaggi scorrevoli/Bruno: esiti finali nel registro.

Slot fixture `.godot/regia_network_test_slot.cfg`, nessuna scrittura negli slot utente. Screenshot `.godot/network_*.png`; luce aggiuntiva e dimensione finestra sono esclusivi del test, non salvati nella mappa/impostazioni. Racket pose 0–3 verificano che ruotando il manico la sequenza sia visibile. Test automatici non sostituiscono il playtest artistico/gameplay utente dell'intero puzzle.

Nuovo slot kit `.godot/regia_network_packed_slot.cfg` e variante -- --packed-test per processo nuovo. regia_book_reader_test.gd verifica sfogliatura e credenziali; network_inspect_* mostra i cinque item. Esiti del ciclo aggiornato nell'ultima SESSION_LOG.

**Esiti finali:** REGIA_NETWORK_CONTINUE_TEST=0, REGIA_NETWORK_PARTIAL_TEST=0, SLIDING_PASSAGE_TEST=0, BRUNO_PASSAGE_TEST=0. Le due prime prove headless concorrenti sono terminate per allocazione memoria fallita; ripetizioni sequenziali passate, nessuna modifica alla bocca per questi errori. Eseguire una sola suite che carica la mappa alla volta. Restano warning storici certificati/SparksElectric e 45 ObjectDB a uscita del restore headless. Primo test documenti corretto perché la fixture aveva disabilitato la fisica del player: il rifiuto della UI era previsto. Dopo ispezione GPU ricalibrati cerniera/schermo PC e tasti alieni sui triangoli reali.
