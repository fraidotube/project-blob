# Broccolo: bocca e studio animazioni — 13/10/2026

**Revisione17/10 dopo playtest riuscito:** avvio mappa sul lampadario (sostituisce corridoio), pausa voce23s. Telefono fornito e gia' posizionato dall'utente nella mano destra, scala0,25/offset preservati; PhonePresentation gestisce visibilita e rilascio fisico durante trow2. [Guida attuale](BROCCOLO_MAP_INTRO.md). I tempi22s e il vecchio trigger nelle note storiche sotto sono superati.

**Aggiornamento17/10:** prima telefonata ora integrata nella mappa sul marker BroccoloSpawn, con trigger sul comando del corridoio dopo porta aliena/luce ingresso. [Guida dedicata](BROCCOLO_MAP_INTRO.md). La modalita studio e le due scene originali restano disponibili; secondo discorso e AI/minion non sono ancora collegati nella mappa. Le note sotto descrivono la fase isolata storica.

**Approvazione finale:** utente conferma «perfetto salva tutto». Configurazione attuale approvata e salvata localmente; le richieste storiche di gradimento qui sotto sono superate. Nessuna ulteriore prova manuale descritta esplicitamente dall'utente. Prossime fasi ancora aperte: mappa e combattimento minion. Nessun commit/push.

Preview isolata: aprire `scenes/levels/broccolo_animation_test.tscn` e premere F6. Le scene `broccolo_intro_test.tscn` e `broccolo_discourse_test.tscn` avviano automaticamente le rispettive presentazioni.

## Prova

- Menu con tutte le 28 clip della libreria `mie`, cursore temporale per clip singole, pausa Spazio e spostamento reale attivabile.
- «1 · Intro»: phone_answer_talk comincia3,5s prima della voce intro_broccolo (31,008s), portando prima la mano verso l'orecchio. A22s audio sospeso, crossfade0,55s verso trow2 completo(2,183s). Poi audio riprende dal punto sospeso e3cicli walking(3,817m complessivi), infine idle. Il secondo discorso resta avviabile separatamente.
- «2 · Discorso»: discorso_broccolo(30,293s), gesti talk1/2/3/4 con clip complete e crossfade; musica ProjecBloc - Broccolo in sottofondo−16dB. Al secondo21 dancing3(2,25s)→dancing2(2,717s)→dancing(2,633s), ciascuna completa una volta. Fine frase in idle se necessario, poi riduzione in2s a20cm e sfumatura musica1s. Segnale combat_ready per integrazione futura, senza combattimento effettivo.
- «Danza + musica»: mantiene la prova separata della vecchia playlist5clip, ripetuta fino a fine musica303,517s. Non è la nuova sequenza del secondo discorso.
- Voce e danza sono provabili separatamente. Override voce tramite voice_stream nell'Inspector.
- F volto/figura intera; 1/2 frontale/tre quarti; destro orbita; rotella zoom; O confronto testa originale. Apertura manuale, forma O e sorriso.
- Ripristino dimensione/posizione interrompe sequenza/audio. Pausa sospende anche il rimpicciolimento.

Le soglie22/21s sono quelle fornite dall'utente; parametri esposti insieme ad anticipo risposta, numero passi/cicli e crossfade. Rotazioni/gesti seguono le clip, con clock audio per le due soglie. Nessun seek per frame durante le presentazioni: il mixer avanza e sfuma normalmente. Pavimento con griglia1m e distanza camera adattata all'aspect per valutare spostamento e braccia. Gradimento e corrispondenza esatta alle frasi da verificare ascoltando in F6. Nessuna integrazione nella mappa o nuova AI.

## SAFE e implementazione

Scena utente scenes/enemies/broccolo.tscn: MouthPresentation e5link aggiuntivi phone_answer_talk/talk1/2/3/4 nella libreria mie; precedenti23clip, rig, pose, trasformazioni e materiali conservati. Backup precedenti in local_optimization/broccolo_mouth/broccolo_before_mouth.tscn e broccolo_before_presentation_20261013.tscn, esclusi dall'import con .gdignore. Le talking reimportate dall'utente hanno già i nomi ossa Broccolo: conversione standard selettiva delle4clip in8copie, nessun retarget delle risorse Angelastri usato nella scena.

Variante della sola testa assets/models/enemies/broccolo/mouth_preview/broccolo_head_mouth.glb, generata da tools/blender/build_broccolo_mouth.py: 23.536 vertici sorgente, 24.169 finali, taglio localizzato di 21 triangoli senza decimazione, cavità/denti e morph mouth_open/round/smile inizialmente zero. Componente scripts/characters/broccolo_mouth.gd sostituisce la mesh a runtime mantenendo attachment/transform e materiale originale della testa. Broccolo.glb originale intatto; Blender della variante nel workspace locale.

Riusa bruno_mouth_motion.gd invariato: RMS con espressioni stilizzate, non riconoscimento fonemi. Capture bus temporaneo rilasciato su stop/cleanup. Le animazioni vengono duplicate in RAM: curve X/Z trasferite all'attore con la scala del rig, testa/camera seguono il corpo. Nessuna .res originale riscritta.

## Verifiche

scripts/tests/broccolo_preview_test.gd passato headless e GPU Forward+ D3D12/RTX4060: failures=0, 23 clip campionate, tre morph, attachment, voce reale e apertura RMS (picco0,58), pausa, fine voce → danza, cambio clip, scala20cm, reset e capture rilasciato. Screenshot closed/open/dance/miniature ispezionabili in .godot/broccolo_preview_*.png. Altezza di riferimento da AABB idle circa1,70m: nominale, non misura anatomica di ogni posa.

Questa prova23clip è storica, precedente alle due presentazioni. Suite preview aggiornata per28clip e balletto standalone. Nuova scripts/tests/broccolo_presentation_test.gd osserva l'intera telefonata e l'intero secondo discorso in tempo reale, verifica ossa/rotazioni clip reimportate, pausa speciale durante lancio, percorso3,817m, massimo passo posizione0,009m, gesti mobili, cue danza21s, ordine3→2→1 e chiusura voce/musica/capture/miniatura. Prima esecuzione headless failures=0 ma rilevava riavvio di un Tween musica già concluso: corretto lifecycle prima della verifica GPU finale.

GPU finale failures=0, apertura0,646, camminata3,817m, massimo passo posizione0,017m, ingresso danza21,085s, ordine3/2/1 corretto. Screenshot phone_phone/discourse_dance/discourse_combat_ready ispezionati; avviso cache shader non scrivibile durante setup, rendering concluso regolarmente. Successiva rifinitura anticipo risposta1→3,5s verificata con campionamento posa e test dei due entrypoint automatici: mano destra entro0,32m dal bone Head all'avvio voce, entrambi gli audio/scena corretti. Helper entrypoint segnala4ObjectDB a teardown, distinto dal successo funzionale; suite principale GPU e preview28clip senza quel warning. Preview28clip finale passa failures=0. Ascolto reale/gradimento ancora aperti.

Test accelera fine voce/musica: non equivale ad ascolto integrale o gradimento artistico. Avviso certificati Windows storico; import editor segnala audio ._zombie.wav preesistenti non validi e salvataggio editor_settings fuori sandbox negato. Risorse necessarie alla preview caricate e runtime passato. Nessun commit/push; prova F6 e approvazione utente ancora aperte.

## Fasi future richieste

Presentazione definitiva, danza e riduzione nella mappa; poi copie minion di20cm, spawn continuo2–3 contemporaneamente, poca vita e soli melee, inseguimento, salto e furtività occasionale lungo muri. Associare gradualmente reazioni ai colpi da fermo/corsa/attacco e morti. Regole di fine battaglia, danni e numero totale ancora da definire. Nessuna di queste logiche combat implementata in questa fase.
