# CoLIN
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
* DG class (with up to two subclasses)
* UN number
* Packing group
* Poisons schedule

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

Upon the arrival of a new chemical, the information should be entered into CoLIN. If the database already contains an entry for the *chemical*, CoLIN will only create a new *container*.

Barcodes facilitate speedy inventory audits, and allow group members to quickly bring up the container information to mark it as empty, or loaned out to another group.

The database is accessed through a flexible API, and the data can be transformed into any format required for manifest reporting etc.

## Installation
CoLIN is designed to be deployed relatively seamlessly as a Heroku app. Simply clone the repository, and connect to it from Heroku. Ensure you are deploying the production branch, as this is the most stable. If you like to live dangerously, you can deploy development, which will give you access to new features.

This starts a web app. Once this is done, you will need to initialise the database. In the Heroku console, run `rake db:migrate` to create all the necessary tables. You will also probably want to seed the database with default values for DG classes, packing groups etc. To do this, run `rake db:seed`.

For local installation, you will need to install Ruby (rbenv is highly recommended), and Postgres, then bundler can handle the rest by running `bundle install`. Run `rake db:create`, `rake db:migrate` and `rake db:seed`, then launch CoLIN by running `rackup`.

## API endpoints
### GET `/api/container`
Returns all containers and all associated information
#### Parameters
* `limit` - return a maximum of this many records
* `offset` - start at this record
  
## Known Issues
* The dg_class_n_id columns must be filled sequentially. If you have dg_class_1_id and dg_class_3_id, but dg_class_2_id is null, only dg_class_1 will appear in the chemical detail page. This doesn't affect the api, where all dg_class objects are returned.

## Roadmap
* Sort chemical list
* Introduce some logic to populate pictograms, hazard classifications and precautionary statements from hazard statements per https://pubchem.ncbi.nlm.nih.gov/ghs/
* Allow the upload of SDSes and parse them automatically
* AJAX for all fields
* List chemicals by location
* Structure searching
* Flexible chemical structure storage