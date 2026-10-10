# BetterBuozzi — scritta connesi sulla maglietta

Data: 08/10/2026. Richiesta: aggiungere la scritta **connesi** alla maglietta del modello BetterBruno/BetterBuozzi, partendo dalla texture nominata dall'utente.

## Asset e collegamenti

Tutti gli asset seguenti sono sotto `assets/models/enemies/bruno_buozzi/`.

| Asset | Ruolo |
|---|---|
| `BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture.png` | Originale 1254×1254, conservato inalterato |
| `BetterBuozzi_Meshy_AI_Mutated_Tennis_Player_1004142620_texture_connesi.png` | Variante finale 2508×2508 con scritta proiettata nelle UV |
| `connesi_wordmark.png` | Livello di lettering trasparente generato con imagegen |
| `BetterBuozzi_connesi_material.tres` | Copia di Materialmat con albedo sostituito dalla variante; altre proprietà conservate |
| `BetterBuozzi.glb` | Modello originale, conservato inalterato |

Il materiale è assegnato in `scenes/enemies/bruno_buozzi.tscn`, sul surface_material_override/0 del nodo verificato:

```text
BetterBuozzi/Armature/GeneralSkeleton/Meshy_AI_Mutated_Tennis_Player_1004142620_texture
```

L'override è nella scena boss; aprire il solo GLB importato mostra ancora il materiale originale. Non sostituire il GLB né modificare skeleton, animazioni o controller per cambiare la scritta. Per ripristinare l'aspetto precedente basta rimuovere questo override del materiale e la relativa risorsa dalla scena, preservando le altre differenze locali.

## Scelte visive e metodo

Scritta minuscola blu scuro, centrata sulla porzione bianca integra del petto. Questa è la scelta predefinita comunicata durante il lavoro; non è ancora una conferma estetica dell'utente. Una scritta più larga risultava tagliata dalla parte mutata, quindi è stata adattata allo spazio realmente disponibile.

L'atlante UV è molto frammentato: non è sufficiente collocare la parola su una singola zona bianca del PNG. Il lettering è stato generato con il tool built-in imagegen e poi trasferito geometricamente nelle UV delle sole superfici frontali del petto, evitando pelle e parti viola. Nessuna rigenerazione dell'intera texture.

La variante usa il doppio della risoluzione: il contenuto originale è replicato con campionamento nearest, senza aggiungere dettagli al corpo; lo spazio aggiuntivo serve al lettering e ai bordi fra le piccole isole UV. Baking con quattro campioni per texel e gutter di due pixel. Originale non sovrascritto.

Dati per riprodurre il posizionamento sul mesh in coordinate locali di riposo:

- Centro XY: `(-0.07, 0.335)`.
- Larghezza: `0.165`; altezza ricavata dal rapporto del lettering ritagliato sull'alpha > 0.25.
- Rettangolo finale: X da −0.1525 a 0.0125, Y circa 0.319821–0.350179.
- Selezione frontale: Z medio > 0.07, normale Z media > 0.35.
- Applicazione sulle sole zone neutre del tessuto: componente minima RGB ≥ 0.45 e differenza fra massimo/minimo ≤ 0.25.
- Inchiostro: RGB `(0.07, 0.153, 0.267)`, alpha originale conservato.
- 3157 texel interessati nella variante 2508×2508; il corpo e le UV non sono modificati.

Gli script temporanei di ispezione, baking e anteprima sono nella cache `.godot/`, ignorata da Git. Il PNG finale e il materiale sono asset permanenti; la cache non serve al runtime e non è un backup del procedimento. Questi parametri consentono di ricostruirlo.

## Prompt e strumento utilizzati

Modalità **built-in imagegen**, senza API/CLI fallback.

Prompt iniziale, con l'anteprima della maglietta come riferimento del tessuto:

> Create the lettering layer for a localized edit to the referenced tennis-shirt texture. The reference image is a garment/material reference only. Output ONLY the exact lowercase word "connesi" (c-o-n-n-e-s-i), readable left to right, in a clean bold rounded sans-serif, dark navy blue #122744 matching the shirt trim. Flat solid ink, subtle clean antialiased edges, no shading, no glow, no outlines, no icon, no company symbol, no extra text, no shirt or model, no background. The entire background must be genuinely transparent. Center the word horizontally and vertically; fill most of the image width with modest padding, with a compact wordmark approximately 4:1 in aspect ratio. This bitmap will be projected onto the original shirt and baked into its existing UV atlas; do not invent or repaint any clothing or skin.

Correzione successiva della sola lettera i:

> Edit the referenced transparent wordmark. Keep its navy color, the existing c-o-n-n-e-s letters, size, spacing, rounded bold sans-serif style and genuine transparency. Correct ONLY the final lowercase letter i: it must have a visibly separate round dot ABOVE a shorter vertical stem, with a transparent gap between dot and stem. The exact text is "connesi" with an ordinary dotted lowercase i, not a dotless ı or l. No other changes and no new elements or background.

## Verifica e stato

- Materiale effettivo del corpo ispezionato in Godot: Materialmat usa il PNG esterno indicato dall'utente, 1254×1254. Il GLB contiene anche un'immagine embedded 2048×2048; non viene scambiata con quella effettivamente caricata.
- Variante importata da Godot e poi caricata dal materiale della scena boss: percorso e dimensione 2508×2508 verificati.
- Rendering della mesh di riposo frontale e posteriore con Forward+ D3D12 / RTX 4060: parola leggibile sul petto, retro senza scritte aggiunte.
- SHA-256 di PNG originale, GLB e script Bruno invariati dopo l'intervento.
- Conservate le differenze preesistenti della scena boss (90 HP, impostazioni debug, posa e parametri). Nessuno staging, commit o push.
- La verifica visiva usa la mesh/materiale della scena boss in posa di riposo; combattimento e cinematica animati non sono stati provati né confermati dall'utente.

La scansione import ha segnalato UID duplicati e differenze di maiuscole/minuscole in asset preesistenti, oltre alla lettura dello store certificati e al salvataggio delle impostazioni globali editor negato nell'ambiente ristretto. La variante è stata importata e caricata correttamente; questi rilievi estranei non sono stati corretti in questo intervento. Il rendering finale del materiale non ha prodotto errori.

## File da conservare

Conservare variante PNG, materiale, scena boss modificata, lettering sorgente e questa nota. PNG e materiale nuovi sono locali/non tracciati finché l'utente non richiede di salvarli in Git. Il GLB e il PNG originale rimangono la base per altre varianti.

