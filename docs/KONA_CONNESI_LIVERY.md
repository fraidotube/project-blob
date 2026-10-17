# KONA — livrea Connesi

## Correzione V2 — versione da usare

**TESTATO UTENTE:** dopo export GLB e reimport Godot, l'utente conferma «perfetto» e riferisce prova completa del gioco riuscita. Segnalazione distinta: faro Angelastri durante fight, gestita nel relativo sottosistema.

L'utente ha rifiutato la prima versione: pallini al centro delle portiere e contorni dell'atlante alterati dalla generazione, con bordi neri. Il digest delle UV attestava solo che la mesh non era cambiata, non la corrispondenza delle sagome dipinte. Le verifiche della prima versione erano quindi insufficienti per quel requisito.

V2 parte direttamente da `car_body_ao.jpg` originale, senza generare o ridisegnare l'atlante. Imagegen integrato genera solo una decal trasparente con `connesi` e `connesi.it`; shader e baking nativi Blender collocano colori e scritte nello spazio della mesh, poi il compositore li applica sull'immagine originale. Pallini confinati a ±0,65 m longitudinali dai centri reali delle ruote, entro una corona dei passaruota e solo superfici esterne. Logo continuo sulle due portiere di ciascun lato; nessun pallino nel centro dello sportello. Texture `assets/textures/vehicles/kona_connesi_albedo_v2.png`, 1024² come l'originale.

Controllo pixel effettivo: 1.018.935 pixel fuori dalla maschera hanno differenza massima **zero** rispetto all'originale esportato nello stesso spazio colore; **zero nuovi pixel neri**. Dithering disattivato e compositore CPU a precisione piena; recessi scuri originali esclusi dalla colorazione. Risultati `texture_verified_v2.json`, anteprime `v2_preview_0.png`/`v2_preview_1.png`. La precedente texture e il candidato V1 restano copie storiche, non sono la versione da usare.

Strumenti aggiuntivi `bake_kona_livery_v2.py`, `verify_kona_texture_v2.py`, `audit_kona_panels.py`; apply/preview supportano `--v2`. La sola scena temporanea del baking unisce le mesh per evitare ricarichi per oggetto; non viene mai salvata come Blender. Il sorgente finale mantiene geometria/UV/gerarchie originali. Connesi14 prima della correzione coincide con `connesi14_kona_ready.blend`, SHA256 `3B6C81596BF2DBCDD850640EFBB238BAEA43A5279E893D4FDC04AF1B6D9F9CA9`; backup precedente alla prima livrea ancora conservato.

V2 installata in `D:/ProjectBlob/Assets_Source/connesi14.blend`, SHA256 `E827A74BCA8C2517498A238E876BADFBD905D61E06FF5083D97184D15E723528`, identico al candidato verificato. Riapertura candidato: tutte le 552 immagini precedenti conservate, nuova immagine 1024² incorporata; digest geometria/UV/gerarchie/material slots invariato. Sorgente verificato ancora uguale al backup V1 prima della sostituzione.

Prompt decal: creare solo `connesi` minuscolo blu scuro, marchio registrato e `connesi.it` grigio sotto, su fondo realmente trasparente, usando la foto come riferimento; nessun veicolo, pallino, ombra o atlante. La tinta finale è controllata dal materiale Blender. Nel baking Cycles appare un riferimento preesistente mancante a `GENERIC_HEADLIGHT_GLASS_dif.jpg`; nessuna modifica a quel materiale/immagine, controllo pixel e render della carrozzeria completati. Import e playtest Godot non eseguiti.

## Cronologia della prima versione, superata dalla V2

Richiesta del 12 ottobre 2026: adattare la carrozzeria della nuova KONA in `connesi14.blend` alla fotografia `docs/connesi_car.png`. Sorgente salvato e chiuso dall'utente alle 20:37; backup completo `local_optimization/kona_livery/connesi14_before_kona.blend`, SHA256 `9A965BC865338C967269FFFD97EFC13A28BC8437FD004F5C98716AF4BB1CD0D8`.

Il materiale reale `carpaint` usa `car_body_ao.jpg` (1024²) direttamente nel Base Color. L'immagine contiene ombre di dettaglio: non è un bianco uniforme. Era presente anche `Atlante UV della livrea Connesi.png.001`, scollegato, che divideva il logo fra portiere appartenenti a lati opposti. Due render sulla mesh hanno riprodotto le parole incomplete.

Nuova texture separata `assets/textures/vehicles/kona_connesi_albedo.png`, generata con lo strumento integrato imagegen usando atlante esistente, originale e foto. Logo completo blu e `connesi.it` su ciascuna portiera anteriore, puntinatura verde sulle superfici laterali. Livrea adattata alle forme e alle UV della KONA; non replica geometricamente l'auto diversa della fotografia. Originale conservato, nuova immagine sRGB incorporata nel candidato Blender. Nessuna modifica gameplay o Godot/GLB in questa fase.

Prompt utilizzato: modificare solo la livrea dell'atlante quadrato, conservare posizione, sagoma e orientamento delle isole UV, fondo nero e ombre; inserire la parola completa minuscola `connesi` blu su entrambe le isole delle portiere anteriori in basso, ognuna con `connesi.it`; mantenere puntini verdi degradanti, senza spostare isole o aggiungere testi altrove. Strumento integrato, nessuna API/CLI.

Anteprime reali delle due fiancate: `local_optimization/kona_livery/final_preview_0.png` e `final_preview_1.png`. Strumenti ripetibili: `tools/blender/audit_kona_livery.py`, `preview_kona_livery.py`, `apply_kona_livery.py`. Il candidato viene riaperto e controllato: digest geometria/topologia/UV/trasformazioni/gerarchie/materiali invariato e payload delle immagini originali conservati. Manifest e risultati in `application.json` e `verified.json`.

Verifica riapertura completata: tutte le 551 immagini originali conservano dimensioni e hash dei payload incorporati; nuova immagine 1254×1254. Digest geometria/UV/trasformazioni `76c5081eee60f9dd933ef12a9880bc7fcbcb8d459a5d2066040e1753f7100330` invariato. Avviso di scrittura thumbnail Blender non impedisce salvataggio e riapertura. Fake user attivato per le immagini inutilizzate e per l'originale, evitando che il salvataggio le elimini.

Installato in `D:/ProjectBlob/Assets_Source/connesi14.blend`, SHA256 finale `3B6C81596BF2DBCDD850640EFBB238BAEA43A5279E893D4FDC04AF1B6D9F9CA9`, identico al candidato verificato. Prima della sostituzione il sorgente coincideva ancora con il backup.

Export/import Godot e gradimento estetico utente restano da verificare. Nessun miglioramento prestazionale attribuito alla livrea. Nessun commit/push.
