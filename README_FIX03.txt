PROJECT BLOB - InteractionOutline FIX03

Sostituisce SOLO:
scripts/tools/interaction_outline_builder.gd

Diagnosi:
- InteractionOutline esiste ed è geometricamente completo.
- connesi_meter.gd usa davvero InteractionOutline.
- Il problema rimasto è il winding/culling delle mesh importate.
- FIX03 ricostruisce ogni triangolo, corregge il verso delle facce
  e poi rigenera le normali.

TEST:
1. Estrai nella root D:\ProjectBlob\Game
2. Godot: seleziona OutlineBuilder del contatore
3. Non cambiare Target Parent e Source Meshes
4. Generate Outline -> ON
5. Ctrl+S
6. Avvia il gioco, apri lo sportello e punta CONTATORE

Non modifica shader, connesi_meter.gd, RayCast o InteractionSystem.
