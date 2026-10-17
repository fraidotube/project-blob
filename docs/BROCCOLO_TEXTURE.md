# Broccolo — variante della texture del corpo

## Revisione approvata del sangue e nuova NORMAL

**Rifinitura rapida successiva:** utente trova la normal troppo uniforme e autorizza una passata veloce. Rilievo tessuti aumentato (strength0.65, distanza nominale8mm), ridotto a0.3mm sulle zone rosse o molto chiare per limitare sangue/loghi; la distanza è un parametro del bump, non un aumento della geometria. Variante leggera conservata in `normal_light_backup.png`, file NORMAL aggiornato sul medesimo path. Vettori e dimensioni riverificati; diffuse invariata. Nessun nuovo playtest/render completo della scena in questa rifinitura.

Utente conferma sangue «perfetto», richiede badge posteriore più piccolo e Connesi più leggibile sopra al taschino. Successive precisazioni: PARKSIDE sul gilet dal lato opposto a Connesi, casco senza logo; NORMAL derivata dalla versione modificata, non dalla mappa originale che conserva dettagli diversi.

Variante diffuse aggiornata sullo stesso path: badge da 0,28 a 0,21 m (-25% diametro), Connesi da 0,060 a 0,083 m sopra al taschino, PARKSIDE sul petto opposto. Sangue e tessuti di camicia/pantaloni conservati; revisione precedente salvata in `local_optimization/broccolo_texture/Ch17_1001_Diffuse_Broccolo_v1.png`. Casco ripristinato all'originale bianco.

Nuovo file `assets/models/enemies/broccolo/Ch17_1001_Normal_Broccolo.png`, 4096², tangent space OpenGL (+Y). Creato con bump leggero dalla luminanza della **diffuse aggiornata** e bake nativo sulle UV del modello, senza caricare/reimpiegare la precedente normal del FBX. Altezza massima nominale 1 mm/strength0.18 per tessuti, 0.15 mm sugli altri materiali del corpo; geometria reale mantiene volume/pieghe principali. Le macchie mantengono rilievo discreto. Normali rinormalizzate in raw data space e portate nell'emisfero uscente per eliminare rari vettori invertiti delle UV importate. Questa è una normal ricostruita dalla texture, non un recupero di dettagli da scultura high-poly.

In Blender: Diffuse nel Base Color con sRGB; NORMAL in un nodo Image Texture impostato **Non-Color**, collegato a **Normal Map (Tangent)** e poi al socket Normal del Principled. Non collegare direttamente il colore della normal al Normal del materiale. Preview `revised_0.png`/`revised_1.png`/`revised_2.png` usa entrambi i file; originale FBX e lavoro testa dell'utente intatti.

Check revisione: camicia/pantaloni invariati ai centri di tutti i poligoni UV confrontati con V1; NORMAL 4096², vettori finiti, lunghezza0.99403–1.00499, zero vettori con Z negativo. Diffuse: 10.872.312 pixel fuori maschera identici all'originale, zero nuovi pixel neri. `revision_verified.json` e `verified.json` conservati. Script aggiuntivi `build_broccolo_normal.py`, `verify_broccolo_revision.py`; preview supporta --normal. Gradimento di questi ultimi cambiamenti ancora da confermare; nessun commit/push.

## Prima versione, cronologia

Richiesta del 12 ottobre 2026: corpo del nuovo nemico `Modello_orig_Strut Walking.fbx`, texture estratta `Ch17_1001_Diffuse.png`. Gilet da arancione catarifrangente a blu elettricista, logo Connesi sul taschino, sporco degli abiti trasformato in sangue, logo PARKSIDE sul lato del casco bianco, logo rotondo fornito in `docs/siemilano.png` sulla schiena. Utente autorizza con «vai»; innesto della testa in Blender svolto dall'utente e non toccato.

## File da usare

`assets/models/enemies/broccolo/Ch17_1001_Diffuse_Broccolo.png`, 4096×4096, variante separata da collegare al Base Color del materiale del corpo in Blender. Originale `Ch17_1001_Diffuse.png` e FBX conservati senza scritture; non sostituita automaticamente la texture nel modello che l'utente sta modificando. Nessuna nuova integrazione in Godot, AI o gameplay.

Anteprime sul FBX originale: `local_optimization/broccolo_texture/edited_0.png` (fronte), `edited_1.png` (retro), `edited_2.png` (casco laterale). Mostrano la testa originale del FBX, non l'innesto in corso. La sola variante diffuse conserva gli altri materiali/normal/specular/glossiness originali, comprese le caratteristiche superficiali delle bande del gilet: arancione e giallo eliminati nel colore, struttura della mesh e mappe di rilievo invariate.

## Procedimento e riferimenti

Letto FBX reale con import nativo Blender 5.2.1: mesh distinte Ch17_Vest, Shirt, Pants, Helmet, materiale comune Ch17_body e UV map1. Ispezione e render in copia locale `inspection.blend`, mai salvata nei sorgenti attivi. Posizionamento loghi mediante proiezione in 3D e trasferimento sulle UV originali, senza modificarne coordinate/topologia. Logo Connesi ricavato dalla decal locale usata nella KONA, ritagliato al solo wordmark e bianco sul taschino blu. Logo rotondo usa esattamente l'immagine fornita, senza rigenerare testo/personaggio.

Logo PARKSIDE scaricato dal [sito ufficiale](https://parkside-diy.com/it): SVG `parkside_logo_white.153b86dca4a8992779976336eaa7ffc2.svg` nel footer, rasterizzato in Blender mantenendo lettering e tre tratti rossi; applicato su targhetta verde laterale. SVG/PNG e pagina di riferimento conservati nella copia locale di lavorazione. Nessuna pubblicazione/staging dei marchi o degli asset del personaggio.

Imagegen integrato usato soltanto per la distribuzione del sangue. Prompt: modificare l'atlante originale mantenendo ogni isola UV, trasformando solo lo sporco su tessuti di camicia/maniche e pantaloni in macchie realistiche rosso scuro/bordeaux; conservare trama, pieghe e cuciture, lasciare pelle/occhi/casco/scarpe/gilet immutati, niente logo o testo, texture piatta. Output generato `blood_reference.png` usato come riferimento delle aree rosse: l'atlante generato non è il file finale. Shader nativi ripuliscono le zone di fango e aggiungono pigmento sangue sui soli capi, ricostruiscono il blu dalle ombre originali e collocano i loghi. Compositore nativo sovrappone le sole modifiche alla texture originale 4K. Dithering disattivato, compositore CPU con precisione piena.

## Verifiche

`verified.json`: 10.843.653 pixel fuori dalla maschera identici all'originale (differenza massima 0), dimensioni 4096² e zero nuovi pixel neri. Prima iterazione aveva pantaloni quasi interamente rossi: separati pulizia e pigmento, ottenute macchie sul tessuto scuro. Taschino corretto dopo render frontale; soglia minima del blu evita nuovi pixel neri ai bordi. Originali verificati SHA256 invariati:

- Diffuse: `64129FBB514E716CEFC2BD88531F91110B8DBF7052C11A52A981D8906B4341F9`.
- FBX: `57EABD3E41690A4237BC4A787CC57EC8324E5D30C86E850A43411E0B157A9CAA`.

Strumenti in `tools/blender`: audit_broccolo_texture.py, render_parkside_logo.py, build_broccolo_texture.py, preview_broccolo_texture.py, verify_broccolo_texture.py. Baker e join operano solo su scena temporanea, non producono un FBX modificato. Avvisi import FBX su proprietà Short non supportate e thumbnail Blender annotati; import/render/pixel check completati. Nessun test runtime Godot o animazioni nuove richiesto da questa sola modifica della texture. Gradimento utente e prova sulla testa innestata restano aperti. Nessun commit/push.
