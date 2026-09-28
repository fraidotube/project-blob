PROJECT BLOB - Interaction Cleanup V6

Obiettivo:
usare sugli interactable lo STESSO metodo che oggi funziona perfettamente
su pistola, torcia, batteria e munizioni:

- shader screen-space già validato
- material_overlay applicato alle mesh ORIGINALI
- niente InteractableOutlineProxy V5
- niente mesh InteractionOutline dedicata
- niente builder durante il test

Lo script ignora automaticamente nodi chiamati:
InteractionOutline
OutlineBuilder
InteractionOutlineProxy

TEST:
1. Estrai nella root D:\ProjectBlob\Game
2. Non modificare pickup: pistola/torcia/batteria/munizioni restano congelati.
3. Avvia e prova:
   - PORTA -> bianco
   - INTERRUTTORE -> bianco
   - CONTATORE -> viola
   - TELECOMANDO -> viola

Se un oggetto evidenzia mesh sbagliate:
nell'Inspector usa interaction_visual_roots per indicare esplicitamente
il/i nodo/i visuali corretti, senza cambiare codice.
