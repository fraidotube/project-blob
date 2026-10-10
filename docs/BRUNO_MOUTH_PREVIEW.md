# Bruno — prova bocca

**Riscontro più recente:** l'utente conferma bocca funzionante nella mappa. Il blocco successivo del cammino è stato riprodotto anche senza bocca e corretto sul collider obsoleto della parete: [diagnosi passaggio](BRUNO_PASSAGE_COLLISION.md). Ora verificare l'intro completa con quel collider corretto, poi riprendere PC/porta/chiave.

## Integrazione reale del 10/10/2026

Dopo «ok ci siamo» l'utente approva V2 e richiede bocca attiva in cinematica, combattimento, ferite e sconfitta, poi prova nella mappa prima di PC/chiave/porta. La scena boss ora contiene `MouthIntegration`, con `scripts/characters/bruno_mouth_integration.gd`. Alla ready differita sostituisce solo la mesh della testa nell'istanza con V2 e mantiene il materiale esterno originale, trasformazione e parent del bone. Preview senza script boss esclusa dall'integrazione automatica.

Sorgenti reali: `BrunoDialogueAudio` del controller intro associato a questo boss; `boss_voice_player`/`BrunoVoice` (frasi, racchetta, dolore, cadute); `BrunoDeathAudio` creato dall'ambiente sotto Bruno. Un solo controller/RMS cambia sorgente e ripristina il bus precedente; priorità sconfitta, dialogo, voce combattimento. AudioStreamPlayer3D supportato mantenendo audio spaziale, stream, volume e riproduzione originali. Musica, swoosh, palline ed elettricità esclusi. La risata segue le animazioni esistenti il cui nome contiene `laugh`, non il tempo fisso della preview; dolore/caduta/sconfitta non sorridono.

Mappa `scenes/maps/map_test.tscn` eredita il nuovo componente dalla scena Bruno: nessuna patch alla mappa o ai controller estesi boss/intro/ambiente. Avvio della mappa verificato con `BRUNO_MOUTH_INTEGRATED`. Test dedicato `scripts/tests/bruno_mouth_integration_test.gd` usa la mappa reale e gli audio originali; il playtest completo resta distinto dal test automatico. Per prova utente aprire map_test e F6: avviare normalmente l'intro, osservare entrambe le parti/risate, poi frasi durante combattimento, ferite/cadute e morte finale. Fermare/riavviare e provare la pausa; controllare che il cadavere torni a bocca ferma. Poi proseguire con integrazione porta/chiave/PC concordata.

Test mappa headless completato: `BRUNO_MOUTH_INTEGRATION_TEST failures=0`, picchi apertura 0.633/0.635 (dialoghi), 0.612 (attacco), 0.636 (dolore), 0.623 (caduta), 0.637 (sconfitta). Verificati chiusura dopo stop, esclusione sorriso dolore, priorità morte e nessun bus residuo. Test richiama i veri metodi audio; non simula l'intera partita o la timeline cinematica. Alla chiusura della mappa Godot segnala 2 ObjectDB e 1 risorsa ancora in uso: non dichiarare assenza globale di warning; il test funzionale è passato, questo limite resta registrato. Hash di map_test, boss.gd, intro.gd e BetterBuozzi originale invariati rispetto all'inizio dell'integrazione.

Implementazione locale del 10/10/2026. Obiettivo iniziale: apertura discreta durante il parlato, senza labiale fonetico. Dopo la correzione del taglio labiale e le istruzioni per la prova F6, riscontro utente: «ok bellino». Prototipo **TESTATO UTENTE / gradimento generale**; non dedurre una verifica distinta di ogni controllo o vista.

## Ripresa della prossima sessione

L'utente chiede di continuare domani: durante il parlato la bocca deve fare movimenti più ampi. Valutare anche altre forme, per esempio una “O”, per renderla più realistica; se il risultato non è fattibile o convincente, accetta di mantenere l'apri/chiudi attuale. Nessuna nuova modifica tecnica effettuata dopo questa richiesta.

1. Ripartire dalla scena autonoma e dalla variante corretta, mantenendo questa versione come riferimento.
2. Valutare prima la risposta audio e il limite attuale (max_open 0.45, guadagno 6): aumentare l'escursione durante la voce e farla provare all'utente con calma. Non aumentare indiscriminatamente la deformazione geometrica.
3. Valutare una shape aggiuntiva per labbra arrotondate, verificando taglio, angoli e cavità. È una possibilità da studiare, non una funzionalità già presente.
4. L'RMS attuale misura l'intensità e non identifica vocali o fonemi: un'eventuale “O” richiede anche una scelta su come pilotarla. Non promettere riconoscimento fonetico dal solo volume.
5. Procedere una modifica mirata alla volta, con confronto originale/variante e prova manuale dell'utente. Integrazione nella vera cinematica ancora successiva, da concordare.

## Prova

**Revisione espressiva del 10/10/2026:** variante attiva in `mouth_preview_v2/`, con tre shape: `mouth_open`, `mouth_round`, `mouth_smile`. Variante approvata precedente conservata in `mouth_preview/`. Apertura parlato 0.72 (prima 0.45), rilascio 0.09 s e risposta alle sillabe deboli più evidente; risata con massimo 0.972 e sorriso 0.85 mantenuto tra i brevi impulsi vocali. Soglia/RMS/bus privato conservati. La variazione arrotondata/sorriso durante il parlato è stilizzata e deterministica, non riconoscimento delle vocali.

La prova ora ascolta fino a 16 secondi, includendo la prima risata. Il riferimento risata 11.55 s proviene da `part1_laugh_time` nel controller intro esistente; qui è usato solo nella preview. **L** avvia direttamente quel tratto. In modalità **M**, **3** alterna labbra arrotondate, **4** alterna sorriso. Gli altri controlli restano validi. Nessuna integrazione nel boss/cinematica reale in questa revisione. Nuova resa ancora da confermare dall'utente.

Verifica finale V2 Forward+ D3D12: test zero errori, apertura voce massima 0.7801, round 0.3889, sorriso 0.8500; screenshot manuali `bruno_mouth_runtime.png`, `bruno_mouth_round.png`, `bruno_mouth_smile.png` in `.godot`, controllati visivamente. Hash dei cinque originali invariati. I parametri/controlli di seguito descrivono la prima versione quando differiscono da questa revisione.

Aprire `scenes/levels/bruno_mouth_test.tscn` e avviare F6.

- Spazio o pulsante: ascolta/ferma i primi 12 secondi di `dialogoBruno2_p1_mostro.mp3`.
- R: riparte. 1/2: frontale/tre quarti.
- A: attiva/disattiva l'animazione originale `mie/talking1`.
- O: confronta la testa originale e la variante.
- M: apertura manuale senza audio; slider: apertura massima, default 0.45.

La scena usa una copia di Bruno priva dello script AI e delle collisioni della radice. Non integra la bocca nella cinematica o nella mappa. Non modifica salvataggi o inventario.

## Asset e funzionamento

La testa originale `output_unwrapped` è rigida, sotto `mixamorig_Head`, senza jaw bone o blend shape (8038 vertici, 7311 triangoli). La nuova variante contiene solo la testa, shape `mouth_open`, labbra separate e cavità scura. Conserva UV/materiale esterno e trasformazione della testa originale; il corpo, lo scheletro e le animazioni restano quelli della scena originale.

Sorgenti nuovi in `assets/models/enemies/bruno_buozzi/mouth_preview/`: `bruno_head_mouth_preview.blend` e `.glb`. Generatore completo: `tools/blender/build_bruno_mouth_preview.py`, Blender 5.2.1 LTS. Il `.blend` è ignorato: effettuare un backup esplicito quando si consolideranno gli asset. Nessuno staging automatico o verifica nuova di licenza per pubblicazione.

La curva del taglio segue punti della linea di contatto labiale nel render ortografico originale, anziché una parabola generica. Solo la parte inferiore, localizzata davanti alla bocca, si muove; occhi e naso restano stabili. Delta massimo della shape completa: 0.0887875 unità locali, circa 14.6 mm alla scala originale; a 0.45 circa 6.6 mm. La mesh resta volutamente nello stile poligonale del modello.

`scripts/characters/bruno_mouth_motion.gd` misura RMS stereo su un bus privato della sola voce, con `AudioEffectCapture`. Soglia 0.012, guadagno 6, attacco 0.05 s, rilascio 0.15 s. Stop e fine chiudono immediatamente; pausa voce/albero richiude gradualmente. All'uscita ripristina il bus della voce e rimuove il bus privato. Nessun bus globale sostituito.

`scripts/debug/bruno_mouth_preview.gd` carica il piccolo GLB direttamente tramite GLTFDocument, sostituisce la mesh della sola istanza e mantiene il materiale originale della superficie esterna. La cavità usa un materiale opaco scuro. Non occorre una reimportazione della mappa per provare.

## Verifiche e limiti

Godot 4.7.2: avvio headless, test su dialogo reale, controllo limite apertura, silenzi, fine estratto, pausa voce, controllo manuale, confronto originale, animazione corpo e rimozione bus. Test grafico Forward+ D3D12 su RTX 4060: zero errori del test, apertura massima osservata circa 0.401, RMS massimo 0.3354. Screenshot in `.godot/bruno_mouth_runtime.png`. Test completo: `scripts/tests/bruno_mouth_test.gd`, eseguibile con `--script res://scripts/tests/bruno_mouth_test.gd` (headless oppure GPU).

La variante corretta è stata rigenerata e controllata nei render Blender frontale/tre quarti; ripetuto il test headless con zero errori e apertura massima 0.407. Il test GPU sopra si riferisce alla variante precedente alla correzione del taglio. I test automatici non certificano la precisione artistica: verificare F6, M/O, frontale e tre quarti per la conferma utente. Warning headless sul certificate store/log user e warning Blender su sampler/use_nodes sono separati dal risultato del test.

Hash dei cinque originali verificati invariati: BetterBuozzi.glb, scena/script boss, controller intro, map_test.tscn. Nessun commit/push. Prossimo passo: movimenti più ampi nella prova isolata e valutazione delle forme aggiuntive secondo la richiesta sopra.

Riferimenti API: [AudioEffectCapture](https://docs.godotengine.org/en/stable/classes/class_audioeffectcapture.html), [MeshInstance3D](https://docs.godotengine.org/en/stable/classes/class_meshinstance3d.html), [GLTFDocument](https://docs.godotengine.org/en/stable/classes/class_gltfdocument.html).
