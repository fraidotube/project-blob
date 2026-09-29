PROJECT BLOB V4.3.5 - HOTFIX CONTATORE HUM

Corregge il Parse Error:
Cannot infer the type of "is_on" variable because the value doesn't have a set type.

Modifica SOLO:
scripts/interactables/connesi_meter.gd

Correzione:
- tipo bool esplicito su is_on
- cast bool esplicito sul valore restituito da power_system.is_power_on()

Funzioni mantenute:
- Switch Sound
- Power On Sound
- Power Off Sound
- Hum Loop Sound
- hum solo con PowerSystem ON
- bus SFX
