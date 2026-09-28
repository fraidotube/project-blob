PROJECT BLOB - MENU BUTTONS V3.3

Questa patch NON modifica logica menu, audio, boot, nebbia o gameplay.

Aggiunge:
- tema riutilizzabile Project Blob per UI
- pulsanti meno standard:
  * bordo sinistro più forte
  * angoli asimmetrici
  * pannello quasi nero
  * glow viola più controllato
  * testo chiaro
- animazione hover:
  * piccolo spostamento a destra
  * leggero scale-up
  * feedback pressed
- file pronto per essere usato anche su pause menu e future UI

FILE:
scripts/ui/menu_button.gd
scripts/ui/menu_style_manager.gd
scenes/ui/project_blob_menu_theme.tres

PROCEDURA CONSIGLIATA:
1. Estrai nella root D:\ProjectBlob\Game
2. Apri Godot
3. Apri scenes/ui/main_menu.tscn
4. Seleziona il nodo root MainMenu
5. Inspector -> Theme -> trascina:
   res://scenes/ui/project_blob_menu_theme.tres
6. I tre pulsanti esistenti erediteranno il nuovo stile.
7. I loro script menu_button.gd già presenti dalla V3 useranno la nuova animazione.

PER IL PAUSE MENU:
Apri scenes/ui/pause_menu.tscn
seleziona PauseRoot
Theme -> stesso project_blob_menu_theme.tres

NOTA:
Se in main_menu.tscn i pulsanti hanno ancora Theme Override locali dalla V3,
gli override hanno precedenza sul Theme. In quel caso:
- seleziona NewGame / Options / Quit
- Theme Overrides -> Styles
- resetta normal / hover / pressed / focus
- resetta anche font size/color se vuoi usare il Theme al 100%.

Lo stesso vale per i pulsanti del Pause Menu.
