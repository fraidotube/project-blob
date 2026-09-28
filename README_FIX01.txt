PROJECT BLOB - InteractionOutline FIX01

Sostituisce SOLO:
scripts/tools/interaction_outline_builder.gd

Procedura sul contatore:
1. Estrai lo ZIP nella root D:\ProjectBlob\Game
2. In Godot seleziona OutlineBuilder.
3. Lascia invariati Target Parent e Source Meshes gia scelti.
4. Attiva di nuovo Generate Outline.
5. Il vecchio InteractionOutline viene cancellato e rigenerato.
6. Avvia il gioco e punta il contatore.

Questa versione NON usa piu la debug mesh del convex hull.
Genera una vera MeshInstance3D unica combinando le mesh scelte manualmente.
