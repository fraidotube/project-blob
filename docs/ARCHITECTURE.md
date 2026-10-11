# Project Blob — architettura operativa

**Mirino globale:** HUD crea un Control project_blob_reticle sotto Interface e nasconde CrosshairImage originale mantenendolo compatibile con vecchi riferimenti. Oggetti/pulsanti usano focused_interactable dell'InteractionSystem esistente; nemici riconosciuti lungo antenati del collider WeaponRay tramite take_damage (Bruno/Angelastri inclusi). Campionamento20Hz, apertura/tinta interpolata; niente modifica alle interazioni/AI. Onda attacco zombie: ImmediateMesh68 triangoli, unshaded alpha, niente ombre/luci, settore uguale al range/cone di danno, svanisce0.35s.

**Combattimento Angelastri:** al ritorno del secondo incontro encounter crea angelastri_combat.gd, CharacterBody3D, e vi trasferisce il modello già caricato conservando posa. Collider riceve melee take_damage, take_bullet_hit/try_dodge_shot sempre senza danno. Stati chase/attack/bite/dodge/hurt/dead, impatti singoli su durata reale, lock/rilascio player, HUD CanvasLayer in alto. Weapon conserva 0–3 e aggiunge racchetta 4, possesso InventoryManager/sblocco fight/slot5/save opzionale. UI Usa/Riponi soltanto dopo sblocco. Preview riusa secondo incontro e pre-carica voce; patrol ruota il modello per non farlo orbitare rispetto al root offset. [Guida](ANGELASTRI_COMBAT.md).

**Evento Angelastri:** controller separato angelastri_encounter.gd, stato RefCounted angelastri_event_state.gd e nodo map_test. Osserva RegiaNetworkState.changed e ConnesiPower.power_changed; non modifica i sistemi. Soglia da collider porta esterna chiusa, lettura direzionale con isteresi. Riusa una presentazione prewarmata e la diagonale di danza nota, evitando istanziazione e sweep fisici alla terza uscita. I tre blackout aprono gli sportelli, spengono ConnesiPower, riproducono click vicino al player, notifica e risata 3D; riarmo 12 s. Regia audio-driven con uscita iniziale dal varco, raycast/volumi camion e quote basse durante danza, lock FPS/arma/HUD e prestito/restauro OcchioDiBue. Persistenza main.angelastri.encounter priorità 30, pausa/morte/restore; passeggiata limitata con capsule/terreno, vista reale per secondo discorso. Segnale fight_ready senza AI/arma racchetta ancora. [Contratti](ANGELASTRI_ENCOUNTER.md).

**Preview Angelastri in mappa:** nodo `AngelastriMapPreview` in map_test con controller dedicato F10/F11/F12. Istanzia il controller studio in modalità map_presentation senza camera/UI/ambiente. Curve bacino originali copiate prima della normalizzazione X/Z: offset cumulativi muovono realmente il modello e raycast segue il terreno. Dialogo resta stazionario e parte dalla posizione corrente, rivolto al player. Cleanup su F12/morte/restore; nessun partecipante salvataggio o AI. [Dettagli e limiti](ANGELASTRI_MAP_PREVIEW.md).

**Isolamento Animation:** nuova AnimationLibrary e duplicate(true) esplicito su ciascuna Animation esterna. Duplicare soltanto la libreria lasciava riferimenti condivisi: loop/normalizzazione ora avvengono su oggetti distinti verificati, senza scrivere risorse originali.

**Principale continuo:** _build_main_cues somma durate reali, pone secret a max(44 s, fine gesto precedente). _play_main_clip usa playback continuo e crossfade 0.55 s, aspetta completamento gesto precedente senza seek/pause per frame. _normalize_main_positions cambia X/Z delle chiavi POSITION_3D del bone 0 nelle sole copie private parlato/idle_new/talk_to_combat/looking; Y e rotazioni conservati, nessun track danza modificato. Fine voce → _main_tail attende fine reale idle_new (8.3333 s), poi talk_to_combat (1.1667 s), signal combat_preview_ready unico e posa finale ferma. Pause/replay espliciti per stati main/tail; intro/danza percorso precedente. Nessuna AI nel debug.

**Talking principali:** CUES[1] integra talking/talking2/talking3 e talking_secret. Prime tre ripetibili sul tempo voce; finite altre clip principali il fallback è talking. Finestra export main_secret_start/end (47/54 s) seleziona secret solo nel principale; non viene ripetuta/copiata negli altri cue. Clip valutate in copia privata, risorse/pose della scena ufficiale utente preservate. Test conteggio aggiornato per 33 mie/35 totali e controllo secret esclusiva nel test continuo.

**Preview discorso principale:** nuova scena debug riusa angelastri_mouth_preview.gd con preview_main_dialogue=true. start_presentation seleziona audio indice 1 e stage main_dialogue; fine voce passa direttamente a looking continuo, senza Thriller o AI. CUES[1] temporizza gesti privati su clock voce; finite le clip brevi usa looking invece di posa bloccata, talk_to_combat ripete, risata pilota motion.laughing. toggle pausa protegge avanzamento stadio anche quando AudioStreamPlayer.playing risulta false durante stream_paused. Preview intro/balletto invariata per export false.

**SingingArticulation locale:** inner class nel controller preview, process_priority=10/ALWAYS per applicare shape dopo BrunoMouthMotion RMS. Attiva solo se binding musica; fase su clock MP3−73.5 s, impulsi stilizzati 2.8 Hz con variazione 0.7 Hz, apertura limitata da motion.current_open e forme modulate. Smoothing 0.03/0.045 s, target zero su pausa/albero fermo; quando binding voce ripristinato non tocca shape. Nessuna modifica controller bocca condiviso o bus/musica.

**Cue secondo gesto intro:** runtime calcola cue pointing2 = intro_pointing_time + durata effettiva mie/pointing, poi ordina cue privati. Default 15.6 s, pointing non più ciclico. Nessun cambio risorse originali.

**Bocca al canto:** solo preview update_singing(time) commuta component.bind_voice tra voice e music al cue 73.5 s. Riusa unico BrunoMouthMotion/capture bus, send SFX prima e Music durante canto; non riavvia stream musica. stop_voice ripristina binding voce prima di reset; fine musica/stop/replay chiudono bocca e restituiscono bus Music. Controller bocca Bruno/Angelastri e scene ufficiali inalterati.

**Looking al posto di idle:** preview dance_start_delay=1.0; init/lead-in/fine danza usano mie/looking. Solo copia privata looking in LOOP_LINEAR; eliminate sync_rest e alternanza/timer verso idle, rest affidato al player continuo con blend 0.6 s e pausa esplicita. Clip idle originale conservata per combattimento e selezione manuale delle risorse.

**Timing/blend preview:** export dance_start_delay 2 s sottratto dal clock musica prima di selezionare danza, idle nel lead-in; fade/fine e durata test includono offset. intro_pointing_time 12 s aggiorna cue privato all'avvio. Dopo danza rest usa AnimationPlayer continuo con crossfade rest_blend_seconds 0.6 s; solo idle privato LOOP_LINEAR. sync_rest governa alternanza senza seek/pause ogni frame; toggle_presentation_pause sospende/riprende player anche nel rest. Clock audio e seek senza blend restano per voce/danze, preservando fix corpo congelato.

**Fix seek/pausa:** sync_sequence/sync_rest e ingresso rest cambiano clip con blend 0.0. La precedente sfumatura restava a peso zero sotto pausa, bloccando il corpo nonostante seek aggiornasse il tempo. Test ora confronta rotazioni delle ossa a 1/5 s per ogni danza, oltre a nomi/stadi. Pointing intro 11–18 s ripete la clip, senza pointing2; allineamento frase da confermare.

**Traccia lunga:** preview crea AudioStreamMP3 privato da byte reali di thriller.mp3, poiché import locale ancora descriveva il vecchio audio. Nuovo file 125.4102 s, loop condizionale risulta false per 111.3 s di danza; clock unico e fade finale invariati.

**Quattro balletti:** DANCES contiene nomi verificati mie/thrller_1…4; selezione cumulativa su clock musica, totale letto dalle risorse. Music usa copia privata del MP3; loop abilitato soltanto se sequenza supera stream.length. music_sequence_position compensa wrap con offset della durata audio. Risorse/scene ufficiali utente non mutate; 29 mie/31 totali.

**Preview automatica Angelastri:** export automatic_preview=true per F6; fasi intro/dance/rest nel solo controller debug. Fine voce avvia Music una volta; thrller_2 usa lo stesso playback continuo, fine danza ferma musica dopo fade e avvia idle. Rest valutato su delta di processo con pausa esplicita, idle ciclico e looking completo ogni 10 s. Replay resetta audio/stato/bocca/vista. Test manuale disabilita export prima dell'add_child; --presentation prova automaticamente tutti gli stadi in 85 s reali.

**Preview Angelastri fase 1:** controller isolato usa copie profonde di mie con LOOP_NONE, SFX voce → capture RMS esistente e Music Thriller indipendente. Sequenze valutate su get_playback_position dell'audio, seek deterministico e pausa AnimationPlayer; assigned_animation mantiene nome anche durante pausa. Dialoghi usano cue provvisori modificabili in RAM; danza passa da thrller_1 a thrller_2 ai 29.8333 s e termina ai 48.6667 s con fade finale. Camera figura intera segue bone 0 del GeneralSkeleton per root motion; closeup segue testa. Nessuna modifica scena ufficiale, modello, player, mappa o controller Bruno.

**Angelastri V2:** stessa struttura della variante iniziale, soltanto arcata superiore traslata +0.0012 m sull'asse verticale locale Blender; componente carica mouth_preview_v2. Controller/shape/apertura e rig invariati.

**Bocca Angelastri:** `angelastri.tscn/MouthPresentation` → angelastri_mouth.gd → head-only GLB su path verificato `sgt_Angelastri/Armature/GeneralSkeleton/mixamorig_Neck/Testa`. Mesh rigida, corpo skinnato separato; nessun retargeting. Tre shape e superfici pelle/cavità/denti. Voce opzionale, bind_voice riusa BrunoMouthMotion; senza voce nessun bus e bocca ferma. Preview isolata con confronto/manuale/animazioni originali, audio Bruno provvisorio escluso dalla scena nemico. [Dettagli](ANGELASTRI_MOUTH.md).

**Audio scorrevoli:** RegiaIntegration assegna `RegiaAudio.stream("sliding")` a open_sound/close_sound delle due istanze laboratorio/bagno. SlidingKeyDoor riusa AudioStreamPlayer3D SFX esistente, max_distance 12 m; stop al completamento del movimento o apply_persistent_state. Offset/velocità/collider invariati.

**Audio regia:** `regia_audio.gd` crea pool SFX locali 2D/3D e conserva stream MP3; terminale emette mouse/input campi/bip, lettore pagina all'inizio tween, NetworkPuzzle cavi alla fine posa e sblocco sulla transizione. ExitDoor usa stream nuovi nel DoorAudio base, apertura dopo arretramento e chiusura a battuta; pausa normale sospende audio/movimento. Restore silenzioso, nessun nuovo stato persistente o bus. [Contratto audio](REGIA_AUDIO.md).

**V6 denti texturizzati:** HEAD_FILE preview/integrazione `mouth_preview_v6`; limite destro X 0.225, recessione aggiuntiva 0.012 tramite smoothstep da X 0.17. PNG nativo Blender 512×64 con separazioni grigie sfumate, UV esistenti e collegamento Base Color della terza superficie, incorporato nel GLB. Nessun override nuovo o modifica controller.

**Arcate V5:** stessa struttura V4, intervallo X [-0.135,0.245] e altezze 0.017/0.011 per superiore/inferiore; profili quadratici e UV continue conservati. HEAD_FILE preview/integrazione punta a `mouth_preview_v5`, controller e animazioni invariati.

**Revisione denti V4:** sostituisce le dodici corone V3 con due fasce continue campionate in 16 segmenti ciascuna. Profilo/profondità interpolati su tre ancore del taglio labiale reale; UV continue 0–1 per arcata, materiale bianco avorio uniforme. Preview/integrazione caricano `mouth_preview_v4`; movimento e override invariati. Nessuna texture nuova applicata.

**11/10/2026 — denti Bruno:** preview e integrazione caricano la variante head-only `mouth_preview_v3`, tre shape invariate e terza superficie con materiale avorio opaco incorporato. Dodici corone leggere generate nel medesimo mesh; sei inferiori seguono jaw_open e tutte seguono le espressioni additive. Superfici esterna/cavità e loro override conservati, controller voce invariato. V2 resta disponibile come riferimento.

**11/10/2026 — uscita e prop Fritz:** RegiaAlienExitDoor specializza solo l'uscita aliena, senza modificare door.gd/player.gd: cardine world +X (destro guardando verso l'uscita dal lato +Z), open_angle +90 verso +Z. Prima dell'apertura esamina posizione player/volume battente e verifica il movimento all'indietro con PhysicsServer3D.body_test_motion; arretra mediante CharacterBody3D.move_and_collide, ripristina lo stato precedente della fisica e apre solo a distanza sicura. Pausa sospende l'arretramento, morte/cambio scena lo interrompono; NetworkPuzzle.blocks_saving include retreating. Restore battente conserva l'adattatore/ID esistente e non sposta il player. FritzPowerAdapter è un Node3D solo visuale con scatolina/innesto sulla ciabatta e tubo Curve3D fino al connettore DC individuato nell'atlante (1350,1533)/1600. Sempre presente, indipendente da kit/collegamenti. PC scala 2.1, deposito (8.75,1.0657,4.90), display circa 0.5985×0.3717 m; innesti derivati dalla stessa scala. NetworkTerminal.camera_target usa gli assi scalati dello schermo anche per l'alieno; clic già in coordinate locali inverse della chiusura. Scorrevole conserva la logica, cambia soltanto la notifica chiave.

**Ciclo kit e documenti 3D:** RegiaNetworkState aggiunge charger_collected/laptop_shutdown/laptop_recovered; connect_charger consuma l'item, shutdown_laptop richiede sblocco, recover_laptop verifica capienze prima di restituire kit e cavo PC. Il vecchio snapshot con caricatore collegato implica charger_collected, senza modificare schema SaveManager. NetworkTerminal aggiunge Start/Arresta ed esce con GameplayUI dopo shutdown. PC runtime 2.5×, Y=PI, display circa 0.7125×0.4425 m; porte fisiche ai lati dal transform importato. Caricatore originale nascosto dopo pickup, adattatore nativo sul tavolo e due cavi alla ciabatta verificata building/root e al PC. RegiaBookReader crea volume copertine/fogli e SubViewport delle pagine, riusa texture degli oggetti, anima la sfogliatura; nessuna patch alle mesh originali. RegiaItemIcons assegna icone SVG native a ogni definizione registrata; RegiaItemVisuals e il viewer di ispezione condiviso mostrano key/cavo/caricatore/PC/racchetta in world 3D separato, con ritorno inventario.

**Revisione visiva regia:** `regia_router_view.gd` riusa il contratto terminale per zoom sul Fritz e restituzione dei comandi; inoltra esplicitamente i clic ai pulsanti perché GameplayUI consuma gli eventi prima della fase GUI. LED montati tramite coordinate UV sull'atlante originale del router, senza legenda nuova. Portatile ancorato a LAPTOP_POSITION sulla ScrivaniaRegia; cavi da Curve3D campionata con terminali. Desktop logico 1024×576 renderizzato a 1920×1080 con font MSDF, coordinate pointer/test aggiornate alla risoluzione effettiva. `regia_windows_wallpaper.gd` e `regia_desktop_icon.gd` disegnano grafica nativa. Glifi condivisi Sylfaen armeno e texture manico rigenerata; indici password e schema persistente invariati. InventoryItemPickup usa il modello key_with_tag normalizzato a 0.34 m; raccolta e ID restano invariati.

**Puzzle rete regia 10/10/2026:** RegiaIntegration crea NetworkPuzzle solo con addon presente. RegiaNetworkState separa regole da wrapper/visivi/UI. `main.regia.network` restore priority 30; `main.door.regia_exit` battente esistente. Portatile/item/cavi/configurazione/WiFi/racchetta/luci persistiti; Online/LED derivati, negoziazione 3 s. GameplayUI aggiunge open_puzzle_panel e ritorno inventario da esame; NetworkTerminal implementa il contratto camera_target/set_terminal_active/handle_pointer con requires_save_eligibility=false. ConnesiOS conserva il default can_save. Chiusura aliena figlia del battente, resta visibile dopo sblocco e si muove solidale; codice non ripetuto. [Nodi e contratti](REGIA_NETWORK_PUZZLE.md).

**SceneTransition condiviso, 10/10/2026:** load_scene(path, caption, show_loading) mostra prima la UI e carica PackedScene in thread; lascia copertura attiva al chiamante. transition_to cambia scena e attende inizializzazione; SaveManager usa lo stesso loader, ripristina inventario/player/partecipanti prima di reveal. Stage risorse 0–88, preparazione 90, ripristino 95, pronto 100; percentuale interpolata. PROCESS_MODE_ALWAYS e tween pausa PROCESS mantengono animazione durante restore. cancel_loading rilascia overlay e busy sugli errori. LoadingBlob disegna contorno deformabile e orbite; cornice e tema riusano inventario/menu.

**Collider player nella regia, 10/10/2026:** durante setup RegiaIntegration duplica la CapsuleShape3D del player e applica `player_passage_radius=0.35`, compatibile con i vani 0.795 m. Altezza e transizioni crouch conservate; player.tscn/player.gd invariati, altre scene mantengono default 0.4. La shape è locale all'istanza e ricostruita anche nel restore.

**Integrazione regia 10/10/2026:** `map_test/RegiaIntegration` → `regia_map_integration.gd` costruisce wrapper runtime delle tre porte/PC usando i visuali esistenti, aggiunge BossLootDrop e PersistentObject sui target reali. Mesh mobili e collider sotto AnimatableBody3D; frame fisso conservato. Creazione differita prima del restore; ID `main.*`, slot principale. Pannello regia e sei maniglie sotto pivot comune; SlidingKeyDoor ora accetta required_key vuoto. [Contratti e percorsi verificati](REGIA_MAP_INTEGRATION.md).

**Collisione Parete_013, correzione 10/10/2026:** `map_test/connesi_building_test2/Mura Interne Alte/Parete_013/StaticBody3D/CollisionShape3D` usa `resources/collision/parete_013_current.tres`, generata dalla mesh attuale. Il precedente concavo incorporato era geometricamente diverso e bloccava Bruno. Visiva/gruppi/transforms/navmesh/AI invariati. [Evidenze e generatore](BRUNO_PASSAGE_COLLISION.md).

**Integrazione bocca reale 10/10/2026:** `bruno_buozzi.tscn/MouthIntegration` scopre il controller intro il cui riferimento `bruno` coincide col parent; collega dialogue_player, boss_voice_player e BrunoDeathAudio sotto boss. Una sola istanza BrunoMouthMotion e un bus capture privato commutano voce con priorità morte > dialogo > combattimento, ripristinando routing precedente. Head V2 sostituita solo runtime, materiale/transforms originali mantenuti. Risata da animazione `laugh`, reazioni dolore/caduta/morte senza sorriso. Nessun nuovo segnale o modifica alla logica boss/cinematica.

**Bocca espressiva, revisione locale:** preview carica `mouth_preview_v2/bruno_head_mouth_preview.glb` (open/round/smile). Il controller audio pilota apertura e variazioni stilizzate; `laughing` attiva sorriso e apertura maggiore. Solo la preview imposta questo flag sul tempo 11.55 s della prima voce, verificato nel controller intro; non esiste riconoscimento automatico delle risate. Originale e precedente head-only conservati.

**Estensione isolata 10/10/2026:** [prova bocca Bruno](BRUNO_MOUTH_PREVIEW.md). `bruno_mouth_test.tscn` → `bruno_mouth_preview.gd` → istanza visuale del boss senza AI → nuova mesh head-only sul nodo originale `mixamorig_Head/output_unwrapped`. `BrunoMouthMotion` misura la voce su bus privato e pilota `mouth_open`; nessun collegamento nuovo alla cinematica reale.

Aggiornamento 08/10/2026: analisi statica locale e [baseline](BASELINE_SAFE_2026-10-08.md). Non è un audit completo di ogni nodo né un playtest.

## Avvio e sistemi globali

`project.godot` punta a `uid://cp2iy3c4fy8en`, risolto in `scenes/ui/boot.tscn`. `boot.gd` mostra i loghi e apre `scenes/ui/main_menu.tscn`; `main_menu.gd` avvia `scenes/maps/map_test.tscn`.

```mermaid
flowchart LR
    Boot --> Menu[Menu principale]
    Menu --> Mappa[map_test.tscn]
    Mappa --> Player
    Mappa --> HUD
    Mappa --> Ambiente
    Mappa --> Intro[Intro Bruno]
    Intro --> Boss[Combattimento Bruno]
    Player --> Armi
    Player --> Interazioni
    Armi --> Danni[Danni e impatti]
    Danni --> HUD
```

| Autoload | Risorsa | Responsabilità |
|---|---|---|
| SettingsManager | `scripts/systems/settings_manager.gd` | Settings persistenti, display, rendering, volumi |
| AudioManager | `scripts/systems/audio_manager.gd` | Bus, routing, musica menu |
| SceneTransition | `scripts/systems/scene_transition.gd` | Overlay, dissolvenze, caricamento threaded, cambio scena |
| PauseMenu | `scenes/ui/pause_menu.tscn` | Pausa, opzioni, ritorno menu |

Configurazione locale: feature Godot 4.7, fisica Jolt, driver Windows D3D12, viewport 1920×1080 e stretch `canvas_items`/`expand`. Godot 4.7.2 è riportato da README/PDF; eseguibile presente ma non avviato.

La mappa compone player/HUD, edificio, porte, TV/telecomando, impianto elettrico e insegna Connesi, scala, pickup, incendi/fumo, meteorite, intro Bruno, racchetta, boss, luci e ambiente combattimento. L'esistenza degli altri nemici e dei test VFX non dimostra che siano istanziati qui.

## Player, armi e impatti

`scripts/player/player.gd` estende `CharacterBody3D`: input, movimento, salute/morte, accovacciamento, passi e voce. Gruppo `player`. Riferimenti verificati: `Head`, `Head/Camera3D`, `Head/Camera3D/WeaponHolder`, `Head/Camera3D/InteractRay`, `CollisionShape3D`, `FootstepRay`, audio/timer passi. Leggere la scena prima di cambiarne la gerarchia.

| Comando | Input corrente |
|---|---|
| Movimento | WASD |
| Salto / sprint / accovacciamento | Spazio / Shift / Ctrl |
| Interazione | E |
| Sparo / ricarica | Mouse sinistro / R |
| Slot | 1–4; slot 4 gestito anche con controllo diretto del tasto |
| Torcia | F |
| Pausa | `ui_cancel` |
| Continua dopo morte | C, solo con file valido della scena corrente |
| Ricomincia dopo morte | N, sempre dall'inizio; file salvato conservato |

Predefiniti player: salute 100, velocità camminata 5, sprint 8, crouch 2,8. Il player inoltra i comandi al controller `scripts/weapons/weapon.gd`, che governa slot, possesso, munizioni, animazioni, audio, viewmodel, melee e batterie.

| Parametro predefinito nello script armi | Valore |
|---|---|
| Pistola | Danno 1, 4 colpi/s, caricatore 9, riserva 36 |
| SMG | Danno 4, 10 colpi/s, caricatore 30, riserva 120 |
| Melee | Danno 1, portata 1,6, cooldown 0,45 s |
| Torcia | Consumo 2/s, massimo 5 batterie di riserva |
| Muzzle flash | Durata 0,05 s |

Gli export possono essere sovrascritti nelle scene. Marker verificati in `scenes/player/player.tscn`: `PistolSocket/PistolMuzzleMarker` e `SMGSocket/SMGMuzzleMarker` sotto il rig braccia del viewmodel.

Pistola/SMG sono hitscan via `weapon_ray`, distinti dai proiettili di nemici/boss. Contratto danni: eventuale `try_dodge_shot(hit_point)`, quindi `take_bullet_hit(base_damage, hit_point)` o fallback `take_damage(amount)`; feedback hitmarker e numeri danno. Preservare l'eccezione al player nel raycast.

`spawn_bullet_impact()` usa `ImpactManager_Runtime`, gestore condiviso creato da `scripts/effects/impact_manager.gd`. Gli impatti leggono `surface_type` sul collider. I passi cercano invece gruppi `surface_rock`, `surface_tile`, `surface_parquet` su collider e antenati: preservare entrambi i contratti.

## Interazioni e scala

`scripts/systems/interaction_system.gd` risale dal collider ai genitori cercando `get_interaction_name()`, `get_interaction_action()` e `interact(player)`. Colore e focus sono opzionali: `get_interaction_color()` e `set_interaction_focus(enabled)`.

`scenes/ui/interaction_system.tscn` è montata nel player; ray path predefinito `../Head/Camera3D/InteractRay`. Il codice locale libera focus/prompt prima del pickup e sospende focus se `Interface` della HUD è nascosta: presente, runtime da confermare.

La scala usa `scripts/interactables/ladder.gd`: root `Node3D`, `InteractionBody/CollisionShape3D`, quattro `Marker3D` chiamati `BottomAttach`, `TopAttach`, `BottomExit`, `TopExit`. Layer interazione 2/mask 0, collider fisico separato. Marker riferiti ai piedi, uscite su pavimento solido fuori dai collider. Input/movimento FPS e collisioni vengono sospesi durante la salita e ripristinati all'uscita. [LEGGIMI_SCALA.txt](../LEGGIMI_SCALA.txt) conserva la procedura V1: verificarla contro il codice corrente, senza assumere che ogni istruzione storica sia ancora applicata.

## HUD e volto

`scripts/systems/hud.gd` aggiorna salute, arma, munizioni, batterie, missione, feedback, morte e boss; gruppo `hud`.

`HudFaceController` (`scripts/systems/hud_face_controller.gd`) estende `TextureRect` ed è collegato a `Interface/HudBar/FacePortrait` in `scenes/ui/hud.tscn`. Gruppo `player_face`, API `set_health(current,max)` e `react(name,severity)`. Immagini `assets/ui/face/stato1_1.png` … `stato4_20.png`.

Quattro stati con soglie predefinite 75/50/25%, 20 frame ciascuno. Priorità: idle 0, focus 30, pickup_small 50, pickup_major 60, hit 80, critical 100. Preservare l'interruzione da danno e l'anti-restart durante raffica SMG.

TESTATO UTENTE secondo PDF: pickup_major per pistola/SMG/torcia, pickup_small per munizioni/batteria accettata, determined per sparo, grunt per melee e dolore. `alert`/`focus` sono disponibili, non automaticamente collegati. `hit_random` non implementa danno direzionale reale. Tabella frame completa nella baseline.

## Nemici, Bruno e cinematica

`scenes/enemies/bruno_buozzi.tscn` usa `scripts/enemies/bruno_buozzi.gd`, `NavigationAgent3D`, stati cinematici/combat, racchetta, tennis/onda, scudo, percezione, anti-incastro, animazioni e tre segmenti salute.

Default script: `max_health=180`, headshot height 1,55/multiplier 2. La scena locale imposta `max_health=90` e `start_active=false`. La segmentazione usa `ceil(max_health/3)`. Leggere anche gli override mappa prima di concludere i valori runtime.

`scripts/cinematics/bruno_intro_controller.gd` gestisce camera/marker, TV e ducking, dialoghi, movimento/animazioni, blackout/rivelazione, blocco player, visibilità HUD e avvio boss. `scripts/vfx/bruno_fight_environment.gd` e `scripts/environment/bruno_boss_spotlight.gd` governano musica, luce e ripristino ambiente. Preservare i gruppi `bruno_intro_blocker` e `navigation_source`.

IA base: `scripts/enemies/enemy.gd`, rilevamento/memoria/LOS, inseguimento, melee, schivata e magie. Varianti Carloni e copie storiche vanno distinte dai riferimenti attivi prima di interventi o eliminazioni.

## Maglietta BetterBuozzi — aggiornamento 08/10/2026

Il corpo usa la nuova texture BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture_connesi.png tramite BetterBuozzi_connesi_material.tres, come surface_material_override/0 in scenes/enemies/bruno_buozzi.tscn sul nodo BetterBuozzi/Armature/GeneralSkeleton/Meshy_AI_Mutated_Tennis_Player_1004142620_texture. GLB e texture originale restano inalterati; il solo GLB conserva l'aspetto originale. La scritta è incorporata nelle UV e segue le animazioni senza nuovi nodi o script runtime. Parametri e verifiche nella [nota asset](BETTERBUOZZI_CONNESI_TEXTURE.md).

## Materiale dell'onda — aggiornamento 08/10/2026

L'onda attiva è assets/vfx/bruno_melee_banana3d/bruno_melee_banana3d.tscn. Core e Shell usano magical_waterball_fire_godot4.gdshader: superficie lilla con noise locale continuo, pulsazione 1,2 Hz / 18% e deformazione radiale 0,06 / velocità 0,8. Entrambi gli strati condividono fase e deformazione, attenuata alle estremità; il margine di culling 0,25 copre lo spostamento della configurazione corrente.

I parametri dissolve ed emission_boost mantengono il contratto del controller. La luminosità viene applicata all'ALBEDO HDR perché il render mode unshaded mostra direttamente quel colore. Nessuna modifica a traiettoria, crescita, durata, volume di danno o ostacoli. L'anteprima usa start_wave() con danno disabilitato.

## Impostazioni, audio e risorse

### Inventario e checkpoint — 10/10/2026

Tre autoload dopo SceneTransition: InventoryManager (Resource/quantità), SaveManager (slot/checkpoint/registro ID mondo), GameplayUI (inventario/PC/pausa/camera/input). Player/Weapon espongono get/apply_save_state; Bruno espone defeated e restore_defeated_state. Entrambi i menu offrono Carica; da morto C carica il file valido della scena, N avvia sempre da zero conservando il file, senza autosave.

`scenes/levels/inventory_save_test.tscn` allestisce player/HUD/Bruno/pickup reali con PC e porta prototipo; la mappa non istanzia ancora i nuovi componenti. PersistentObject adatta pickup/porte/evento/alimentazione/TV/ambiente; BossLootDrop registra sconfitta e chiave dinamica. SavePCStation usa SubViewport sul monitor e conversione ray → pixel per i clic. Identificatori, installazione, formato e verifiche nella [nota inventario e ConnesiOS](INVENTORY_SAVES_CONNESIOS.md).

Grafica attiva: InventorySkin con Theme/palette menu e BlobInventoryPanel con materiale privato dello shader boss_health_blob. IndustrialPanel non più referenziato. Card sopra HudBackground, coerente con Interface e nascosta in pausa; [I] INVENTARIO su una riga solo nei pickup. SVG chiave incorporato nella skin. SavePCStation conserva il desktop approvato; scena HUD/mappa inalterate.

select_scene_slot separa MAIN_SLOT user://savegame.cfg da TEST_SLOT user://inventory_save_test.cfg, preservando gli override dei test. La demo seleziona prima di creare il PC; menu iniziale torna al principale. read_checkpoint valida il contesto degli slot standard; has_scene_save confronta la scena per C/pausa. Load chiude PauseMenu con close_for_scene_change e cancella notifiche. Il checkpoint è assegnato prima di restore_completed, senza riassegnazione nella continuazione asincrona.

SettingsManager è la fonte centrale, archivio `user://settings.cfg`, segnale `settings_changed`; non ricaricare il file a ogni menu. Nel locale il player legge sensibilità dal file solo in `_ready()`, camera legge FOV dal manager; pausa aggiorna direttamente il FOV corrente ma non la sensibilità player. Vedere backlog.

| Bus | Destinazione | Livello impostato da AudioManager all'avvio |
|---|---|---|
| Music | Master | Volume opzioni |
| SFX | Master | Volume opzioni |
| Ambience | SFX | +2 dB |
| Player | SFX | −2 dB |
| Weapons | SFX | 0 dB |
| UI | Master | Volume opzioni |

Il manager imposta routing e livelli di categoria; il solo `default_bus_layout.tres` non descrive il mix runtime. Opzioni: 75% nominale, boost sopra. Stream/volumi armi e boss configurabili nell'Inspector.

Test: `scenes/levels/shooting_range.tscn`, `prototype_corridor.tscn`, `scenes/vfx_tests/`, diagnostica `scripts/debug/`. Non equivalgono a suite automatica già eseguita. Asset GLB ambiente, Blender/FBX e export possono essere solo locali: consultare stato/procedura per la riproducibilità.
