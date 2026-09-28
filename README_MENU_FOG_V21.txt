PROJECT BLOB - MENU FOG V2.1

Sostituisce SOLO:
assets/shaders/menu_fog.gdshader

Correzione:
la V2 precedente moltiplicava troppo l'alpha della nebbia,
quindi a video risultava quasi invisibile.

Questa versione:
- aumenta nettamente la visibilità
- usa due masse di nebbia
- movimento lento in direzioni differenti
- miscela viola/cyan
- mantiene il centro del menu più leggibile

Procedura:
1. Estrai nella root D:\ProjectBlob\Game
2. Godot reimporta automaticamente lo shader
3. Avvia il gioco
4. Osserva il menu per 5-10 secondi

Non modifica musica, pulsanti, logo o logica menu.
