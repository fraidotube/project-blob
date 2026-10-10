# Project Blob — stato locale

## Punto di ripresa confermato — 10/10/2026

**Consolidamento Git richiesto:** commit locale autorizzato dall'utente per codice, scene e risorse Godot testuali, UID e Markdown. Esclusi binari, modelli, texture/audio, PDF, cache e cancellazioni SilverDelivery. Questa baseline conserva l'integrazione ma dipende dagli asset locali esclusi; non è un backup completo esportabile su un altro PC. Hash definitivo verificabile con git log e registro commit. Nessun push richiesto.

**Commit creato:** 5b3267e — Consolidate inventory saves, regia integration and Bruno presentation, 107 file testuali. Baseline di sviluppo locale sul branch dev/prototype-0.1; segue registrazione documentale del risultato. Asset esclusi e cancellazioni SilverDelivery restano fuori commit; nessun push.

Utente: «ok ci siamo» dopo pulizia schermata caricamento. **TESTATO UTENTE: resa finale caricamento approvata**, blob centrale conservato, nessuna striscia decorativa a sinistra/in alto. Nuova partita e Carica condividono loader; immagini Carica collegate nei menu, Nuova partita sopra Carica. Queste attività sono completate: non riproporre integrazione asset o revisione bocca/porte/caricamento.

Mappa: bocca Bruno e passaggi confermati; chiave/drop, tre porte e PC ConnesiOS integrati. Suite inventario/save, restore mappa in processo nuovo e GPU loader passate. Rimane da confermare esplicitamente il playtest completo manuale del salvataggio nella mappa: Salva al PC, Carica da pausa/menu, morte C/N e riavvio applicazione. HUD inferiore rinviata a un obiettivo successivo scelto dall'utente.

Branch dev/prototype-0.1, HEAD e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c; staging vuoto, nessun commit/push. Molti file/asset sono locali non tracciati: conservare questa working directory, verificare Git e file reali alla ripresa. Le voci sottostanti sono aggiornamenti cronologici storici: le indicazioni «ancora da collegare» o «conferma estetica aperta» sono superate da questo punto di ripresa.

**Pulizia caricamento, 10/10/2026:** animazione centrale approvata dall'utente. Rimossi accenti laterali e striscia blob superiore dal solo caricamento; cornice, animazione centrale e avanzamento conservati. Inventario mantiene le proprie decorazioni.

**Caricamento unificato, 10/10/2026:** utente conferma funzionamento immagini menu. Nuova partita e Carica salvataggio ora condividono SceneTransition con caricamento threaded, pannello scuro/viola, blob deformabile e bolle ciano, barra interpolata e dissolvenze. SaveManager mantiene copertura e pausa fino al ripristino completo; demo e slot principale conservati. Nuova resa verificata GPU; playtest estetico utente ancora da ricevere. Le note precedenti su immagini da collegare sono storiche e superate.

**Menu Carica salvataggio collegato, 10/10/2026:** immagini utente normale/blob ora associate in `menu_button.gd`, usate sia nel menu iniziale sia nella pausa. Menu iniziale: Nuova partita sopra Carica salvataggio (poi Opzioni/Esci). Verifica runtime texture e ordine passata; conferma estetica utente aperta. Logica caricamento/abilitazione/slot conservata; non resta da implementare il collegamento indicato nella precedente chiusura.

**Chiusura confermata dall'utente, 10/10/2026:** «perfetto ora funziona» dopo correzione attraversamento scorrevole: **TESTATO UTENTE per il passaggio**, senza dedurre prove specifiche di salvataggio/C/N/riavvio. Prossima sessione: usare nei menu i nuovi asset utente `assets/ui/caricasalvataggio.png` e `assets/ui/caricasalvataggio_blob.png`, nello stile degli altri pulsanti. Entrambi presenti localmente; non ancora collegati da questa chiusura documentale. Ripartire dalla nota regia e dall'ultima sessione. Bocca Bruno e passaggi confermati; porte/PC/persistenza integrati e testati automaticamente, playtest completo del salvataggio nella mappa ancora da confermare.

**Attraversamento scorrevoli, 10/10/2026:** blocco utente con porta aperta riprodotto come urto sugli stipiti, vano circa 79.5 cm e capsula player larga 80 cm. `regia_map_integration.gd` ora usa una shape privata con raggio 35 cm per questa mappa; nessuna patch al controller/scena player o alla visiva delle porte. Nuovo test fisico `sliding_passage_test.gd`; prova F8/F6 e attraversamento reale richiesti. [Nota](REGIA_MAP_INTEGRATION.md).

**Regia integrata nella mappa, 10/10/2026:** sui path indicati dall'utente, scorrevole laboratorio DX→SX con chiave, scorrevole bagno libera, battente regia con pannello/maniglie solidali e PC reale ConnesiOS. Drop finale Bruno e stato di porte/pickup/alimentazione/TV/evento/ambiente collegati a SaveManager; slot principale distinto dalla demo. Test mappa salvataggio/restore e GPU click monitor passati; regressioni demo e passaggio Bruno passate. Playtest utente della nuova integrazione aperto. [Nodi, modifiche e procedura](REGIA_MAP_INTEGRATION.md).

**Ultimo riscontro/obiettivo, 10/10/2026:** «ok ci siamo» dopo correzione collider: passaggio Bruno confermato dall'utente. Ora integrazione chiave/drop boss, porta scorrevole con chiave e PC/salvataggi nella mappa, più scorrevole bagno regia senza chiave e porta a battente regia. Utente offre di identificare mesh/pivot; richiesti nomi/path esatti delle porte e monitor. Nel GLB rilevati PCRegia, Porta Bagno Regia, Porta Regia e Porta Regia.001: assegnazione funzionale ancora da indicare, nessun collegamento presunto. Componenti esistenti ispezionati; integrazione tecnica non ancora applicata.

**Correzione passaggio Bruno, 10/10/2026:** bocca confermata funzionante dall'utente nella mappa. Blocco movimento riprodotto anche senza bocca; collider incorporato Parete_013 non corrisponde alla mesh corrente. Rigenerata solo quella forma in `resources/collision/parete_013_current.tres`, collegata nella mappa; AI/collider boss/navmesh/visiva conservati. Test sul punto finale intro: Bruno supera il blocco, failures=0. Playtest completo utente ancora aperto. [Diagnosi e ripresa](BRUNO_PASSAGE_COLLISION.md).

**Bocca collegata alla scena reale, 10/10/2026:** V2 approvata dall'utente («ok ci siamo»). Nuovo componente `MouthIntegration` nella scena boss collega dialoghi della cinematica, frasi/reazioni in combattimento e audio sconfitta. Mappa eredita il componente; controller gameplay/intro/ambiente e file mappa preservati. Prossimo playtest utente su `scenes/maps/map_test.tscn`, poi porta scorrevole/chiave/PC e salvataggi. [Collegamenti e prove](BRUNO_MOUTH_PREVIEW.md).

**Revisione bocca espressiva 10/10/2026:** richiesta attiva completata nella preview: maggiore apertura nel parlato, shape aggiuntive arrotondata/sorriso, risata più ampia dal riferimento temporale originale 11.55 s. Asset nuovi `mouth_preview_v2`, variante approvata precedente conservata. F6 sulla stessa scena; Spazio parlato/risata, L risata, M e 3/4 forme manuali. Conferma utente della nuova resa aperta; [nota aggiornata](BRUNO_MOUTH_PREVIEW.md). Integrazione PC/chiave/salvataggi nella mappa rimane il successivo obiettivo concordato.

**Obiettivi di ripresa concordati:** oltre a terminare la bocca di Bruno, integrare nella scena principale i sistemi già provati separatamente: PC ConnesiOS/salvataggio, inventario, chiave droppata alla morte finale di Bruno e porta scorrevole. Leggere [la procedura di collegamento](INVENTORY_SAVES_CONNESIOS.md), identificare i nodi reali della mappa e procedere SAFE; poi provare salvataggio/caricamento, morte C/N e persistenza nella mappa. Richiesta registrata per la prossima sessione; nessuna integrazione eseguita durante questa chiusura documentale.

**10/10/2026 — bocca Bruno:** scena autonoma `scenes/levels/bruno_mouth_test.tscn`, testa separata con `mouth_open`, RMS della sola voce, default 0.45. Taglio ricalibrato; dopo le istruzioni F6 l'utente conferma «ok bellino»: **TESTATO UTENTE, gradimento generale**. Domani riprendere con movimenti più ampi durante il parlato e valutare forme aggiuntive come “O”; l'apri/chiudi attuale resta accettabile se queste non convincono. Forme aggiuntive non implementate. Originali boss/intro/mappa invariati. [Dettagli e ripresa](BRUNO_MOUTH_PREVIEW.md).

**Ultima conferma utente — 10/10/2026:** «funziona tutto», dopo la revisione inventario/blob, caricamento, C/N e slot separato. Sistema nella scena di prova **TESTATO UTENTE**. La successiva integrazione SAFE nella mappa e il rifacimento della HUD inferiore restano aperti. Questa conferma aggiorna lo stato di verifica della fotografia sottostante, senza certificare la mappa non ancora integrata.

**Ultima implementazione: 10/10/2026.** ConnesiOS approvato e preservato. Inventario industriale sostituito con scuro/viola dei menu e accento blob del boss; HUD inferiore rinviata. Carica nella pausa/menu iniziale, da morto **C carica**, **N ricomincia sempre**. Prova F6 con slot `user://inventory_save_test.cfg`, mappa/menu con `user://savegame.cfg`. Routing, C/N, pausa, riavvio e grafica verificati tecnicamente; nuovo inventario e salvataggio ancora non TESTATO UTENTE. Integrazione nella mappa successiva e SAFE. Leggere [la nota](INVENTORY_SAVES_CONNESIOS.md) e l'ultima sessione. Branch/HEAD `dev/prototype-0.1` / `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c`; nessun commit/push.

Al controllo finale `scenes/maps/map_test.tscn` misura **26.936.463 byte**, timestamp locale **10/10/2026 00:30:45**, diverso dalla lettura iniziale della sessione. Non attribuire questa differenza all'implementazione inventario: nessuna patch dell'intervento tocca la mappa. La nuova versione va letta prima dell'integrazione; il solo timestamp non certifica il contenuto della stanza.

Fotografia del **08/10/2026**, acquisita prima della creazione dei Markdown di continuità. Etichetta: **VERIFICATO LOCALE — ANALISI STATICA**. Ripetere i controlli all'inizio della prossima sessione. Le differenze aggiunte da questa consegna sono annotate nel registro, senza riscrivere l'inventario precedente.

## Repository e strumenti

| Voce | Valore verificato |
|---|---|
| Workspace | `D:\ProjectBlob\Game` |
| Repository root | `D:/ProjectBlob/Game` |
| Branch attivo | `dev/prototype-0.1` |
| HEAD | `e5ff3c8d95ef9953cc69229d5f90e5acf03f0f1c` |
| Ultimo commit | Complete HUD face reactions for flashlight and battery pickups |
| Data ultimo commit | 2026-10-08 18:15:25 UTC / 20:15:25 Europe/Rome |
| Cronologia raggiungibile da HEAD | 85 commit |
| origin fetch/push | https://github.com/fraidotube/project-blob.git |
| Riferimento remoto locale | HEAD coincide con origin/dev/prototype-0.1 (0 avanti / 0 indietro) |
| Git | 2.39.0.windows.1 |
| Git LFS | 3.3.0 |
| Regole LFS | `*.glb`, `*.blend` |
| Godot, file presente | `D:\ProjectBlob\Tools\Godot\Godot_v4.7.2-stable_win64.exe` |
| Progetto Godot | `D:\ProjectBlob\Game\project.godot` |
| Blender / sorgente .blend attivo | Non verificati |
| PDF fonte | `docs/Project_Blob_Baseline_SAFE_2026-10-08.pdf` |

Il remoto live non è stato interrogato; il confronto usa i riferimenti già disponibili localmente. Git segnala ownership diversa nell'ambiente dell'agente: le letture hanno usato `git -c safe.directory=D:/ProjectBlob/Game ...`, senza modificare la configurazione globale.

## Differenze dalla baseline

Prima della documentazione: **10 file tracciati modificati, 26 cancellati dalla working directory, 258 file non tracciati**, nessun cambiamento nello staging. I 258 includono il PDF caricato dopo il primo controllo, che aveva contato 257 file. Un elenco completo datato è in fondo.

Le cancellazioni riguardano la vecchia cartella `SilverDelivery/Low_World_Base_Male_Character/`. Il percorso nuovo `assets/models/player/` è presente ma non tracciato: verificare se le cancellazioni sono parte dello spostamento, senza ripristinare automaticamente.

I 10 file modificati prima della consegna:

- Sei audio Bruno: `dolore2_mostro.mp3`, `dritto1_mostro.mp3`, `dritto2_mostro.mp3`, `pallina1_mostro.mp3`, `pallina_esplosiva1_mostro.mp3`, `pallina_esplosiva2_mostro.mp3`, sotto `assets/models/enemies/bruno_buozzi/`.
- `scenes/enemies/bruno_buozzi.tscn`.
- `scenes/levels/shooting_range.tscn`.
- `scenes/maps/map_test.tscn`.
- `scripts/systems/interaction_system.gd`.

Gli altri file non tracciati comprendono arredi, modelli player/armi, animazioni/audio/texture Bruno, volto HUD, materiali, UID e copie di script. Non sono conservati da HEAD. Non attribuire intenzione o completamento a un file dal solo nome.

## Mappa e boss

| Dato | Baseline PDF | Locale verificato |
|---|---|---|
| Dimensione map_test.tscn | 53.845.966 byte nel commit GitHub citato | **26.608.635 byte**, 26,61 MB / 25,38 MiB |
| Collisioni concave | Storia: 212, poi 114 in copie diverse | **50** dichiarazioni sub_resource `ConcavePolygonShape3D` |
| Salute Bruno nello script | 180 | 180 |
| Salute nella scena Bruno | Da verificare prima di cambiare | Override **90** in `scenes/enemies/bruno_buozzi.tscn` |

Il conteggio locale non misura le collisioni ereditate da GLB/scene importate o istanziate e non valuta da solo costo/performance. La dimensione è coerente con la dichiarazione storica di circa 25 MB, senza dimostrare quali interventi ne abbiano causato ogni riduzione. Gli override nella mappa e il comportamento runtime devono ancora essere verificati.

## Rilievi aperti

| Rilievo | Evidenza statica | Limite |
|---|---|---|
| Percorsi SilverDelivery | Scene sotto referenziano la vecchia cartella assente | UID/cache possono mascherare il problema; serve importazione completa separata |
| Sensibilità in pausa | Player legge da file in avvio; pausa salva senza aggiornare il campo player | Non riprodotto in gioco |
| SceneTransition su errore | Rami errore dopo fade-in azzerano busy senza nascondere overlay | Potenziale schermo nero/interfaccia bloccata |
| Attese animazioni | Sparo/ricarica attendono animation_finished anche se animazione richiesta manca | Potenziale blocco o completamento su animazione diversa |
| Prompt cinematic | Controllo visibilità Interface e pulizia focus nel locale modificato | Implementato localmente, test/push non certificati |
| GodotLootVFX | Riferimenti assenti sotto assets/BinbunVFX... | Non dedurre coinvolgimento nella mappa principale |
| Codice esteso e copie | Bruno ~4.473 righe, intro ~2.450, armi ~2.151; backup/varianti presenti | Non autorizza refactor o rimozione |

Percorsi assenti rilevati direttamente nelle scene:

| Scena | Dipendenza mancante |
|---|---|
| `scenes/weapons/lowworld_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn` |
| `scenes/weapons/lowworld_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/gltf/a_arms_flashlight_idle.res` |
| `scenes/weapons/lowworld_arms_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb` |
| `scenes/weapons/lowworld_arms_viewmodel.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter.tres` |
| `scenes/pickups/pistol_pickup.tscn` | `res://SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn` |

Sono osservazioni da diagnosi, non bug risolti o autorizzazioni a modificare. Le priorità e i criteri di completamento sono nel [backlog](DECISIONS_AND_BACKLOG.md).

## Asset ignorati e stato degli export

`.gitignore` esclude `.godot/`, import/cache, `assets/models/environment/`, `assets/textures/environment/`, archivi, `*.fbx`, `*.obj`, `*.mtl`, `*.blend`, `*.import`, file temporanei/backup/log, export exe/pck e `export_presets.cfg`. Le regole non rimuovono automaticamente file già tracciati.

`export_presets.cfg` è presente ma non tracciato: preset Windows Desktop, export `./ProjectBlob_demo.exe`, x86_64, PCK separato. Non è stato eseguito un export né verificato il template di esportazione.

I Markdown e Git non sono un backup completo. Per spostare il progetto servono inventario e conservazione anche di asset ignorati, sorgenti Blender e contenuti LFS. Le licenze dei pacchetti non sono state auditate.

## Verifiche eseguite e limiti

Letti configurazione, scene/riferimenti principali, controller pertinenti, standard tecnici, istruzioni scala e tutte le pagine del PDF. Controllati Git, cronologia, branch, remoto configurato, ignore/LFS, dimensione mappa, dipendenze testuali e alcuni override.

**Nessun Godot/Blender avviato; nessun playtest, benchmark, importazione pulita, build/export, fetch, staging, commit o push.** I test nel PDF restano conferme storiche dell'utente. Il primo controllo non trovava Godot nel PATH; il PDF ha consentito di verificarne il percorso reale.

## Inventario Git completo prima della consegna documentale

Output `git status --porcelain=v1 -uall`. ` M` = modifica non staged, ` D` = cancellazione non staged, `??` = file non tracciato. I path fra virgolette usano la rappresentazione di Git. Le esclusioni di ignore non compaiono in questo elenco.

```text
 D SilverDelivery/Low_World_Base_Male_Character/gltf/a_arms_flashlight_idle.res
 D SilverDelivery/Low_World_Base_Male_Character/gltf/mesh_melee.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/mesh_melee.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_character_male.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_character_male.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_pistol.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_pistol.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_revolver.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_revolver.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_shotgun.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_shotgun.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_sniper.glb
 D SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_sniper.glb.import
 D SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter.tres
 D SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter_placeholder.tres
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_arms_male.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_character_male.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_melee.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_revolver.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_shotgun.tscn
 D SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_sniper.tscn
 D SilverDelivery/Low_World_Base_Male_Character/textures/t_lowworld_basemalecharacter.png
 D SilverDelivery/Low_World_Base_Male_Character/textures/t_lowworld_basemalecharacter.png.import
 M assets/models/enemies/bruno_buozzi/dolore2_mostro.mp3
 M assets/models/enemies/bruno_buozzi/dritto1_mostro.mp3
 M assets/models/enemies/bruno_buozzi/dritto2_mostro.mp3
 M assets/models/enemies/bruno_buozzi/pallina1_mostro.mp3
 M assets/models/enemies/bruno_buozzi/pallina_esplosiva1_mostro.mp3
 M assets/models/enemies/bruno_buozzi/pallina_esplosiva2_mostro.mp3
 M scenes/enemies/bruno_buozzi.tscn
 M scenes/levels/shooting_range.tscn
 M scenes/maps/map_test.tscn
 M scripts/systems/interaction_system.gd
?? assets/models/edificio/metal-shelf-5mb/textures/01_DefaultMaterial_Metallic.png
?? assets/models/edificio/metal-shelf-5mb/textures/01_DefaultMaterial_Normal.png
?? assets/models/edificio/metal-shelf-5mb/textures/01_DefaultMaterial_Roughness.png
?? assets/models/edificio/metal-shelf-5mb/textures/alpha-base_color.png
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster.glb"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic010_2K-JPG_Color.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_Color.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_NormalGL.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_Roughness.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Plastic013A_2K-JPG_Roughness_5.png"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Wood027_2K-JPG_Color.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Wood027_2K-JPG_NormalGL.jpg"
?? "assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/source/Muwannga L-shaped Desk with Cabinet- OfficeMaster_Wood027_2K-JPG_Roughness.png"
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic010_2K-JPG_Color_7.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_Color_4.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_NormalGL_6.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_Roughness_3.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Plastic013A_2K-JPG_Roughness_5@channels=G.png
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Wood027_2K-JPG_Color_1.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Wood027_2K-JPG_NormalGL_0.jpeg
?? assets/models/edificio/muwanga-modern-l-shaped-desk-with-cabinet/textures/Wood027_2K-JPG_Roughness_2@channels=G.png
?? assets/models/edificio/office-monitor-workstation-monitor/source/monitor.dae
?? assets/models/edificio/office-monitor-workstation-monitor/source/monitor.stl
?? assets/models/edificio/office-monitor-workstation-monitor/source/read.txt
?? assets/models/edificio/office_chair.glb
?? assets/models/edificio/office_chair_0.jpg
?? assets/models/edificio/office_chair_1.png
?? assets/models/edificio/office_chair_2.png
?? assets/models/edificio/rack_22U.glb
?? assets/models/edificio/warehouse_shelving_unit.glb
?? assets/models/edificio/warehouse_shelving_unit_0.jpg
?? assets/models/edificio/warehouse_shelving_unit_1.png
?? assets/models/edificio/warehouse_shelving_unit_2.png
?? assets/models/edificio/warehouse_shelving_unit_3.png
?? assets/models/edificio/warehouse_shelving_unit_4.png
?? assets/models/edificio/warehouse_shelving_unit_5.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture_.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_texture_0.png
?? assets/models/enemies/bruno_buozzi/BetterBuozzi_texture_0_metallic_roughness.png
?? "assets/models/enemies/bruno_buozzi/ElevenLabs_2026-10-02T23_03_47_Paolo - Dynamic Italian Radio Voice_pvc_sp100_s50_sb75_v4.mp3"
?? assets/models/enemies/bruno_buozzi/Meshy_AI_Mutated_Tennis_Player_All_Animations_texture_0_2.png
?? assets/models/enemies/bruno_buozzi/Meshy_AI_Mutated_Tennis_Player_All_Animations_texture_0_metallic_roughness_3.png
?? assets/models/enemies/bruno_buozzi/Meshy_AI_Mutated_Tennis_Player_All_Animations_texture_0_mod.png
?? assets/models/enemies/bruno_buozzi/animations/Talk_Passionately.res
?? assets/models/enemies/bruno_buozzi/animations/disappointed.res
?? assets/models/enemies/bruno_buozzi/animations/idle4.res
?? assets/models/enemies/bruno_buozzi/animations/idle7.res
?? assets/models/enemies/bruno_buozzi/animations/laughing.res
?? assets/models/enemies/bruno_buozzi/animations/parla_sx.res
?? assets/models/enemies/bruno_buozzi/animations/risata.res
?? assets/models/enemies/bruno_buozzi/animations/sitting_laughing.res
?? assets/models/enemies/bruno_buozzi/animations/sitting_talking.res
?? assets/models/enemies/bruno_buozzi/animations/talking1.res
?? assets/models/enemies/bruno_buozzi/animations/talking2.res
?? assets/models/enemies/bruno_buozzi/animations/talking_sfida.res
?? assets/models/enemies/bruno_buozzi/animations/trovata_racchetta.res
?? assets/models/enemies/bruno_buozzi/buozzi_avatar.png
?? assets/models/enemies/bruno_buozzi/buozzi_avatar_2.png
?? assets/models/enemies/bruno_buozzi/caduta_fase1.mp3
?? assets/models/enemies/bruno_buozzi/caduta_fase2.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p1.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p12_mostro.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p1_mostro.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno2_p2.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno_monster.mp3
?? assets/models/enemies/bruno_buozzi/dialogoBruno_monster2.mp3
?? assets/models/enemies/bruno_buozzi/dolore1.mp3
?? assets/models/enemies/bruno_buozzi/dolore2.mp3
?? assets/models/enemies/bruno_buozzi/dolore3.mp3
?? assets/models/enemies/bruno_buozzi/dritto1.mp3
?? assets/models/enemies/bruno_buozzi/dritto2.mp3
?? assets/models/enemies/bruno_buozzi/idle4.glb
?? assets/models/enemies/bruno_buozzi/idle4_texture_0.png
?? assets/models/enemies/bruno_buozzi/idle4_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/idle7.glb
?? assets/models/enemies/bruno_buozzi/idle7_texture_0.png
?? assets/models/enemies/bruno_buozzi/idle7_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/morte.mp3
?? assets/models/enemies/bruno_buozzi/morteBruno.mp3
?? assets/models/enemies/bruno_buozzi/pallina1.mp3
?? assets/models/enemies/bruno_buozzi/pallina2.mp3
?? assets/models/enemies/bruno_buozzi/pallina_esplosiva1.mp3
?? assets/models/enemies/bruno_buozzi/pallina_esplosiva2.mp3
?? assets/models/enemies/bruno_buozzi/parla_manoSX.glb
?? assets/models/enemies/bruno_buozzi/parla_manoSX_texture_0.png
?? assets/models/enemies/bruno_buozzi/parla_manoSX_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/parla_passione.glb
?? assets/models/enemies/bruno_buozzi/parla_passione_texture_0.png
?? assets/models/enemies/bruno_buozzi/parla_passione_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/racchetta_trovata.mp3
?? assets/models/enemies/bruno_buozzi/risata.glb
?? assets/models/enemies/bruno_buozzi/risata_texture_0.png
?? assets/models/enemies/bruno_buozzi/risata_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/rovescio1.mp3
?? assets/models/enemies/bruno_buozzi/rovescio2.mp3
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_0.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_metallic.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/test/Meshy_AI_Mutated_Tennis_Player_1004142603_texture_roughness.png
?? assets/models/enemies/bruno_buozzi/test/morte2_0.png
?? assets/models/enemies/bruno_buozzi/testa.glb
?? assets/models/enemies/bruno_buozzi/testa2.glb
?? assets/models/enemies/bruno_buozzi/testa2_texture_0.png
?? assets/models/enemies/bruno_buozzi/testa2_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/testa_texture_0.png
?? assets/models/enemies/bruno_buozzi/testa_texture_0_metallic_roughness.png
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_DIAGNOSTIC.gd
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_DIAGNOSTIC.gd.uid
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_FINAL.gd
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_NAV_FINAL.gd.uid
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_SHIELD_DEATH_FIX.gd
?? assets/models/enemies/bruno_buozzi/textures/bruno_buozzi_SHIELD_DEATH_FIX.gd.uid
?? assets/models/enemies/bruno_buozzi/textures/texture_0.png
?? assets/models/enemies/bruno_buozzi/textures/texture_0_mod.png
?? assets/models/enemies/bruno_buozzi/trovata_racchetta.glb
?? assets/models/enemies/bruno_buozzi/trovata_racchetta_texture_0.png
?? assets/models/enemies/bruno_buozzi/trovata_racchetta_texture_0_metallic_roughness.png
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/a_arms_flashlight_idle.res
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/mesh_melee.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_arms_male.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_character_male.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_pistol.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_revolver.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_shotgun.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/gltf/smesh_sniper.glb
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter.tres
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/materials/m_lowworld_basemalecharacter_placeholder.tres
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_arms_male.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_character_male.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_melee.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_pistol.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_revolver.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_shotgun.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/scenes/prefab_sniper.tscn
?? assets/models/player/SilverDelivery/Low_World_Base_Male_Character/textures/t_lowworld_basemalecharacter.png
?? assets/models/weapons/Guns/AdditionalMeshes/Projectiles/Texture/Projectiles_Albedo.png
?? assets/models/weapons/Guns/Pistol_01/Textures/Pistol_01_Albedo.png
?? assets/models/weapons/Guns/Pistol_01/Textures/Pistol_01_silhouette.png
?? assets/models/weapons/Guns/Rifle_01/Textures/Rifle_01_Albedo.png
?? assets/models/weapons/Guns/Rifle_01/Textures/Rifle_01_silhouette.png
?? assets/models/weapons/Guns/Shotgun_01/Textures/Shotgun_01_Albedo.png
?? assets/models/weapons/Guns/Shotgun_01/Textures/Shotgun_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/FP_Arms/Texture/FPS_Arms_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/FX/Textures/LowRes_Noise.png
?? assets/models/weapons/RetroWeaponsPack/FX/Textures/MuzzleFlash.png
?? assets/models/weapons/RetroWeaponsPack/Guns/AdditionalMeshes/Projectiles/Texture/Projectiles_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Pistol_01/Textures/Pistol_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Pistol_01/Textures/Pistol_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Rifle_01/Textures/Rifle_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Rifle_01/Textures/Rifle_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Fbx_Files/Texture/SMG_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Fbx_Files/Texture/SMG_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Textures/SMG_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/SMG_01/Textures/SMG_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Shotgun_01/Textures/Shotgun_01_Albedo.png
?? assets/models/weapons/RetroWeaponsPack/Guns/Shotgun_01/Textures/Shotgun_01_silhouette.png
?? assets/models/weapons/RetroWeaponsPack/Readme.pdf
?? assets/models/weapons/ak47.glb
?? assets/models/weapons/ak47_akmat.png
?? assets/models/weapons/ak47_akmat_1.png
?? assets/package-lock.json
?? assets/shaders/boss_health_blob.gdshader.uid
?? assets/textures/Rack_lab.png
?? assets/ui/face/stato1_1.png
?? assets/ui/face/stato1_10.png
?? assets/ui/face/stato1_11.png
?? assets/ui/face/stato1_12.png
?? assets/ui/face/stato1_13.png
?? assets/ui/face/stato1_14.png
?? assets/ui/face/stato1_15.png
?? assets/ui/face/stato1_16.png
?? assets/ui/face/stato1_17.png
?? assets/ui/face/stato1_18.png
?? assets/ui/face/stato1_19.png
?? assets/ui/face/stato1_2.png
?? assets/ui/face/stato1_20.png
?? assets/ui/face/stato1_3.png
?? assets/ui/face/stato1_4.png
?? assets/ui/face/stato1_5.png
?? assets/ui/face/stato1_6.png
?? assets/ui/face/stato1_7.png
?? assets/ui/face/stato1_8.png
?? assets/ui/face/stato1_9.png
?? assets/ui/face/stato2_1.png
?? assets/ui/face/stato2_10.png
?? assets/ui/face/stato2_11.png
?? assets/ui/face/stato2_12.png
?? assets/ui/face/stato2_13.png
?? assets/ui/face/stato2_14.png
?? assets/ui/face/stato2_15.png
?? assets/ui/face/stato2_16.png
?? assets/ui/face/stato2_17.png
?? assets/ui/face/stato2_18.png
?? assets/ui/face/stato2_19.png
?? assets/ui/face/stato2_2.png
?? assets/ui/face/stato2_20.png
?? assets/ui/face/stato2_3.png
?? assets/ui/face/stato2_4.png
?? assets/ui/face/stato2_5.png
?? assets/ui/face/stato2_6.png
?? assets/ui/face/stato2_7.png
?? assets/ui/face/stato2_8.png
?? assets/ui/face/stato2_9.png
?? assets/ui/face/stato3_1.png
?? assets/ui/face/stato3_10.png
?? assets/ui/face/stato3_11.png
?? assets/ui/face/stato3_12.png
?? assets/ui/face/stato3_13.png
?? assets/ui/face/stato3_14.png
?? assets/ui/face/stato3_15.png
?? assets/ui/face/stato3_16.png
?? assets/ui/face/stato3_17.png
?? assets/ui/face/stato3_18.png
?? assets/ui/face/stato3_19.png
?? assets/ui/face/stato3_2.png
?? assets/ui/face/stato3_20.png
?? assets/ui/face/stato3_3.png
?? assets/ui/face/stato3_4.png
?? assets/ui/face/stato3_5.png
?? assets/ui/face/stato3_6.png
?? assets/ui/face/stato3_7.png
?? assets/ui/face/stato3_8.png
?? assets/ui/face/stato3_9.png
?? assets/ui/face/stato4_1.png
?? assets/ui/face/stato4_10.png
?? assets/ui/face/stato4_11.png
?? assets/ui/face/stato4_12.png
?? assets/ui/face/stato4_13.png
?? assets/ui/face/stato4_14.png
?? assets/ui/face/stato4_15.png
?? assets/ui/face/stato4_16.png
?? assets/ui/face/stato4_17.png
?? assets/ui/face/stato4_18.png
?? assets/ui/face/stato4_19.png
?? assets/ui/face/stato4_2.png
?? assets/ui/face/stato4_20.png
?? assets/ui/face/stato4_3.png
?? assets/ui/face/stato4_4.png
?? assets/ui/face/stato4_5.png
?? assets/ui/face/stato4_6.png
?? assets/ui/face/stato4_7.png
?? assets/ui/face/stato4_8.png
?? assets/ui/face/stato4_9.png
?? assets/ui/hud/bullet_back.png
?? assets/ui/hud/bullet_sfondo.png
?? assets/ui/hud/bullet_smg_final.png
?? character_body_3d.tscn
?? docs/Project_Blob_Baseline_SAFE_2026-10-08.pdf
?? materials/faro2_material.tres
?? materials/faro_material.tres
?? scripts/enemies/bruno_buozzi_hud.gd
?? scripts/enemies/bruno_buozzi_hud.gd.uid
?? scripts/pickups/smg_ammo_pickup.gd.uid
?? scripts/pickups/smg_pickup.gd.uid
?? scripts/systems/hud_face_controller.gd.uid
```

Per aggiornare questa fotografia usare i comandi della [procedura](WORKFLOW_AND_TESTING.md), annotando data, HEAD e limiti della verifica remota. Non copiare automaticamente questi conteggi nel prossimo resoconto.

## Aggiornamento 08/10/2026 — materiale onda di Bruno

Per la successiva modifica della maglietta consultare anche la nota di aggiornamento in fondo e il registro sessioni.

Successivo alla fotografia precedente e alla creazione dei documenti: modificati lo shader attivo e la scena sotto assets/vfx/bruno_melee_banana3d, oltre allo script completo dell'anteprima scenes/vfx_tests/bruno_melee_banana3d_test.gd. Materiale lilla più chiaro, pulsazione morbida e rigonfiamenti radiali; parametri e stato di approvazione nel backlog B03 e nel registro.

L'eseguibile è ora verificato anche in esecuzione: **4.7.2.stable.official.ed1daf0bf**. Anteprima avviata headless; verifica grafica Forward+ D3D12 su NVIDIA GeForce RTX 4060 completata con screenshot e controlli materiali. Nessun test del combattimento nella mappa e nessuna conferma visiva utente ancora ricevuta. Il precedente paragrafo “Nessun Godot avviato” descrive solo la sessione documentale.

Controller Bruno, controller movimento/danni dell'onda e mappa non modificati da questo intervento; conservate le differenze locali preesistenti. Nessun staging/commit/push; HEAD invariato. Script temporaneo di verifica, screenshot e log restano sotto .godot, ignorati da Git e rigenerabili: non sono dipendenze del gioco.

## Aggiornamento 08/10/2026 — maglietta BetterBuozzi

Nuova variante PNG _texture_connesi.png (2508×2508), lettering connesi_wordmark.png e materiale BetterBuozzi_connesi_material.tres nella cartella Bruno. La scena scenes/enemies/bruno_buozzi.tscn usa un override del materiale sul solo corpo; originale PNG, GLB e script Bruno conservati. Import e rendering della mesh di riposo confermati, animazioni/playtest/conferma utente aperti. Tutto locale, nessun commit/push. Dettagli e prompt nella [nota asset](BETTERBUOZZI_CONNESI_TEXTURE.md).

