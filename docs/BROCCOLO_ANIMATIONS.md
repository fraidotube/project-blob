# Broccolo — animazioni compatibili con il GLB

**17/10 — collegate dall'utente e integrate nel laboratorio:** broccolo.tscn contiene ora34clip. Audit motore delle sei nuove: running0,633s con3,43m nativi per ciclo; idle_to_run0,8s; inversione2,15s/180°; jump_to_run0,5s con rialzata del bacino (atterraggio, non decollo); stop0,9s; waving3,167s. Locomozione e scenetta integrate nella sola [prova boss](BROCCOLO_COMBAT_LAB.md), con animazioni private in_place e compensazione yaw solo per inversione. Nessuna modifica alla scena utente o alle risorse convertite. Audit `.godot/broccolo_running_audit.log`; snapshot GPU delle sei clip e test movimenti descritti nel registro.

## 17/10 — sei nuove clip convertite

Convertite selettivamente `running.res`, `running_jump_to_run.res`, `idle_to_run.res`, `running_change_direction.res`, `running_to_stop.res`, `waving.res` con il generatore già validato, invariato. Create12risorse nelle cartelle `animation_compatibili/in_place/` e `animation_compatibili/con_spostamento/`; originali e scena modello non modificati. Le nuove risorse non esistevano prima della conversione. Test compatibilità sul modello reale passato:68versioni,2108campioni. Log `.godot/broccolo_running_conversion.log` e `.godot/broccolo_running_compatibility.log`. L'utente le caricherà sul modello prima della valutazione/integrazione nei movimenti; non ancora collegate automaticamente. Restano da applicare nel laboratorio emissione copie in direzioni casuali differenti, aura arancione tenue e dimensioni leggermente maggiori richieste dall'utente.

## Aggiornamento 17/10/2026 — root motion durante il balletto

La cinematic mappa trasferisce per ogni frame le curve originali Hips di `dancing3`, `dancing2` e `dancing` al CharacterBody, orientando il movimento sul fronte corrente. Il fattore uniforme `dance_motion_scale=0.5` accorcia la distanza senza accelerare o modificare le pose; le risorse di animazione restano invariate. Percorso completo testato:3,56m, contatti mappa0.

**13/10 — talking reimportate:** talk1/2/3/4 nella cartella animation adattate con generatore standard selettivo,8copie. Queste sorgenti hanno già mixamorig1_; non usate le risorse Angelastri con mixamorig_. Collegate le4versioni in_place e phone_answer_talk alla libreria mie di broccolo.tscn, ora28clip. [Presentazioni e prove](BROCCOLO_MOUTH_AND_PREVIEW.md).

**13/10 — phone:** convertita solo phone_answer_talk.res nelle due versioni in_place/con_spostamento. Generatore accetta nomi .res dopo `--`; metodo invariato e altre clip non riscritte. Esecuzione completata2copie, originale e scena intatti, nessun test esteso.

**Aggiornamento13/10:** rigenerate tutte le23clip correnti (9nuove),46copie nelle due cartelle. Controllo rapido passato1426campioni; aggiornato test verticale per rispettare caduta/morte anziché richiedere bacino sempre alto. Conversione invariata, nessuna modifica agli originali. Utente preferisce evitare prove estese ripetute usando il metodo già validato.

**Confronto richiesto con Angelastri:** stesso meccanismo di traslazione sull'osso Hips. Angelastri walking percorre1.762m e thrller_1 circa4.094m suZ; Broccolo walking127.232unità×0.01=1.272m e dancing418.005unità×0.01=4.180m. Diversa scala di memorizzazione, non diversa tipologia di animazione. Le copie con_spostamento sono adatte allo stesso flusso: in Angelastri `_prepare_world_motion` conserva la curva, rende stazionarie X/Z sulle copie private e `_apply_world_motion` applica il viaggio al nodo model. Questo adattatore di runtime non è ancora implementato per Broccolo. Conferma utente: con_spostamento funziona. Log `.godot/boss_animation_motion_comparison.log`; nessun cambiamento agli asset in questo confronto.

Richiesta del 12/10/2026: caricando idle/dancing e le altre risorse nella scena Broccolo, il corpo si sposta vicino all'origine rispetto al posizionamento scelto. Diagnosi effettuata sui file locali veri, non sull'FBX precedente senza testa innestata.

## Causa verificata

GLB `assets/models/enemies/broccolo/Broccolo.glb`: Armature con scala 0.01, GeneralSkeleton con ossa in centimetri; rest del bacino `mixamorig1_Hips` = (0,94.75101,1.119742). Tutte le 14 clip in `animation` hanno una traccia di posizione `%GeneralSkeleton:mixamorig1_Hips` in metri (idle Y0.887422, dancing Y0.876663). Quando il player la applica direttamente al rig in centimetri, il bacino scende vicino all'origine. Bug riprodotto nel motore sul modello reale. Nessuna traccia di traslazione diretta del nodo mondo presente nelle risorse esaminate.

## Risorse pronte

`assets/models/enemies/broccolo/animation_compatibili/in_place/`: scelta per osservare i gesti mantenendo il nemico nella posizione impostata. Posizione del bacino moltiplicata per100; X/Z ancorate al rest del GLB. Y animata conservata, quindi salti, abbassamenti e respirazione rimangono. Non c'è traslazione orizzontale guidata dalla clip; futura locomozione gameplay richiede controller, non implementato qui.

`assets/models/enemies/broccolo/animation_compatibili/con_spostamento/`: stessa correzione di scala, X/Z iniziali riallineate al rest e successivo spostamento originale conservato. Usare quando si vuole che passi, salto in corsa o danze traslino il corpo. Il movimento è sull'osso root; il nodo esterno della scena resta alla posizione scelta.

Usare le nuove `.res` nell'AnimationLibrary del proprio AnimationPlayer al posto di quelle nella cartella `animation`. Non serve reexport Blender/GLB. Path ossa, rotazioni, scale, durata, numero/tempi delle chiavi conservati. GLB, animazioni originali e scene utente non sovrascritti; nessuna aggiunta autonoma di AI o incontro Broccolo.

Nomi reali conservati, inclusa grafia `risht_cover_sneak.res`: dancing, dancing2, dancing3, dancing_salsa, drinking, idle, jump, left_cover_sneak, risht_cover_sneak, running_jump, surprised, walking, walking_happy, walking_sneaky.

## Verifiche e strumenti

`scripts/tools/audit_broccolo_animations.gd` legge rig, scale e tracce; `prepare_broccolo_animations.gd` duplica solo in nuove cartelle, si ferma se scala/nome root/tracce non sono quelli verificati. Manifest/audit in `.godot/broccolo_animation_audit.json` e `broccolo_animation_conversion.json`.

`scripts/tests/broccolo_animation_compatibility_test.gd`: riproduce errore originale, posiziona GLB a (12,0,-8), applica tutte le copie al rig reale e campiona31tempi per clip (28versioni/868campioni). Bacino non collassa all'origine, X/Z stabili nella versione in_place, nodo mondo immobile; rotazioni/scale e timing confrontati integralmente con le risorse originali. Passato headless, log `.godot/broccolo_animation_compatibility.log`. Non equivale a verifica audiovisiva completa di ogni clip; resa con testa innestata/contatto piedi da confermare utente. Nessun commit/push.
