PROJECT BLOB - MENU UI SOUNDS V3.7

Questa patch aggiunge tre suoni originali generati per il progetto:
- ui_hover.wav
- ui_click.wav
- ui_back.wav

Nessun problema di licenza o attribuzione.

Comportamento:
- hover/focus = ui_hover.wav
- click normale = ui_click.wav
- INDIETRO / MENU PRINCIPALE / ESCI = ui_back.wav

I suoni usano il bus UI.
AudioManager crea già il bus UI a runtime.

Sostituisce:
scripts/ui/menu_button.gd

Aggiunge:
assets/audio/ui/ui_hover.wav
assets/audio/ui/ui_click.wav
assets/audio/ui/ui_back.wav

NON modifica:
main_menu.gd
game_settings.gd
scene menu
gameplay
