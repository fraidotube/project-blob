PROJECT BLOB - MENU FOG V2.2

Sostituisce SOLO:
assets/shaders/menu_fog.gdshader

Correzione:
la V2.1 mostrava celle/quadratoni visibili durante il movimento.
Questa versione usa:
- interpolazione quintica
- coordinate ruotate
- 6 ottave FBM
- domain warping
- nessuna soglia dura

Risultato atteso:
nebbia continua, organica, senza bordi rettangolari evidenti.

Procedura:
1. Estrai nella root D:\ProjectBlob\Game
2. Attendi il reimport shader
3. Avvia il menu
4. Osservalo per 10-15 secondi

Non modifica musica, logo, pulsanti o logica menu.
