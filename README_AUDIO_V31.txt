PROJECT BLOB - AUDIO BUS FIX V3.1

Sostituisce SOLO:
scripts/systems/audio_manager.gd

Cosa fa:
- crea automaticamente a runtime i bus:
  Music
  SFX
  UI
- li instrada tutti verso Master
- crea il player soundtrack sul bus Music
- avvia la soundtrack già al boot
- mantiene loop e fade-in

IMPORTANTE:
gli effetti di gioco esistenti NON vengono ancora spostati su SFX.
Per ora continueranno sul Master.
Nel prossimo passaggio li assegneremo in modo ordinato.

TEST:
1. Chiudi Godot.
2. Estrai nella root D:\ProjectBlob\Game
3. Riapri Godot in editor mode.
4. Avvia il progetto.
5. La musica deve sentirsi già durante FraidoSoft.
