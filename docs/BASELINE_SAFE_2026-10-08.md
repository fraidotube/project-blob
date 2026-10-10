# Project Blob — baseline tecnica e storica del 08/10/2026

Fonte: [PDF originale](Project_Blob_Baseline_SAFE_2026-10-08.pdf), 10 pagine. Trascrizione integrale delle sezioni 0–17; tabelle, elenchi, frecce e interruzioni di pagina sono normalizzati per la lettura. I dati e le qualifiche di verifica sono quelli della fonte, non nuove verifiche del remoto. Gli aggiornamenti locali sono in [CURRENT_STATE.md](CURRENT_STATE.md).

Documento di continuità • fotografia verificata 8 ottobre 2026 • contratto SAFE Scopo: consentire a un nuovo agente o a una nuova chat di continuare lo sviluppo Godot/Blender senza perdere decisioni, introdurre nomi inventati o danneggiare sistemi funzionanti. Questo documento NON è un ordine di modifica né un’autorizzazione al push.

## 0. Lettura obbligatoria: livelli di verifica

| Etichetta | Significato |
|---|---|
| VERIFICATO GITHUB | Presenza, contenuto o valore accertato nel repository sul commit indicato. Non equivale a prova in esecuzione. |
| TESTATO UTENTE | Funzionamento confermato dall’utente in Godot nel corso dello sviluppo. |
| STORICO | Dato proveniente dai riepiloghi o dalle conversazioni precedenti, non riverificato nello stato corrente. |
| LOCALE NON PUSHATO | File o modifica segnalata localmente, non presente nel commit remoto verificato. |
| APERTO / NON VERIFICATO | Implementazione incompleta, risultato incerto, necessità di ulteriore ispezione. |

## 1. Contratto operativo SAFE — vincolante

- Usare sempre milestone e baseline funzionanti; verificare stato reale prima di interventi rilevanti.

- Una modifica alla volta, quando possibile; diagnosi → intervento singolo → test → consolidamento.

- Prima di modificare uno script .gd, leggere la versione reale corrente dal GitHub o dal file locale. Se locale e GitHub differiscono, fermarsi e confrontare.

- Quando si consegna un .gd, fornire il FILE COMPLETO, mai diff o frammenti da incollare.

- Mai git add . oppure git add -A; effettuare staging esclusivo dei path scelti, ispezionare git diff --cached.

- Nessun commit o push autonomo. Sono decisioni dell’utente.

- Non inventare path, nomi di nodi, segnali, scene, animazioni, proprietà, metodi o collegamenti. Se non risultano verificati, dichiararlo.

- Non usare script PowerShell/Python per patch automatiche ai file del progetto.

- Non rompere player/FPS, HUD, porte e interazioni, pickup, pistola, SMG, torcia, audio, VFX, AI, Bruno, cinematic, HUD boss e ambienti.

- Non sostituire deliberatamente la geometria visiva dell’edificio durante ottimizzazioni fisiche.

- Non presumere che un file GitHub rappresenti tutte le modifiche locali; l’utente decide la direzione.

## 2. Coordinate di lavoro e baseline

| Elemento | Riferimento verificato / storico |
|---|---|
| Repository | fraidotube/project-blob |
| Branch | dev/prototype-0.1 |
| HEAD GitHub (08/10/2026) | e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c |
| Messaggio commit | Complete HUD face reactions for flashlight and battery pickups |
| Data commit UTC | 2026-10-08 18:15:25Z |
| Cartella Windows (storico) | D:\ProjectBlob\Game |
| Godot (storico) | D:\ProjectBlob\Tools\Godot\Godot_v4.7.2-stable_win64.exe |
| Albero GitHub | 1.838 file di tipo blob, 80 script .gd, inventario ricorsivo non troncato |
| Scena mappa GitHub | scenes/maps/map_test.tscn — 53.845.966 byte |
| Scena locale allegata in chat | map_test(20261008-172609).tscn — fotografia antecedente alle ultime rimozioni |
| Ottimizzazione locale dichiarata | ~25 MB dopo rimozione di collisioni della torre; NON verificata su GitHub |

ATTENZIONE: la baseline del codice e la baseline della mappa non coincidono necessariamente. Prima di intervenire sulla mappa chiedere il .tscn corrente oppure controllare la working directory. Il vecchio prototipo 0.1B porta funzionante è parte della storia, ma l’elenco completo di commit/tag antecedenti non è ricostruito qui e non viene inventato.

## 3. Evoluzione storica dello sviluppo

### Concept e avvio

FPS aziendale goliardico: meteorite/blob alieno nei pressi della sede Connesi; contagio e mutazione di dipendenti/colleghi. Godot per il gioco, Blender per i modelli, Git per la cronologia. Logo Fraidosoft e titolo Project Blob.

### Prototipo interazione 0.1B

Player FPS, WASD, salto e sprint, porte interattive, puntamento e prompt. Baseline/tag 0.1B storicamente dichiarato. Sensibilità mouse inizialmente troppo bassa, successivamente oggetto di lavoro.

### Combattimento

Pistola in prima persona con animazioni asset Kuptchi, munizioni, rinculo, hitmarker, danno, muzzle flash e impatti. SMG aggiunta e validata con fuoco automatico, pickup munizioni e audio sovrapposto.

### Ambienti

Modello edificio Connesi importato da Blender/GLB. Scena test esterna notturna: sky, illuminazione, nebbia e torcia. Vincolo: mantenere nebbia all’esterno, ridurla/eliminarla negli interni della versione definitiva.

### Interfaccia

HUD responsive con barra salute, armi, munizioni, crosshair, volto animato e HUD boss. Quattro stati grafici del volto, 20 immagini ciascuno.

### Boss Bruno

Nemico tennista mutato con intro cinematografica, dialoghi, navigazione, fasi salute, attacchi da tennis/onda blob, condizioni speciali di combattimento, luci, audio e HUD a fasi. Le prove dell’onda blob hanno risolto il movimento discontinuo; velocità, ampiezza, danno e shader restano punti da verificare nella mappa definitiva.

### Ottimizzazione mappa

Scoperto peso anomalo della scena test dovuto soprattutto a risorse geometriche incorporate/collisioni concave. Un’analisi puntuale ha individuato grandi blocchi nella torre radio; dopo rimozioni locali l’utente riferisce circa 25 MB.

### Ottobre 2026: volto HUD

Collegati eventi raccolta pistola, SMG, munizioni di entrambi, torcia e batterie; espressioni durante pistola, raffica SMG e corpo a corpo. L’utente ha testato e confermato il funzionamento, con push sul branch.

## 4. Architettura ad alto livello

Catena di gioco verificata da script: player.gd gestisce input, movimento, salute, voce e inoltra i comandi a weapon.gd. weapon.gd governa equipaggiamento, proiettili hitscan via raycast, attacchi, animazioni, munizioni e feedback. hud.gd aggiorna gli indicatori. hud_face_controller.gd reagisce semanticamente via gruppo player_face. interaction_system.gd individua gli interactable, che espongono interact(player). I nemici implementano take_bullet_hit()/take_damage(), mentre impact_manager.gd centralizza feedback per superficie. La scena map_test.tscn compone ambienti e istanze; non è sicuro dare per scontato che ogni script nell’inventario sia attivamente istanziato.

## 5. Player, input, salute e movimento

VERIFICATO GITHUB: scripts/player/player.gd (749 righe): _unhandled_input, _physics_process, _update_crouch, _can_stand_up, suoni passi/salto/atterraggio per superfici, respirazione sprint, suoni

vocali per danno e morte. max_health=100. Metodi equip_pistol(), equip_smg(), equip_flashlight(), add_ammo(), add_smg_ammo(), add_flashlight_battery(), take_damage(), die(). L’input fire raggiunge weapon.fire(). Il player consulta i dati del materiale/superficie per i passi; qualsiasi cambio ai collision body e metadata va testato anche acusticamente. scene: scenes/player/player.tscn. Script ausiliari: scripts/player/camera_settings.gd, indoor.gd e viewmodel_depth_override.gd. Le dinamiche esatte di ogni riferimento e lo stato della regolazione del mouse vanno verificati nelle scene, evitando di assumere nodi non letti.

## 6. Armi, munizioni, attacchi e proiettili

| Tipo | Valori verificati nello script weapon.gd |
|---|---|
| Pistola | Danno 1, fire_rate=4 colpi/s, caricatore 9, riserva iniziale 36 |
| SMG | Danno 4, smg_fire_rate=10 colpi/s, caricatore 30, riserva iniziale 120 |
| Corpo a corpo | Danno 1, portata 1,6 m, cooldown 0,45 s |
| Torcia | Consumo 2 unità/s; batteria/equipaggiamento con riserva massima 5 |
| Muzzle flash | OmniLight3D spostata al marker arma; durata esposta 0,05 s |
| Impatto | Raycast del weapon controller + manager separato di decal/audio materiali |

Script cardine: scripts/weapons/weapon.gd, 2.151 righe nel commit verificato. Metodi principali: fire(), attack_unarmed(), perform_melee_hit(), fire_pistol(), fire_smg(), _apply_pistol_hit(), _apply_smg_hit(), _show_damage_feedback(), spawn_bullet_impact(), reload(), reload_smg(), select_weapon_slot(), equip_*(), _update_smg_automatic_fire(). Lo sparo non è un proiettile fisico in ogni caso: per pistola e SMG la logica di impatto è basata sul raycast. NON confondere con i proiettili di nemici/boss che hanno scene e script propri. Sistema danni: i nemici supportano take_bullet_hit(), con fallback take_damage(), e feedback HUD hitmarker/damage number. SMG con sovrapposizione audio degli spari. Richiami HUD volto: determined nello sparo pistola e SMG con controllo anti-restart durante la raffica; grunt per il corpo a corpo. Ultima modifica verificata su GitHub. Marker di arma storicamente registrati: PistolSocket/PistolMuzzleMarker e SMGSocket/SMGMuzzleMarker lungo il rig FP; NON ricostruire percorsi completi senza verificare scena attuale.

## 7. Pickup e interazioni

Script: scripts/systems/interaction_system.gd e scenes/ui/interaction_system.tscn, più scripts/interactables/* e scripts/pickups/*. Oggetti validi espongono funzioni get_interaction_name(), get_interaction_action(), get_interaction_color() e interact(player). Evidenziamento mediante materiale overlay shader interactable_outline_screen.gdshader. I pickup impediscono doppie raccolte tramite collected e controllano metodi player.

| Pickup | Script | Reazione volto confermata |
|---|---|---|
| Pistola | scripts/pickups/pistol_pickup.gd | pickup_major → frame 13 |
| SMG | scripts/pickups/smg_pickup.gd | pickup_major → frame 13 |
| Munizioni pistola | scripts/pickups/ammo_pickup.gd | pickup_small → frame 8 |
| Munizioni SMG | scripts/pickups/smg_ammo_pickup.gd | pickup_small → frame 8 |
| Torcia | scripts/pickups/flashlight_pickup.gd | pickup_major → frame 13 |
| Batteria | scripts/pickups/battery_pickup.gd | pickup_small → frame 8, solo se accettata |

BUG storico: durante intro cinematic la HUD principale viene nascosta, ma il prompt interazione riappariva al frame successivo perché l’interaction ray ritrovava il telecomando. La proposta era sospendere aggiornamento focus quando Interface nascosta; nel riepilogo storico il test/push non risultava confermato. Non dichiararlo risolto senza prova. Durante la cinematic di Bruno la HUD è nascosta: non ha senso mostrare frame alert senza cambiare deliberatamente il disegno della cinematic.

## 8. HUD classica, salute e volto animato

scripts/systems/hud.gd (1.199 righe): update_health(), update_ammo(), update_flashlight_battery(), update_weapon(), update_mission(), show_hitmarker(), show_damage_number(), show_damage_flash(), show_death_screen(), show_boss_hud(), update_boss_hud(), hide_boss_hud(). La barra boss ha texture/colori dedicati alle tre fasi e tween di ricarica fra fasi: non ricostruire una HUD nuova. Volto: scripts/systems/hud_face_controller.gd (1.017 righe), attaccato al TextureRect FacePortrait nella gerarchia HUD/Interface/HudBar/FacePortrait (dato storico). Le immagini sono res://assets/ui/face/stato1_1.png … stato4_20.png: quattro stati salute × 20 pose = 80 asset. Il controller

carica texture, gestisce idle casuale, sequenze di reazione, priorità, interruzioni e ripresa. API pubbliche set_health(current,max), react(name,severity). Gruppo Godot: player_face.

| N. frame | Significato |
|---|---|
| 1–5 | Neutro, guarda sinistra, destra, in alto, in basso |
| 6–7 | Respiro, tensione |
| 8 | Pickup leggero |
| 9–10 | Colpito da sinistra/destra |
| 11–12 | Smorfia lieve, respiro teso |
| 13 | Pickup importante |
| 14–16 | Colpito frontale, dolore intenso, rabbia dopo colpo |
| 17–18 | Sorpresa/allerta, concentrazione |
| 19–20 | Grugnito, determinazione intensa |

API disponibili definite: hit_left, hit_right, hit_front, pain, angry_after_hit, pickup_small, pickup_major, alert, focus, grunt, determined; hit_random sceglie SX/DX perché il danno direzionale reale non è ancora implementato. Priorità numeriche: idle 0, focus 30, pickup_small 50, pickup_major 60, hit 80, critical 100. Non confondere “reazione definita” con “evento gameplay collegato”. alert/focus sono disponibili per futuri eventi visibili a HUD.

## 9. Audio: routing, suoni e ambienti

scripts/systems/audio_manager.gd (299 righe) espone _ensure_audio_buses(), _configure_audio_routing(), play_menu_music(), fade_out_menu_music(), route_current_scene_audio() e strumenti debug. weapon.gd possiede stream configurabili Inspector per sparo/ricarica/arma vuota/pronta di pistola e SMG, volume dedicato e bus Weapons; l’audio SMG

può sovrapporsi. player.gd contiene suoni passi distinti parquet, piastrelle, roccia, corsa, salto, atterraggio, danno, morte e respiro sprint. door.gd espone open_sound/close_sound. bruno_intro_controller.gd gestisce audio TV, dialoghi, musica/effetti cinematic e ducking. bruno_fight_environment.gd gestisce musica boss, ripristino ambiente e audio morte. Non assumere che Master, Weapons e ogni altro bus siano identici in locale senza leggere project.godot/default_bus_layout: la presenza del bus Weapons è documentata, la configurazione completa non è inventariata in questo documento.

## 10. Nemici, AI e Bruno boss

scripts/enemies/enemy.gd (816 righe): IA base con rilevamento, memoria player, inseguimento, linea

di vista, attacchi jab/cross, schivata, attacco magico/proiettile e gestione vita. Valori esportati di questa classe includono max_health=100, attack_damage_jab=12, attack_damage_cross=20 e spell_damage=18. Esistono varianti del nemico in scripts/enemies/dr_carloni_enemy*.gd, da distinguere dal nemico istanziato realmente. Bruno: scenes/enemies/bruno_buozzi.tscn e scripts/enemies/bruno_buozzi.gd (4.473 righe). max_health=180, tre fasi da 60 HP descritte nel lavoro sulla HUD boss; headshot_height=1,55 m e headshot_multiplier=2,0; percorsi, velocità per fase, rilevamento, ricerca, navigazione, collider più stretto e anti-incastro sono configurabili. Presenti stati cinematografici e combattimento, scudo, attacchi tennis/racchetta, onde/attacchi speciali. NON riscrivere/semplificare arbitrariamente questo

script molto ampio. Cinematic: scripts/cinematics/bruno_intro_controller.gd (2.450 righe), camera multipunto, markers, televisore, flicker/blackout/rivelazione, dialoghi e animazioni temporizzate. Ambiente boss: scripts/vfx/bruno_fight_environment.gd, scripts/environment/bruno_boss_spotlight.gd, oltre a materiali/scene scudo. Esistono gruppi bruno_intro_blocker e navigation_source nella mappa: da preservare. VFX principali sotto assets/vfx/bruno_melee_* e scene test sotto scenes/vfx_tests/. L’onda blob ha avuto iterazioni per eliminare l’effetto di comparsa a distanza; il movimento è stato approvato in prova, ma danni/shader/ampiezza definitivi richiedono verifica.

## 11. Collisioni, scena mappa e Blender

Visuale: edificio GLB dettagliato res://assets/models/environment/connesi_building_test2.glb, costruito/editato in Blender. Fisica: preferire BoxShape3D/collider semplici dove bastano; usare collisioni mesh-accurate solo per geometria che le richiede. Conservare pavimenti, muri, scale e superfici gameplay, metadati surface_type e gruppi funzionali. Verificare ogni modifica giocando e misurando i byte della scena. Storia pesi: una prima scena era circa 53,85 MB (212 ConcavePolygonShape3D); successive rimozioni

avevano portato il file intorno a 40,76 MB (114 concave). Un’analisi per byte ha smentito che le scrivanie fossero necessariamente il principale responsabile: blocchi della torre radio risultavano fra i maggiori. Il file allegato map_test(20261008-172609).tscn fotografava uno stato intermedio di circa 35,5 MiB; l’utente successivamente riferisce circa 25 MB dopo ulteriori interventi sulla torre. Questi valori descrivono copie in momenti differenti: NON vanno trattati come tag Git verificati. Nuova stanza: sviluppo in Blender di uffici, magazzini, bagno, rack e scaffali; ricerca di modelli scaricabili. Prima di importare: scala coerente, mesh separabili, controllo poligoni/texture/materiali; NON aggiungere indiscriminatamente collisioni trimesh a ogni pezzo di arredo.

## 12. Menu, impostazioni, transizioni e altri sistemi

scripts/ui/boot.gd, main_menu.gd, pause_menu.gd, game_settings.gd, menu_button.gd, menu_style_manager.gd governano flussi UI. scripts/systems/settings_manager.gd gestisce settings_changed, load/save/apply, audio, display e rendering. scripts/systems/scene_transition.gd fornisce cover_black(), reveal(), transition_to(). Scripts ambiente: exterior_lamp_controller, lamp_flicker, smoke_stack, fire_wall_3d; scripts/hazards/fire_damage_zone e smoke_cough_zone; scripts/interactables/door, ladder, interruttore, tv_controller, tv_remote, connesi_power e connesi_meter. La presenza di script dimostra esistenza in repo, non che siano tutti presenti nella mappa o già testati.

## 13. Inventario completo degli script .gd nel commit verificato

Elenco dei 80 path risultanti dall’albero GitHub del commit e5ff3c8; include backup, esperimenti, plugin e varianti non necessariamente attive. NON dedurre da questi nomi che il codice venga eseguito in runtime.

- `assets/models/animations/FlameFXFree/FlameFX/script/VFXFireBB.gd`
- `assets/models/animations/FlameFXFree/shared/script/VFXEmitterBB.gd`
- `assets/models/animations/FlameFXFree/shared/script/VFXOmniLightBB.gd`
- `assets/models/animations/GodotLootVFX/loot_effects/src/script/vfx_loot.gd`
- `assets/models/animations/GodotLootVFX/shared/script/vfx_effect.gd`
- `assets/models/weapons/kuptchi/pistol_viewmodel.gd`
- `assets/vfx/bruno_melee_banana3d/bruno_melee_banana3d.gd`
- `assets/vfx/bruno_melee_slash/bruno_melee_slash.gd`
- `assets/vfx/bruno_melee_wave/bruno_melee_wave.gd`
- `assets/vfx/bruno_melee_wave3d/bruno_melee_wave3d.gd`
- `scenes/enemies/spell_projectile.gd`
- `scenes/vfx_tests/bruno_melee_banana3d_debug_test.gd`
- `scenes/vfx_tests/bruno_melee_banana3d_test.gd`
- `scenes/vfx_tests/bruno_melee_slash_fire_test.gd`
- `scenes/vfx_tests/bruno_melee_wave3d_test.gd`
- `scenes/vfx_tests/bruno_melee_wave_test.gd`
- `scenes/vfx_tests/explosion_pb47_test.gd`
- `scenes/vfx_tests/explosion_vfx_test.gd`
- `scenes/vfx_tests/explosion_vfx_test_v2.gd`
- `scripts/audio/meteorite_audio_trigger.gd`
- `scripts/cinematics/bruno_intro_controller.gd`
- `scripts/debug/shooting_range_diagnostics.gd`
- `scripts/debug/shooting_range_impact_preview.gd`
- `scripts/effects/bullet_impact.gd`
- `scripts/effects/impact_manager.gd`
- `scripts/enemies/bruno_buozzi.gd`
- `scripts/enemies/dr_carloni_enemy.gd`
- `scripts/enemies/dr_carloni_enemy_2.gd`
- `scripts/enemies/dr_carloni_enemy_old.gd`
- `scripts/enemies/dr_carloni_enemy_oldiss.gd`
- `scripts/enemies/dsds.gd`
- `scripts/enemies/enemy.gd`
- `scripts/enemies/hammer_flight.gd`
- `scripts/enemies/spell_projectile.gd`
- `scripts/enemies/tennis_ball_projectile.gd`
- `scripts/environment/bruno_boss_spotlight.gd`
- `scripts/hazards/fire_damage_zone.gd`
- `scripts/hazards/smoke_cough_zone.gd`
- `scripts/interactables/connesi_meter.gd`
- `scripts/interactables/connesi_power.gd`
- `scripts/interactables/connesi_sign_light.gd`
- `scripts/interactables/door.gd`
- `scripts/interactables/interruttore.gd`
- `scripts/interactables/ladder.gd`
- `scripts/interactables/tv_controller.gd`
- `scripts/interactables/tv_remote.gd`
- `scripts/pickups/ammo_pickup.gd`
- `scripts/pickups/battery_pickup (1).gd`
- `scripts/pickups/battery_pickup.gd`
- `scripts/pickups/flashlight_pickup.gd`
- `scripts/pickups/pistol_pickup.gd`
- `scripts/pickups/smg_ammo_pickup.gd`
- `scripts/pickups/smg_pickup.gd`
- `scripts/player/camera_settings.gd`
- `scripts/player/indoor.gd`
- `scripts/player/player.gd`
- `scripts/player/viewmodel_depth_override.gd`
- `scripts/systems/audio_manager.gd`
- `scripts/systems/hud.gd`
- `scripts/systems/hud_BACKUP_PRE_NEW_HUD.gd`
- `scripts/systems/hud_face_controller.gd`
- `scripts/systems/interactable_outline_proxy.gd`
- `scripts/systems/interaction_system.gd`
- `scripts/systems/scene_transition.gd`
- `scripts/systems/settings_manager.gd`
- `scripts/tools/interaction_outline_builder.gd`
- `scripts/ui/boot.gd`
- `scripts/ui/game_settings.gd`
- `scripts/ui/main_menu.gd`
- `scripts/ui/menu_button.gd`
- `scripts/ui/menu_style_manager.gd`
- `scripts/ui/pause_menu.gd`
- `scripts/vfx/bruno_fight_environment.gd`
- `scripts/vfx/exterior_lamp_controller.gd`
- `scripts/vfx/fire_wall_3d.gd`
- `scripts/vfx/lamp_flicker.gd`
- `scripts/vfx/smoke_stack.gd`
- `scripts/vfx/smoke_stack_before_soft_edges.gd`
- `scripts/weapons/flashlight_beam_follow.gd`
- `scripts/weapons/weapon.gd`

## 14. Prove, diagnosi e criticità storiche

- Prototype 0.1B: porta interattiva e movimento base con commit/tag storico; sensibilità mouse da regolare nella fase successiva.

- Armi: smg testata su Bruno: danni, hitmarker, numero danno, audio, muzzle flash e impatti confermati dall’utente.

- Onda Bruno: difetto iniziale di movimento non continuo/salto apparente tra origine e destinazione; scena diagnostica dedicata; traiettoria successivamente approvata.

- HUD volto: idle, soglie quattro livelli, dolore, pickup, pistola, raffiche SMG e melee tutti provati; il controller gestisce la priorità del danno.

- HUD boss: barra unica per tre fasi cromatiche verde/giallo/rosso, refilling; script attuale espone logica visuale; parametri salute nella scena vanno controllati prima di cambiare.

- Mappa: diffidare di analisi basate solo sul numero delle collisioni. Classificare ogni sub_resource

per byte e risalire al nodo. Le scrivanie NON sono state dimostrate causa principale.

- Cinematic HUD: prompt interazione che ricompare durante cutscene; soluzione proposta ma stato conclusivo non certificato.

- Collisioni: collisioni dettagliate di torre, veicoli, terreno e arredi incidono sul peso; ogni categoria va testata isolatamente prima del successivo intervento.

## 15. Backlog ragionato e priorità attuali

- Prossima attività scelta dall’utente: ritorno a Blender per completare nuova stanza dell’edificio; importare arredi e materiali.

- Verificare e consolidare separatamente la scena mappa alleggerita a circa 25 MB (non confondere con Git remoto).

- Rifiniture Bruno/onda blob: velocità, ampiezza, shader, danno e prove in arena reale.

- Nuovi ambienti, NPC, altri boss e mutanti.

- Integrazione eventuale alert/focus HUD per eventi visibili durante gameplay (non intro di Bruno: HUD nascosta).

- Verificare prompt interaction HUD durante cinematic; non dichiarare bug risolto prima del test.

- Gestione nebbia solo esterna e ambienti interni, illuminazione notturna, torcia.

- Ulteriori animazioni/ricariche, menu e controlli: valutare contro la baseline prima di intervenire.

## 16. Procedura di consegna a un nuovo agente

Prima azione obbligatoria: leggere questo documento, non scrivere codice. Seconda: verificare branch, HEAD, git status --short e stato delle modifiche locali. Terza: scegliere CON L’UTENTE un solo

obiettivo. Quarta: leggere integrali gli script e le scene coinvolti, identificare richiami/nomi reali, elaborare diagnosi; solo allora proporre la modifica. Quinta: consegnare file .gd completi o istruzioni

di editing manuale concordate; non applicare patch automatiche. Sesta: test in Godot e conferma esplicita dell’utente. Settima: staging path espliciti, verifica diff cached, commit e push soltanto su richiesta. PROMPT CORTO DI CONTINUITÀ: «Stiamo continuando Project Blob, Godot + Blender, repo fraidotube/project-blob branch dev/prototype-0.1. Applica il contratto SAFE di questo documento integralmente. Non inventare nulla; leggi GitHub e i file locali reali; fai una modifica per volta, consegna .gd completi, verifica con l’utente, non committare/pushare autonomamente. Lo stato del codice sul commit e5ff3c8 include HUD volto, armi, pickup e Bruno; la mappa locale alleggerita a ~25

MB non è comprovata sul remoto. Il prossimo lavoro scelto è Blender/nuova stanza.»

## 17. Limiti consapevoli della ricostruzione

Inventario script ottenuto da tree GitHub; analizzati nel dettaglio i controller principali, non ogni riga di tutti i 80 script né ogni collegamento Inspector nei file .tscn. Non sono stati eseguiti Godot, Blender o playtest automatici. I test etichettati TESTATO UTENTE derivano dalle conferme esplicite riportate durante lo sviluppo. Le modifiche locali alla mappa dopo l’ultimo caricamento non sono disponibili qui. Lo stato dei tag storici non è stato ricostruito integralmente. La struttura node-by- node dell’intero map_test e la rete completa delle dipendenze esterne richiederebbero audit dedicato; non vengono simulati.

