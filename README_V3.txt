PROJECT BLOB - MENU / AUDIO / SETTINGS V3

BASELINE:
Git commit 10e818d - Add main menu pause system and visual design

ESTRAI SOPRA:
D:\ProjectBlob\Game

QUESTA V3:
- musica menu parte subito dal BOOT tramite AudioManager Autoload
- musica continua BOOT -> FraidoSoft -> Project Blob -> Menu senza riavvio
- bus audio: Master / Music / SFX / UI
- volumi persistenti Master / Musica / Effetti / UI
- opzioni video persistenti:
  * risoluzione
  * finestra / borderless / fullscreen
  * VSync
  * limite FPS
  * render scale 50%-150%
  * MSAA Off / 2x / 4x / 8x
  * FXAA
  * TAA
- pulsanti main menu ridisegnati:
  * dark industrial
  * bordo sinistro viola
  * glow hover
  * animazione hover leggera
- pause menu restilizzato con lo stesso linguaggio grafico

NON TOCCA:
- boot.tscn (quindi mantiene le dimensioni logo che hai appena impostato)
- gameplay
- interazioni
- HUD
- map_test
- nebbia V2.2

NOTA:
In questa V3 la schermata Opzioni del pause menu è volutamente minimale.
Le opzioni complete sono nel Main Menu. Nel prossimo step possiamo condividere
lo stesso pannello completo anche in pausa, senza duplicare logica.

TEST:
1. Chiudi Godot.
2. Estrai lo ZIP nella root del progetto.
3. Riapri Godot e attendi import.
4. Avvia con:
   cd D:\ProjectBlob\Game
   & "D:\ProjectBlob\Tools\Godot\Godot_v4.7.2-stable_win64.exe" --path .
5. Verifica:
   - musica già sul logo FraidoSoft
   - nessuna interruzione entrando nel menu
   - hover pulsanti
   - tab VIDEO / AUDIO
   - APPLICA
   - riavvia e controlla persistenza
   - ESC in gioco e nuovo stile pausa
