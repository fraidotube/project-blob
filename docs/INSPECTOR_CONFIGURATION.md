# Configurare Project Blob dall'Inspector

**Audio fight Broccolo (19/10):** selezionare `BroccoloMinionSpawner` per stream, volume, ripartenza soundtrack e parametri mappa. In `MainBroccolo/LabAudio` (e nella scena Actor Scene per le copie) sono esposti i cue, offset iniziali e durate di taglio; pop streams e lanci rispettano gli array ordinati. Su `BroccoloEncounter` → **Invito interruttore** regolare raggio di prossimità, portata, energia e frequenza pulsazione della luce viola, applicata soltanto al comando lampadario.

**Sfera/incendio Broccolo18/10:** sul root laboratorio collegamenti Energy Visual Scene/Burn Status; nel test puntano a EnergyVisual e Player/BroccoloBurnStatus, in mappa null. Sullo stato: Target/Camera obbligatori, Duration Seconds3, Tick Damage3, Tick Seconds0,75, Flame Height1,7m e Flame Color. Energia grafica: scene broccolo_energy_visual, dimensioni/tinta aura e materiali/mesh Core/Orbit; fisica/danno/raggio sui Moves del boss come prima. BodyFlames usa stessa PowerVFX. Nuovi effetti esclusivamente runtime, nessun @tool; parametri stato custom serializzati e applicati nel test.

PowerVFX / Nascita copie: **Copy Flash Seconds0,22s** e **Copy Flash Strength0,65** regolano il breve guscio arancione alla duplicazione, separato dalla durata delle particelle. A fine lampo la copia conserva il bordo normale e il principale riprende l'eventuale aura dorata.

Nel nuovo PowerVFX, posizione Y/raggio/velocita native di Sparks e Streaks sono il profilo per un corpo alto1m: runtime li legge al ready e li moltiplica per l'altezza corrente. I valori personalizzati vengono conservati, non sostituiti da costanti; quantita/spread/lifetime restano nativi. Verificato roundtrip PackedScene e applicazione di velocita1,1 a un'aura alta0,5m (risultato0,55m/s).

**VFX Broccolo in approvazione18/10:** `broccolo_combat_test.tscn/MainBroccolo/Preview Vfx Scene` collega `scenes/effects/broccolo_power_vfx.tscn`. Aprire tale scena: root espone colori, durata coda, glow, tempo emersione/getto, forza/spessore/glow/minimo pulsazione del bordo copie. Sparks/Streaks hanno quantita, lifetime, mesh, velocita e spread nativi; shader/mesh su Flames e GroundRing. Copy Aura Strength sull'actor vale solo senza profilo (mappa attuale), con profilo usare Copy Rim Strength. Pool conserva lo stesso riferimento di scena per le copie. **Non abilitare ancora in mappa: approvare nel test, poi trasferire la stessa risorsa identica.**

**Broccolo in mappa18/10:** scena `scenes/enemies/broccolo_map_combat.tscn`, istanza sotto BroccoloEncounter/BroccoloMinionSpawner. Root: Max Copies, cooldown, Warmup Render, volume/spaziatura/budget navigazione, Gate Config Paths, altezza/tempo/distanza salto. Figli Roles e MainBroccolo conservano il tuning del laboratorio. WarehouseDoors/PortaGrigliata013/014/015: Enemy Jump Open Enabled; default falso sulle altre porte. Non cambiare Persistent Id senza migrazione. [Dettagli](BROCCOLO_COMBAT_LAB.md#integrazione-mappa-e-copie-preparate-1810).

**Audio Broccolo:** su LabAudio entrambe le liste esclamazioni usano solo `_mostro`; Hurt Streams contiene3colpito, Hurt Start Offsets contiene i rispettivi silenzi da saltare in secondi. Hurt Volume Db=+8, pitch reazioni1; Step Volume Db=−4, Step Unit Size=6m, Step Hearing Distance=16m, pitch passi1,7. Il canale voce pilota anche la bocca nelle reazioni. Test PCM e dettagli nella [guida laboratorio](BROCCOLO_COMBAT_LAB.md).

**Broccolo ruoli/audio aggiornato:** nel laboratorio selezionare **Roles/Assaltatore, Lanciatore, Aggiratore** per velocità, cadenze, raggio laterale e distanza tiro; duplicare un profilo con Role Id distinto e aumentare Max Copies per aggiungerne uno. In `broccolo_lab_actor.tscn/LabAudio` selezionare esclamazioni originali/mostro, passi/salto/atterraggio/impatti, pitch e volumi. Sul corpo: scala0,20, distanza/cadenza iniziali e finali del principale, tempi di salto/escape da incastro. Sotto Moves: tipo Lancio, velocità/raggio/danno/timing delle sfere. [Guida attuale](BROCCOLO_COMBAT_LAB.md).

**Laboratorio boss Broccolo17/10:** [nodi e parametri](BROCCOLO_COMBAT_LAB.md#inspector). Scena `broccolo_combat_test.tscn`: cap/cooldown sul root, salute/movimento sul principale; mosse duplicabili sotto Moves in `broccolo_lab_actor.tscn`, con clip/timing/portata/danno/impulso serializzati. Nessuna modifica alla configurazione della mappa.

Aggiornamento running: root Start In Fps/Auto Combat ed Emission Separation Degrees; attore Miniature Scale0,17, clip partenza/corsa/inversione/frenata/atterraggio, soglia/cooldown inversione e Scatter Seconds. Copie: Copy Aura Strength0,08 e Copy Aura Color arancione. Per parametri delle copie modificare la scena Actor Scene, non solo il principale. Default verificati nel runtime e override salute serializzato/reistanziato nei test.

Standard approvato dall'utente il17/10/2026 per gli sviluppi futuri: parametri e collegamenti utili devono essere modificabili nella scena, raggruppati e descritti. I commenti `##` dei campi forniscono le spiegazioni nell'editor. Lo stato interno del gioco resta nel codice.

Esteso dallo stesso utente a tutti gli script di gameplay, con priorita a player, armi, energia e dotazione iniziale. I valori approvati della partita rimangono i predefiniti: rendere un parametro modificabile non ne cambia il bilanciamento.

## Prima di modificare

Ferma il gioco e lavora sull'albero **Locale**, non su **Remoto**: le modifiche remote non costituiscono la configurazione salvata della scena. Salva la scena e riavviala per applicare i valori ai controller generati. Non cambiare gli ID delle porte/circuiti esistenti per rinominarli: i checkpoint li usano per riconoscere gli oggetti.

## Player, salute, armi e spawn

Apri `scenes/player/player.tscn` per modificare i predefiniti condivisi. Per modificare solo una mappa, seleziona la sua istanza **Player**: gli override locali della mappa prevalgono sulla scena condivisa. Per accedere ai figli di un'istanza, tasto destro sul Player → **Figli modificabili / Editable Children**, poi salva la mappa. Non rendere unica o ricostruire tutta la scena del player.

| Nodo da selezionare | Cosa regolare |
|---|---|
| Player → Salute e dotazione iniziale | Max Health, Starting Health, Starting Inventory |
| Player → Movimento | Walk Speed, Sprint Speed, Crouch Speed, Jump Velocity (m/s) |
| Player → Visuale | Base Mouse Sensitivity; viene moltiplicata per la preferenza del menu |
| Player → Postura avanzata | Altezze capsula/testa e velocita transizione; verificare soffitti/passaggi dopo modifiche |
| Player → Ritmo passi / Audio passi e salti / Player Voice | Intervalli, stream, volume voci, cooldown e respiri |
| Player/Head/Camera3D/WeaponHolder → Dotazione iniziale | Possesso pistola/torcia/SMG e arma inizialmente in mano |
| WeaponHolder → Danni / Combat / Racchetta | Danni, portata, cadenza pistola, cooldown melee, velocita/istante impatto racchetta |
| WeaponHolder → Pistola / SMG | Capienza, colpi inizialmente caricati e riserva; cadenza automatica SMG |
| WeaponHolder → Torcia | Consumo percentuale/secondo, carica iniziale, batterie di ricambio e capienza |
| WeaponHolder → Audio Pistola / Audio SMG / Animazioni / Viewmodel | Stream/volumi, velocita ricarica e arretramento vicino ai muri |
| Player/Head/Camera3D | Fov nativo; Use Saved Fov attivo applica la preferenza menu all'avvio |
| Player/Head/Camera3D/InteractRay | Target Position determina la distanza E (attualmente Z=-2 m); mask2, aree abilitate |
| Player/Head/Camera3D/WeaponRay | Target Position determina la portata massima del ray proiettili (Z=-100 m) |
| Player/Head/Camera3D/FlashlightBeam | Energia, colore, cono, portata e ombre della torcia, distinti dalla batteria |
| WeaponHolder/MuzzleFlash | Energia/colore/range del lampo; durata sul WeaponHolder |
| WeaponHolder/ShellCasingTimer e ShellCasingAudio | Ritardo del bossolo (Wait Time), stream e volume |

**Salute iniziale:** Starting Health=0 significa partire con Max Health. Un valore positivo viene limitato tra1e Max Health. Attualmente100HP e nessuna stamina: l'energia della torcia e' la percentuale della batteria, non una seconda barra del giocatore.

**Esempio per una prova:** Starting Owns Pistol=true, Starting Equipped Weapon=Pistola, Pistol Starting Magazine Ammo=4 e Starting Reserve Ammo=20. La pistola sara' disponibile con4colpi caricati e20di riserva. Senza possesso, la selezione iniziale torna a mani nude. Il valore−1 dei colpi inizialmente caricati significa caricatore pieno;0 significa vuoto. La capienza del caricatore e' un'impostazione distinta dalla quantita allo spawn.

**Oggetti iniziali:** Starting Inventory e' un dizionario di ID→quantita, per esempio `switch_key: 1`. Usa ID gia' registrati in InventoryManager, come switch_key, assistance_key, production_key, ced_fingerprint, bruno_key o network_cable. L'ID non e' il nome del nodo o il nome visibile dell'oggetto. La definizione `.tres` in `resources/items` stabilisce nome, icona, descrizione e capienza. ID sconosciuti, quantita non positive o oltre capienza producono un avviso, senza inventare oggetti. Vuoto conserva lo spawn attuale. La racchetta resta soggetta a possesso e sblocco della progressione; inserire un item non sblocca il combattimento.

**Nuova partita e caricamento:** le impostazioni iniziali valgono per avvio diretto/F6 e Nuova partita, incluso riavvio dopo morte. Carica/Continua usa salute, possesso, arma, colpi, carica e inventario del checkpoint. Gli oggetti consumati non vengono riassegnati. Cambiare la capienza massima continua a limitare il valore ripristinato come prima; per provare una nuova dotazione usare Nuova partita, non un vecchio salvataggio.

**Valori predefiniti conservati:** camminata5/corsa8/accovacciato2,8m/s, salto4,5m/s,100HP, mani nude e nessuna arma posseduta, inventario vuoto; pistola9+36colpi, SMG30+120, torcia100%/consumo2punti al secondo/0ricambi/capienza5. Nessuna modifica ai valori delle scene player o mappa e nessuna chiave concessa automaticamente.

## Altri componenti importanti

Seleziona il nodo che porta lo script, oppure la risorsa `.tres` nel FileSystem; i gruppi esportati compaiono sotto le proprieta native. Le proprieta native sono gia' modificabili: non serve duplicare energia luce, collisioni, geometria o volume audio in un altro pannello.

| Componente / script | Parametri e collocazione |
|---|---|
| Pickup munizioni pistola/SMG | Contenuto pickup → Ammo Amount aggiunge colpi alla rispettiva riserva; Interazione controlla nome/colore/bordo |
| Pickup pistola/SMG/torcia/batteria | Interazione descritta; la batteria aggiunge un solo ricambio se c'e' posto. Possesso e carica iniziale sono sul WeaponHolder |
| inventory_item_pickup.gd | Oggetto raccolto → Item Id/Quantity; Identita e interazione → Persistent Id/nome/colore, rispettati anche dopo il ready |
| inventory/item_definition.gd | Risorse `resources/items/*.tres`: ID stabile, nome, descrizione, icona e Max Quantity; una nuova risorsa va anche registrata |
| hazards/fire_damage_zone.gd | Damage Per Tick e Damage Interval; primo danno immediato all'ingresso |
| hazards/smoke_cough_zone.gd | Stream tosse, volume, primo ritardo e intervallo minimo/massimo |
| player/indoor.gd | Audio ambiente esterno collegato, volumi interno/esterno e durata sfumatura |
| ConnesiPower | Stato Power On iniziale; checkpoint e blackout prevalgono durante il gioco |
| BrunoBuozzi / enemies/bruno_buozzi.gd | Categorie gia' presenti: salute/fasi, movimento, proiettili/melee, audio, scudo e animazioni; non modificati da questa migrazione |
| Broccolo, scena di prova | Controller debug/broccolo_animation_preview.gd: voce, modalita presentazione, tempi telefonata/lancio/danze e musica gia' esportati |
| OcchioDiBue | environment/bruno_boss_spotlight.gd: Target, Spotlight, Tracking e Debug gia' esportati; il boss attivo puo' sostituire il target durante l'incontro |
| HUD | systems/hud.gd: gruppi Damage Feedback, Boss HUD e Damage Numbers gia' esportati |
| ImpactManager | effects/impact_manager.gd espone durata/numero decal e limiti audio. Quando generato solo a runtime, modificare il nodo Remoto e' una prova temporanea; non e' ancora una configurazione salvata nella mappa |

Le proprieta storiche Bullet Impact Scene/Offset del WeaponHolder restano serializzabili per compatibilita ma non sono presentate come regolazione dei decal: il gestore reale e' ImpactManager. Gli script di servizio, le macchine a stati, i test e gli strumenti non richiedono l'esposizione di contatori e variabili interne. Per controller generati soltanto a runtime, come combat Angelastri e alcune integrazioni storiche, serve una configurazione serializzata sul generatore prima di poter promettere modifiche permanenti dall'Inspector: questa parte non e' stata migrata integralmente in questa sessione.

## Porte della nuova zona

Apri `scenes/maps/map_test.tscn`, espandi **WarehouseDoors** e seleziona il figlio della porta. Questi nodi sono configurazioni: non vanno spostati nello spazio. Il modello visivo mantiene il suo posizionamento originale; durante il gioco il controller viene creato automaticamente nella radice della mappa.

| Nodo da selezionare | Porta |
|---|---|
| PortaAntibagno | Antibagno |
| PortaBagnoDX / PortaBagnoSX | Due bagni |
| PortaSwitch | Stanza switch |
| PortoneAssistenzaInterno | Portone interno |
| PortaAssistenzaPrincipale | Ingresso assistenza |
| PortaProduzione | Produzione |
| PortaGrigliata013 /014 /015 | Grigliate magazzino |
| PortaScale038 | Cima scale magazzino |
| PortaCED | CED |

I gruppi dell'Inspector sono:

- **Mesh e pannello:** Source Visual e' la sola anta mobile con figli/maniglie; il telaio resta fuori. Se il visual e' un gruppo, Panel Source indica la mesh dell'anta che determina ingombro e cardine. Il CED usa il gruppo Porta DC e il pannello Porta_092.
- **Identita e salvataggio:** Runtime Name identifica il controller creato all'avvio; Persistent Id identifica lo stato salvato. Interaction Name e' soltanto il nome mostrato al giocatore.
- **Movimento:** Width Axis sceglie l'asse mondiale lungo la larghezza dell'anta chiusa (X o Z); Hinge At Max sceglie il bordo massimo oppure minimo dell'asse. Open Angle e' l'angolo in gradi attorno a Y: cambia il segno per invertire apertura. La direzione della protezione del giocatore segue automaticamente l'angolo. Open Speed controlla la rapidita; Auto Close e Auto Close Delay richiedono una chiusura dopo il ritardo, con le protezioni del passaggio.
- **Serratura:** Required Key e' l'ID dell'oggetto inventario, vuoto per una porta libera. La chiave non si consuma; lo sblocco viene salvato. Fingerprint Locked associa la porta al lettore configurato sul genitore. Non combinare chiave e fingerprint sulla stessa porta.
- **Audio:** scegli apertura/chiusura, volume e distanza3D. Close Sound At Start anticipa la chiusura all'inizio del movimento anziche' a battuta, per gli sportelli.
- **Evidenziamento:** colore del bordo e spessore; non cambia geometria o collisioni.

Esempio: **WarehouseDoors → PortaScale038 → Movimento → Open Angle** e' attualmente−90. Cambiare il segno inverte il verso senza intervenire nello script. L'attuale−90 apre verso giocatore/scale come richiesto dall'utente; un valore diverso va provato per evitare gli arredi.

Per una nuova porta duplica una configurazione simile, assegna **nuovi Runtime Name e Persistent Id**, collega la nuova anta e scegli asse/cardine/angolo. La chiave deve essere gia' registrata nell'inventario: compilare l'ID non crea l'oggetto o il suo pickup. Gli avvisi del nodo segnalano riferimenti mancanti, ID/nome/anta duplicati e serrature incompatibili; correggili prima della prova. Non selezionare l'intero edificio o un gruppo che comprende anche il telaio.

## Lettore fingerprint

Seleziona **WarehouseDoors**, gruppo **Lettore fingerprint**. Puoi modificare mesh del dispositivo, ID del lettore, oggetto inventario autorizzato, durata dello sblocco, durata dell'errore e colori del LED. I valori iniziali restano10s,1,5s e blu/rosso/verde. La porta e' identificata dall'unica configurazione figlia con Fingerprint Locked, non dalla posizione nell'albero. Il lettore sblocca temporaneamente: la porta si apre manualmente con E. L'enigma per ottenere l'impronta e' ancora una fase futura.

## Interruttori delle luci

Seleziona direttamente la mesh dell'interruttore nella radice della mappa. Nei gruppi dell'Inspector:

- **Collegamenti:** Power System e' ConnesiPower; Lights Root e' la luce singola o il gruppo del circuito. Zone Light Switch gestisce anche luci annidate.
- **Salvataggio circuito:** Persistent Id deve essere unico; quando duplichi un interruttore assegnane uno nuovo e collega un circuito diverso se deve essere indipendente.
- **Materiali luminosi:** Emissive Visual Roots contiene percorsi relativi all'interruttore. Se centro e lati emettono, seleziona il gruppo della lampada intero. I materiali vengono copiati in memoria, lasciando gli originali intatti. Emission Texture Override e' facoltativo; i lampadari lo usano per la maschera corretta della lampadina.
- **Interazione / Evidenziamento / Audio interruttore:** nome, contorno, click on/off, volume e distanza. Il nome mostrato non sostituisce l'ID del salvataggio.

I parametri dei corpi luminosi reali, come energia, range e cono Spotlight, restano nell'Inspector delle **Light3D**: non nel comando dell'interruttore. L'accensione iniziale, blackout e restore applicano lo stesso stato a luci ed emissione; il ritorno della corrente non riaccende automaticamente il circuito.

## Limiti e verifica

I controller storici basati su `door.gd` espongono movimento/audio/evidenziamento direttamente sul loro nodo. Migrazione effettuata:12porte WarehouseDoors/interruttori e parametri principali player/armi/spawn, con descrizioni per pickup, oggetti inventario, interazioni e aree ambientali. Bruno/HUD e altri componenti con export preesistenti sono indicati nella tabella, senza dichiarare una conversione completa di tutti i controller storici.

`player_inspector_configuration_test.gd` verifica player reale, round-trip scena con figli modificabili, valori personalizzati, avvio diretto/nuova partita/caricamento tramite SaveManager, consumo/ricarica torcia e precedenza del checkpoint senza rigenerare oggetti consumati. `inventory_save_test.gd` controlla la regressione della progressione e dei salvataggi su slot `.godot`, non quelli utente. Serve comunque il playtest FPS/audiovisivo per giudicare un nuovo bilanciamento scelto nell'Inspector.

Controlli pertinenti: `door_inspector_configuration_test.gd` per serializzazione e valori modificati, `warehouse_doors_test.gd` per migrazione/chiavi/CED/passaggio reale e `warehouse_lights_test.gd` per circuiti. Le verifiche non scrivono gli slot utente. Dopo una modifica ai cardini o al verso, prova sempre attraversamento e spazio dagli arredi nella mappa.
