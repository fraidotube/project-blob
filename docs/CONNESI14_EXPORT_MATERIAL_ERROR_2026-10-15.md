# Connesi14: errore export materiali — 15/10/2026

## Secondo salvataggio: Normal rimossa ma altre tre presenti

Utente rimuove la Normal del Material.013 e salva15/10 00:13:23 (2.187.325.171byte). Nuova lettura conferma Material.013 non più tra i materiali con immagini TILED collegate. Restano3nodi ImageTexture.001 con Normal UDIMpacked/tile1001:

| Materiale | Oggetti | PNG identico estratto |
|---|---|---|
| Material.012 | Camion Shell.010/.011 | fuel_truck2_Normal_export.png |
| final1 | Camion Shell.016/.017 | fuel_truck3_Normal_export.png |
| final3 | Camion Shell.004 | fuel_truck1_Normal_export.png |

TrePNG2048² in local_optimization/connesi14_export_20261015_updated, estratti byteidentici. SHA256truck1=867c99f9fbeedf1eb7a8d8b3b7e4861542804cf11464378a94159731d776bdb6; truck2=d123921ea37baeb24fb9f08b6139c2a79798e3e1761d08ea12668da54d939798; truck3=d8ab833a9a1fd450d4efd7d3169a6825550a49ef584f2db268d834915016898b. Nodi/materiali/UV modificati soltanto in RAM per il test. Il primo errore era il primo materiale invalidato nella serializzazione, non l'unico materialeUDIM della mappa.

Su ciascuno dei3materiali aprire il PNG singolo corrispondente nel nodo collegato a NormalMap, poi salvare/export utente. Sostituzione preserva le texture; eliminazione delle altreNormal toglie il rilievo. Sorgente e GLB gioco mai scritti.

Nuovo probe368materiali con profilo utente termina con MicrosoftC++Exception prima della raccolta indici. Successivo factory-startup con3sostituzioni in RAM tenta export completo ma si ferma per ArrayMemoryError su allocazione7,20MiB durante raccolta mesh: non equivale a export completo riuscito e distinto dal traceback normalTexture. Tool verify_connesi14_all_normal_fixes.py; audit/report/log nuovi in cartelle suffisso_updated e.godot. Verifica ridotta dei3materiali eseguita separatamente; all_normal_fixes_verified.json distingue scope/esito. Note sotto riferite al primo salvataggio.

Verifica ridotta finale passa: FINISHED,3materiali/6immagini incorporate, nessun indiceTexture invalido, GLB15.194.696byte. Log con marker inizialmente FULL ma scopeJSON three_materials: corretto marker nello strumento, non confondere con export completo. Sorgente ancora2.187.325.171byte/00:13:23 invariato. Applicazione al Blender dell'utente e successivo export intero restano da eseguire.

Utente aggiorna connesi14.blend e segnala AssertionError nell'export GLB. Sorgente letto soltanto: D:/ProjectBlob/Assets_Source/connesi14.blend,2.189.308.605byte, ultimo salvataggio14/10/2026 23:33:18. Non salvato né sostituito. GLB Godot e scene non modificati; HEAD3b685e42 invariato, nessun commit/push.

## Causa riprodotta

Materiale Blender `Material.013`, usato da `Camion Shell.012` e `Camion Shell.013`. Nodo `Image Texture.001` usa immagine `fuel truck2_<UDIM>_Normal.png`2048², sourceTILED e packed, unica tile1001. Collegamenti corretti ImageTexture→NormalMap→PrincipledNormal.

Blender5.2.1 esportatore integrato segnala `UDIM packed images are not supported for export. Please unpack them before exporting.` La conversione UDIM crea `Material.013.1001` con normalTexture.index=None; serializzazione glTF pretende intero e termina con AssertionError. Warning sui nodi immagine duplicati distinto da questo blocco.

Audit iniziale senza nodi immagine/gruppi nulli. Unica FILE nonpacked mancante GENERIC_HEADLIGHT_GLASS_dif.jpg, storica: non la normal che causa il traceback. Esportazione completa originale riproduce l'errore; probe su368materiali con geometria minima identifica nome/indiceNone; isolamento del solo Material.013 riproduce packedUDIM non supportato.

## Correzione provata senza salvare il sorgente

Estratto byte per byte il PNG della tile packed1001 e caricato come normale immagine FILE sul solo nodo normal, in RAM. Export isolato riuscito FINISHED, normalTexture.index=0 valido e2immagini/texture incorporate. Geometria sorgente/UV/albedo non toccati. Payload SHA256 `d123921ea37baeb24fb9f08b6139c2a79798e3e1761d08ea12668da54d939798`, identico al PNG estratto,2048² invariato. Colorspace conservato sRGB per non introdurre un'altra modifica: Non-Color normalmente appropriato alle normal, ma non è la causa di questo blocco e non è stato cambiato nel test.

PNG pronto: `local_optimization/connesi14_export_20261015/fuel_truck2_Normal_export.png`. Nome senza1001/<UDIM> per evitare rilevamento automatico UDIM all'apertura. Copia identica anche fuel_truck2_1001_Normal.png. Se si corregge manualmente Blender: selezionare uno dei due CamionShell, materiale Material.013, aprire sul nodo ImageTexture.001 il PNG pronto come immagine singola, conservare NormalMap e collegamenti; salvare e riesportare normalmente. È possibile incorporare questo PNG singolo: il problema riguarda UDIM packed, non le immagini packed in generale. Alternativa: estrarre/unpack correttamente il tileUDIM e mantenere il formatoUDIM, ma per un'unica tile non necessario.

Strumenti read-only `tools/blender/diagnose_connesi14_export.py`, `inspect_connesi14_material.py`, `verify_connesi14_normal_fix.py`; questi Python usano Blender nativo per audit/export/estrazione dati, non patch di script o scene. GLBdiagnostici/log/JSON sotto local_optimization e.godot. Preparato ma non applicato al .blend originale; export completo dopo correzione e playtest Godot ancora da eseguire. La riuscita del materiale isolato non garantisce da sola assenza di altri errori nell'intera mappa.
