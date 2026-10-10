# Bruno — blocco nel passaggio dopo la cinematica

**Conferma successiva:** l'utente risponde «ok ci siamo» e passa all'integrazione chiave/porte/PC: correzione del passaggio **TESTATO UTENTE**, conferma generale senza elenco degli scenari. Le note sotto conservano diagnosi e limiti dei test automatici.

## Segnalazione e diagnosi, 10/10/2026

L'utente conferma che la bocca funziona nella mappa, ma Bruno si blocca nel camminare tra tavolo e scrivania dopo la cinematica. Script di movimento identico al controllo precedente (SHA256 `F9D08B4A56774567F8025C511A802E8A055B4F148391B4D7AB82FBC4AB4F52EA`). La mappa risultava nuovamente salvata alle 10:41:42: SHA256 prima di questa correzione `B0902E77D75DEE11CC1DCE14DD877636FF7C7A641402223072CB6E64DC1B1AEE`, rispetto al precedente `7CDA6E...`. Questo dato non attribuisce da solo la causa a quel salvataggio.

Confronto runtime A/B sul punto finale della intro: stesso blocco con MouthIntegration presente o rimosso, root intorno a X=3.8/Z=9.52. Il collider effettivamente urtato è `connesi_building_test2/Mura Interne Alte/Parete_013/StaticBody3D`, normale rivolta verso -Z, superficie a Z=9.46621. Non è il collider della testa o quello del boss.

La parete visiva attuale è diversa dalla collisione incorporata precedente:

| Dato locale | Posizione AABB | Dimensioni AABB |
|---|---|---|
| Mesh attuale | (-0.211957, -2.3, -7.079399) | (0.413998, 12.31932, 12.11876) |
| Collider precedente | (-2.8261, -1.0, -0.9978) | (5.52, 5.3562, 1.7081) |

Trasformazione relativa collider/mesh verificata identità. La collisione precedente non corrisponde alla mesh attuale: evidenza compatibile con collisione rimasta obsoleta dopo cambiamento/reimportazione del modello; la cronologia precisa dell'asset non è ricostruita.

## Correzione mirata

Rigenerata soltanto la forma di questa parete dalla mesh corrente (192 vertici di triangoli), salvata in `resources/collision/parete_013_current.tres`. `map_test.tscn` cambia solo un ext_resource e l'assegnazione shape del nodo specifico. Vecchio sub_resource conservato, ma quel collider non lo usa più. Non cambiano mesh visive, materiali, transforms, metadati, gruppi navigation_source/intro, collision layer, collider boss, navmesh, AI o bocca.

Generatore completo `scripts/tools/build_bruno_passage_collision.gd`: legge la scena importata dell'edificio e salva la nuova risorsa, senza risalvare l'intera mappa. Ripetere soltanto quando cambia effettivamente la mesh di questa parete; verificare nuovamente trasformazioni e passaggi prima di sostituire una collisione.

## Verifiche

- Diagnostica `scripts/tests/bruno_movement_diagnostic.gd`: confronto bocca on/off, tracciamento percorso/collisioni; riduzione raggio boss 0.15/0.10 e tolleranza waypoint 0.20 non risolvono. Sono prove runtime, nessuno di quei parametri è stato consolidato.
- Rigenerazione temporanea del solo collider: Bruno arriva a Z=15.07 anziché fermarsi a 9.52.
- Test finale `scripts/tests/bruno_passage_test.gd`, mappa salvata: tutti i vertici fisici corrispondono ai triangoli correnti, collider boss sempre raggio 0.18, bocca integrata presente, Bruno arriva a (6.45443, 0.08938, 14.60089) dopo 10 s. `BRUNO_PASSAGE_TEST failures=0`, exit 0.

I test iniziano dal marker finale dell'intro e attivano il combattimento; non sostituiscono il playtest della cinematica completa. Ora F6 su `scenes/maps/map_test.tscn`, intro normale e uscita nel laboratorio. Conferma utente della correzione ancora aperta; il funzionamento della bocca è invece confermato. Non è un audit di tutte le collisioni dell'edificio reimportato. Nessun commit/staging/push.

Hash mappa dopo correzione: `97374191CACB30A87F7057E3148B6B9B01D17F7D1861385A6B5281963EC29BC3`. La risorsa nuova misura 5441 byte. La baseline storica non è stata riscritta.
