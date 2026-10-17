# Connesi14: texture applicate alla versione attuale

12/10/2026. L'utente richiede esplicitamente di applicare la correzione texture al proprio connesi14 e conferma «salvato e chiuso» prima della sostituzione.

## Risultato

Aggiornato direttamente `D:/ProjectBlob/Assets_Source/connesi14.blend`, a partire dal salvataggio delle 16:55:07. Dimensione 2.009.571.305 → 1.902.407.083 byte: circa 107 MB in meno (5,33%). Conservati gli ulteriori cambiamenti dell'utente.

SHA256 installato: `2CB0C83EF1CD9983679EA46E74FB63DEB573BDFDF8A2B28E19FB6C5EF386A5AC`.

Backup completo: `local_optimization/connesi14_current/connesi14_before_textures.blend`; copia verificata: `connesi14_ready.blend`. Il sorgente live è stato confrontato via SHA256 con il backup prima della sostituzione; il file installato è stato confrontato via SHA256 con il candidato dopo la copia. Scrittura fuori workspace eseguita con permesso sandbox specifico, dopo preparazione e verifica della copia.

Applicate le 26 riduzioni già approvate: 20 mappe Iveco e quattro scatole 4K→2K, auto rotta 8K→2K, paved 8K→4K. Copie PNG in `textures/`, incorporate nel sorgente. Originali esterni non sovrascritti. Pixel della selezione ridotti del 77,34%, non di tutte le texture del gioco.

## Preservazione verificata

Digest su coordinate dei vertici, topologia, indici materiali, UV, nomi di mesh/oggetti, trasformazioni, parent, assegnazioni materiali e nomi/tipi/flag dei modificatori invariato nella riapertura finale: `ea295f68ca810a795ec978d2f812f8e505f7929aebffe539bbb3967f33f864bc`.

Verificate dimensioni, hash packed, spazi colore e alpha delle 26 immagini ridotte. Tutti i 536 datablock immagine originali restano presenti; i payload packed delle immagini non selezionate sono identici al backup. Librerie referenziate conservate.

Blender eliminava 11 immagini inutilizzate al salvataggio: recuperate dai payload originali e marcate fake user. Il cambio dei percorsi tramite `filepath` aveva ricaricato quattro mappe extensioncord da file esterni: recuperati i payload originali e usato `filepath_raw` per modificare i riferimenti senza reload. Verifica finale di tutte le immagini passata. Problemi risolti prima di scrivere il sorgente.

Autopack automatico disattivato per evitare tentativi di incorporare riferimenti originali mancanti; le nuove immagini sono già packed. Nessuna immagine non selezionata ridimensionata o ricomposta.

Strumenti Blender: `apply_connesi14_current_textures.py`, `verify_connesi14_current_textures.py`, `preserve_connesi14_unselected_images.py`, `final_verify_connesi14_current.py`. Manifest, validation e confronto inventari nella cartella locale. Primo tentativo fermato da una proprietà di preferenza non disponibile, poi eliminata; nessuna scrittura al sorgente in quel tentativo. Avvisi thumbnail OpenImageIO e due enum colorspace invalidi già presenti anche nel backup; dati verificati senza alterarli.

## Beneficio atteso

Ridurre la risoluzione può diminuire memoria GPU e costo di caricamento; il beneficio FPS dipende dal collo di bottiglia. [Documentazione Godot](https://docs.godotengine.org/en/4.3/tutorials/assets_pipeline/importing_images.html).

Il benchmark precedente era già intorno a 10 ms/frame nelle rotazioni, con caricamento risorse di 49 s e texture riportate dal motore di circa 3,51 GiB. Il beneficio atteso è soprattutto memoria/caricamento; nessuna promessa di aumento FPS specifico o eliminazione dei picchi iniziali.

Serve nuovo export dal connesi14 aggiornato e import Godot completo, poi verifica delle risoluzioni incorporate e benchmark. Il GLB attivo non è stato modificato: nessun nuovo miglioramento runtime dichiarato e nessun playtest su asset vecchi spacciato per verifica di questo intervento. Nessun commit/push.
