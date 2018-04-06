# COLIN
## The COmprehensive Laboratory Information Nexus

This is COLIN, a laboratory management package developed by the White group at the University of Melbourne.

Features will include chemical inventory management through an integrated barcode system, safety documentation, and group messaging.

## Inventory management
The inventory will be stored in a  database on a central machine. This will be accessed through COLIN. A distinction will be made between *chemicals* (the abstract concept) and *containers* (physical instances of a chemical).
Attributes of *chemicals* will include
* Name
* CAS number
* Formula
* GHS hazard symbols
* SDS

Attributes of *containers* will include
* Chemical
* Supplier
* Size
* Quantity
* Location
* Date added
* Expiry
* Borrowed by

Members of other groups will be able to view the inventory but not the location. This should discourage pilfering of chemicals.

Members of the White group will be able to view the full inventory either in read-only mode (to avoid accidental deletions) or edit mode.

Upon the arrival of a new chemical, the information should be entered into COLIN. If the database already contains an entry for the *chemical*, COLIN will only create a new *container*. COLIN will also generate a barcode unique to the *container*, which will be automagically printed on an attached label printer and should be stuck on the container. The barcode label will include such useful information as the proper location of the chemical.

Barcodes will facilitate speedy inventory audits, and will allow group members to quickly bring up the container information to mark it as empty, or loaned out to another group.
