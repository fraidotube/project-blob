# Angelastri — combattimento e prova rapida

**Faro — 12/10:** utente prova tutto il gioco dopo reimport KONA V2 e segnala che l'occhio di bue non segue Angelastri nella fight. Causa: rilascio del faro alla fine del dialogo senza acquisizione nel combattimento. L'encounter ora acquisisce il corpo mobile del combat dopo configure, sia nel percorso naturale sia F11 e restore fight_ready. Faro ripristinato alla sconfitta, morte player, nuovo test/cleanup. Durante tracking il rig resta fisso e ruota come quello di Bruno; nessuna modifica a parametri della luce o AI. Test specifici nel registro; conferma utente della correzione ancora aperta.

Verifiche nuove headless: reuse/patrol passato e suite mappa failures=0, occluded=0, dance_collisions=0; include inseguimento del corpo su due spostamenti, rig immobile, ripristino dopo sconfitta/morte player e acquisizione F11. Le query del test escludono il collider dell'attore stesso. Nessun export GLB richiesto: cambiato solo lo script encounter.

**Stato finale 11/10:** utente conferma «ok ci siamo» nella mappa dopo revisione sangue direzionale. F7 patrol, **F11 fight diretta**. Arco attacco 3D sospeso a quota busto integrato; sangue finale38 sfere piccole bordeaux, senza quad verticali, direzione dal colpo con componente outward. Suoni approvati, alone sottile, niente info box fight. Le descrizioni/versioni precedenti sotto sono cronologia; barra definitiva ancora da creare con immagine utente.

Prima performance senza freeze/sparizione confermata dall'utente. Combattimento autorizzato: IA, walking/running, due attacchi melee, morso con immobilizzazione, danni reciproci, barra provvisoria e racchetta.

## Prova nella mappa

Caricare il checkpoint dopo Bruno, poi **F7** durante gameplay: Angelastri dal marker in passeggiata, senza intro/balletto. Il tasto non interviene durante cinematiche/fight. Secondo incontro entro 8 m, entrambi rivolti uno all'altro e linea di vista libera. Fine voce: talk_to_combat durante ritorno camera morbido 1.4 s, subito dopo controlli/fight senza attesa idle. F9 resta Bruno; F10/F11/F12 disabilitati.

Alla comparsa della barra ANGELASTRI in alto: **I → racchetta → USA COME ARMA**, clic sinistro per colpire; **I → RIPONI** o slot 1–4 per cambiare. Dopo primo uso **5** riequipaggia. Serve possedere bruno_racket, F7 non lo regala. Prima della fight resta soltanto esaminabile. Socket/transform utente conservati, swing procedurale sul modello sotto BoneAttachment e locomozione braccia hold esistente.

## Parametri iniziali da bilanciare

Feedback aggiornato: archi trasparenti a impatto per pugni/racchetta; sangue particellare solo quando gli HP diminuiscono; alone rosso sul modello skinnato durante invulnerabilità. Colpo respinto: arco rosso, rimbalzo viewmodel e urto grave, niente sangue. Audio reali assets/audio/enemy per pugni/impatti/zombie, swoosh1/2/3 Bruno per racchetta. Hold attack1/2/3 a 1.35× con impatto ricalcolato. Walking ridotto a1.2 m/s, running4.0 e velocità playback legata a velocità effettiva; schivate senza traslazione orizzontale. Nuova resa GPU ispezionata in `.godot/angelastri_invulnerable_feedback.png`, gradimento/ascolto aperti.

Aggiornamento su richiesta utente: **F11 avvia direttamente il combattimento**, F7 rimane passeggiata. Durante attack/bite/dodge/hurt il melee non infligge danno; ogni colpo accettato in chase provoca una reazione completa. Rabbia monotona in funzione della vita persa: morso fino a 1.8× più veloce, tentativi falliti ogni 3→1 s, recupero attacco 1.3→0.45 s e inseguimento fino a +25%. Dopo morso riuscito cooldown **8→5 s dal rilascio**, anche da ferito. Movimento con floor snap 0.45 m e superamento controllato di gradini fino a 0.35 m (test di spazio libero sopra e appoggio sotto, senza attraversare muri). Test fisico del gradino da 20 cm passato con shape reale.

- 40 HP; proiettili sempre senza danno. Pistola/SMG provocano dodging/dodging_right, oppure ducking con direzioni occupate. Cooldown 1.6 s; non interrompono azioni in corso.
- Walking 2.2 m/s, running 5.8 m/s oltre 5 m. CharacterBody dedicato con capsule/move_and_slide e deviazione laterale test_move. Il controllo locale evita ostacoli immediati ma non garantisce percorsi complessi fra stanze.
- Due melee alternati zombie_attack1/2, danno 10/16; impatto singolo al 45% della clip reale, 1.95 m e controllo fronte/LOS, recupero 1.3 s dopo clip.
- bite_neck entro 1.2 m: preavviso, presa al 25% se ancora entro 1.35 m e senza muro, lock fino fine clip; danno singolo 24 al 55%, recupero 4 HP mostro, cooldown 12 s. Rilascio su fine/interruzione melee/morte/cleanup, camera/input/physics ripristinati.
- Solo melee danneggia: pugni mantengono valori esistenti; racchetta 5 danni/2.5 m/cooldown 0.7 s. hit_reaction1/2 con limite anti-stunlock; death alla sconfitta, barra nascosta/collider disattivo. Stato defeated/posa corpse persistono, save vietato durante fight. Slot storici 0–3 conservati, racchetta nuovo valore 4.

## Prove e limiti

`angelastri_combat_test.gd`: vero player/modello in pavimento isolato, immunity/dodge, running/spostamento, due melee/impatti singoli, morso/rilascio/interruzione, morte, colpo racchetta sul collider reale, gate item/slot5/save. Passato headless e GPU D3D12. Screenshot `.godot/angelastri_combat_hud.png` ispezionato: barra centrata in alto. Non certifica bilanciamento audiovisivo/navigazione mappa.

`angelastri_reuse_patrol_test.gd`: stessa istanza per primo spawn, F7 e secondo incontro; movimento walking, posizione conservata, camera e handoff fight con controlli restituiti. Passato con asset reali in scena isolata; faro escluso dalla fixture. Suite mappa con fixture distinta dai salvataggi utente.

Suite mappa finale GPU: `angelastri_encounter_map_test.gd failures=0`, zero occlusioni/collisioni, patrol e handoff combat passati (`.godot/angelastri_encounter_combat_map_final.log`). Regressione inventario/salvataggio `INVENTORY_SAVE_TESTS_OK`. Conferma artistica/bilanciamento manuale ancora aperti.

File: angelastri_combat.gd, angelastri_encounter.gd, preview mappa/studio, weapon.gd, player.gd, gameplay_ui.gd e stato evento. Nessun commit/push.
