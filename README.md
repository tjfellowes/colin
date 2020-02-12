# COLIN
## The Comprehensive Laboratory Information Nexus

This is CoLIN, a laboratory management package developed by the White group at the University of Melbourne.

Currently, the inventory management feature is in beta.

Planned features include safety documentation, and group messaging.

## Inventory management
The inventory is stored in a central PostgreSQL database in a structured way. A distinction is made between *chemicals* (the abstract concept) and *containers* (physical instances of a chemical).
Attributes of *chemicals* include
* Name
* CAS number
* Formula
* GHS hazard symbols
* SDS

Attributes of *containers* include
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

Upon the arrival of a new chemical, the information should be entered into CoLIN. If the database already contains an entry for the *chemical*, CoLIN will only create a new *container*. CoLIN will also generate a barcode unique to the *container*, which will be automagically printed on an attached label printer and should be stuck on the container. The barcode label includes such useful information as the proper location of the chemical.

Barcodes facilitate speedy inventory audits, and allow group members to quickly bring up the container information to mark it as empty, or loaned out to another group.

## Installation
CoLIN is designed to be deployed relatively seamlessly as a Heroku app. Simply clone the repository, and connect to it from Heroku. Ensure you are deploying the production branch, as this is the most stable. If you like to live dangerously, you can deploy development, which will give you access to new features.

This starts a web app, which can only be used to search the inventory (at this stage). Once this is done, you will need to initialise the database. In the Heroku console, run `rake db:migrate` to create all the necessary tables. You will also probably want to seed the database with default values for DG classes, packing groups etc. To do this, run `rake db:seed`.

The command line interface is a Python script which can be run on a local machine, which allows you to edit the inventory. If required, the label printer should be attached to this machine.
