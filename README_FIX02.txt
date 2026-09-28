PROJECT BLOB - InteractionOutline FIX02

Sostituisce SOLO:
scripts/tools/interaction_outline_builder.gd

FIX02:
- combina le mesh selezionate
- rigenera le NORMALI della mesh risultante
- ricrea InteractionOutline

Procedura:
1. Estrai nella root D:\ProjectBlob\Game
2. In Godot seleziona OutlineBuilder del contatore
3. Lascia Target Parent e Source Meshes invariati
4. Generate Outline -> ON
5. Ctrl+S
6. Avvia il gioco e punta il contatore

Non modifica connesi_meter.gd, shader, RayCast o InteractionSystem.
