# Regia — porte, chiave Bruno e PC nella mappa

**Menu aggiornati, 10/10/2026:** `caricasalvataggio.png` e `_blob.png` ora collegati in `scripts/ui/menu_button.gd` per menu iniziale e pausa; nel menu iniziale Nuova partita precede Carica salvataggio. Test runtime conferma texture nei due pulsanti e ordine; resa estetica da confermare. La precedente nota di asset ancora da collegare è superata.

**Conferma utente successiva:** «perfetto ora funziona», riferita alla correzione dell'attraversamento della scorrevole. Passaggio TESTATO UTENTE; non attribuire a questa frase una prova completa di salvataggio/C/N/riavvio. Nuovi asset per i menu consegnati dall'utente: `assets/ui/caricasalvataggio.png` (normale) e `assets/ui/caricasalvataggio_blob.png` (variante blob). Sono presenti e da collegare nella prossima sessione al pulsante Carica salvataggio del menu iniziale/pausa secondo i pulsanti esistenti; nessuna modifica UI tecnica in questa chiusura.

**Correzione attraversamento, 10/10/2026:** utente segnala pannello aperto ma passaggio impossibile. Sweep con il corpo player reale rileva urto sugli stipiti Parete Lab (anche Parete_015 del bagno), non sul pannello spostato. Larghezza pannello/vano circa 0.795 m contro capsula default diametro 0.80 m. L'integrazione ora duplica la shape del solo player della mappa e imposta raggio 0.35 (diametro 0.70), tramite export `player_passage_radius`. Altezza/crouch/camera/input/velocità invariati; scena/script player e altre scene non modificati. Riavviare F6 perché la configurazione viene applicata nella setup della mappa. Test dedicato `scripts/tests/sliding_passage_test.gd` controlla porta chiusa e sweep del player nelle due direzioni a porta aperta. I precedenti test di movimento/salvataggio non certificavano l'attraversamento.

Esito finale della correzione: porte chiuse bloccano; laboratorio e bagno aperti sono attraversabili in entrambe le direzioni, `SLIDING_PASSAGE_TEST failures=0`, exit 0. Test headless con warning ambientali già registrati. Conferma del player giocato ancora aperta; nessuna modifica ai collider dei mobili oltre il vano.

Implementazione locale del 10/10/2026, sui percorsi indicati dall'utente. Scena attiva `scenes/maps/map_test.tscn`; nessun commit/push. La demo resta separata.

## Provare con calma

Aprire map_test e F6. Giocare normalmente intro e combattimento. Bruno lascia una chiave soltanto alla morte finale; raccoglierla con E e controllare I. E sulla porta del laboratorio sblocca e apre, senza consumare la chiave. In regia, E su porte bagno/regia apre e chiude; E sul monitor entra in ConnesiOS. Clic Salva partita, poi Esc per tornare al player.

Cambiare posizione/stato delle porte, poi pausa → Carica salvataggio: devono tornare al checkpoint, con inventario e boss coerenti. Dopo morte, C continua dal file, N ricomincia. Riprovare dopo chiusura/riavvio. Il salvataggio reale è `user://savegame.cfg`; la demo usa `user://inventory_save_test.cfg`. Nessun autosave e nessuna scorciatoia F7/F8 aggiunta alla mappa. La conferma utente di questa integrazione resta aperta.

## Nodi e comportamento

| Elemento indicato dall'utente | Collegamento runtime | ID persistente |
|---|---|---|
| `connesi_building_test2/Porta Lab/Porta_011` | LabSlidingDoor, pannello+maniglie in Panel; telaio originale fisso | `main.door.lab` |
| `connesi_building_test2/Porta Bagno Regia` | BathroomSlidingDoor, senza chiave | `main.door.bath_regia` |
| `connesi_building_test2/Porta Regia` | RegiaSwingDoor, tutti i 7 mesh sotto lo stesso DoorBody | `main.door.regia` |
| `connesi_building_test2/PCRegia/Collada visual scene group_003/Computer_Low` | RegiaSavePC, schermo ConnesiOS sul monitor esistente | `main.pc.regia` |
| Bruno/intro reali | BrunoLoot, sconfitta e drop unico | `main.bruno`, `main.bruno_key` |

`RegiaIntegration`, child della mappa, esegue `scripts/systems/regia_map_integration.gd` dopo la costruzione della scena. Conserva mesh/materiali e sposta i visuali nelle nuove gerarchie solo nell'istanza runtime; non modifica il GLB dell'edificio. I vecchi collider dei pannelli mobili vengono esclusi; nuovi AnimatableBody3D usano box costruiti dagli ingombri attuali. Collider interagibili layer 1+2, Area3D fissa con mask player. I gruppi della geometria rimangono sui nodi originali, navmesh conservata.

Entrambe le scorrevoli hanno pannello verificato sul piano XY mondo; spostamento verso -X dalla faccia +Z, corsa pari alla larghezza reale più 0.08 m, velocità 1.8 m/s. Per il laboratorio corrisponde DX→SX richiesto. Per il bagno è il default scelto, da confermare nel playtest. La scorrevole libera usa `required_key` vuoto, ora supportato anche al restore; il default della classe rimane `bruno_key`. Impedisce chiusura sul player e blocca salvataggio durante movimento come la demo. Suoni scorrevoli non assegnati; battente riusa i suoni metallici esistenti del laboratorio.

### Porta regia e maniglie

Il pannello aveva una rotazione locale modificata, mentre le sei maniglie sono fratelli del pannello nel GLB attuale. La mappa conservava inoltre sei override verso vecchi path sotto `Porta_009`, che il runtime segnalava scomparsi. Rimossi solo quegli override obsoleti e ripristinata l'orientazione chiusa del pannello, preservando scala/traslazione.

Il pivot runtime usa l'origine del pannello `Porta_009` verificata (X=4.336967, Y=1.06, Z=6.335467), sullo stipite; l'origine del contenitore si trova invece vicino al bordo delle maniglie. Pannello e tutte le maniglie muovono insieme in DoorBody, apertura -90°. Il telaio della stanza resta nell'edificio. Il comportamento del vecchio `door.gd` è riusato senza patch.

### PC reale

La faccia frontale del monitor è stata verificata dai triangoli di `defaultMaterial_005`: piano locale Z circa -0.234, normale +Z. Schermo posizionato leggermente davanti; centro locale (-0.1552, 0.17645) e dimensioni 1.42×0.865, convertiti alla scala reale 0.501151. Il controller PC è un wrapper senza scala, orientato come il monitor; camera di accesso calcolata con il componente già approvato. Modello, cornice, LED, tastiera e mouse preservati. Geometria di prova disattivata.

## Persistenza nella mappa

Registrati alimentazione `main.power`, TV `main.tv`, meteorite `main.meteorite`, ambiente boss `main.boss_environment`, porta esterna laboratorio `main.door.lab_external`, più i pickup root già esistenti con ID `main.pickup.<nome nodo>`. Gli adattatori sono figli dei target: per i pickup l'uscita durante queue_free registra raccolta e rimuove il partecipante, senza riferimenti a nodi liberati. Un nuovo pickup annidato o nuovo sistema non viene automaticamente salvato: aggiungere un collegamento esplicito.

All'avvio normale/F6 la mappa seleziona il principale e inizializza la partita; durante restore preserva inventario/stati già letti. La creazione differita è completata prima dell'applicazione degli stati di SaveManager. Non rinominare ID o nodi pickup senza gestire i vecchi salvataggi. Schema ConfigFile resta versione 1, SaveManager non modificato.

## Verifiche

- `scripts/tests/regia_map_test.gd`: mappa reale, rifiuto senza chiave, scorrevole libera, corsa a sinistra, battente+7 mesh solidali, raccolta pistola persistente, morte finale/drop/raccolta chiave, sblocco senza consumo, salvataggio e ricostruzione della mappa, tutte le porte/boss/inventario/ambiente ripristinati, nessuna chiave/pistola duplicata. Esito finale `REGIA_MAP_TEST failures=0`, 19 partecipanti dopo pistola raccolta.
- `scripts/tests/regia_render_test.gd`: Forward+ D3D12 RTX4060, monitor reale/click sul bottone/esito salvataggio, screenshot porta chiusa/aperta. `REGIA_RENDER_TEST failures=0`; PNG `regia_pc`, `regia_pc_saved`, `regia_door_closed`, `regia_door_open` in `.godot`, controllati visivamente. La luce aggiuntiva nelle foto delle porte è soltanto del test, non della mappa.
- `scripts/tests/bruno_passage_test.gd`: con le nuove porte/PC Bruno supera ancora il passaggio, failures=0, Z finale 17.61 dopo 10 s; raggio boss 0.18 e bocca presenti.
- Suite demo `inventory_save_test.gd`: `INVENTORY_SAVE_TESTS_OK`, senza regressioni del default porta con chiave o slot demo.
- Processo nuovo `regia_map_test.gd -- --continue-test`: `REGIA_CONTINUE_TEST failures=0`, porte/boss/chiave ripristinati e pickup raccolti ancora assenti, senza usare memoria del processo precedente.

Fixture e log tutti sotto `.godot`, nessuna scrittura automatica nello slot utente principale/demo. Nel test esteso la prima scrittura è stata rifiutata correttamente durante l'animazione di equipaggiamento pistola; fixture corretta per attendere la fine dell'azione e rifiutare file residui. Test iniziale SceneTree corretto per accedere agli autoload via root. Warning certificate store headless/lampione SparksElectric già presenti distinti dai test; non dichiarare assenza globale di warning. I test non sostituiscono la partita completa o la conferma estetica/direzione del bagno.

Boss.gd, intro, scena boss e SaveManager preservati; bocca e collider Parete_013 corretti in precedenza conservati. Modifiche tecniche: nuova integrazione/test, supporto chiave vuota SlidingKeyDoor, collegamento child/script in mappa e pulizia locale degli override scomparsi della regia. Prossimo passo playtest utente dell'intero percorso chiave → porta → PC → caricamento/morte/riavvio.
