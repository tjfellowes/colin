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
### Chemicals
#### GET `/api/chemical`
Returns all chemicals and all associated information.
##### Parameters
* `limit` - return a maximum of this many records
* `offset` - start at this record

#### GET `/api/chemical/cas/<CAS Number>`
Returns all chemicals whose CAS Number contains the substring `<CAS Number>`. If there is more than one match, only the CAS Number and ID are returned, to facilitate fast searching. Otherwise, all fields are returned.

#### POST `/api/chemical`
Creates a chemical with the following fields.
##### Parameters
* `cas` - string - CAS number
* `name` - string - name of the chemical
* `prefix` - string - prefix of the name which should not be used in alphabetical sorting (e.g. **1-**butanol)
* `haz_substance` - boolean - is the chemical a hazardous substance?
* `dg_class` - string - dangerous goods shipping class and subclass in the format `8 (3, 6.1)`. Can be used in place of `dg_class_1`, `dg_class_2` and `dg_class_3`
* `dg_class_1` - string - primary dangerous goods class
* `dg_class_2` - string - dangerous goods subclass
* `dg_class_3` - string - dangerous goods secondary subclass
* `packing_group` - string - shipping packing group
* `un_number` - string - UN number
* `un_proper_shipping_name` - string - UN proper shipping name
* `schedule` - string - SUSMP poisons schedule number <https://en.wikipedia.org/wiki/Standard_for_the_Uniform_Scheduling_of_Medicines_and_Poisons>
* `storage_temperature` - string - storage temperature in degrees Celsius. Either a single number of range separated by ~ (e.g. -20~-15)
* `inchi` - string - InChI string representation of the structure
* `smiles` - string - SMILES string representation of the structure
* `pubchem` - string - Pubchem ID
* `density` - string - density in g/mL
* `melting_point` - string - melting point in degrees Celsius
* `boiling_point` - string - boiling point in degrees Celsius
* `sds` - binary - a PDF of the SDS
* `signal_word` - string - GHS signal word
* `haz_stats` - string - GHS hazard statement code <https://unece.org/sites/default/files/2021-09/GHS_Rev9E_0.pdf>. can be passed multiple times as an array `haz_stats[]`
* `prec_stats` - string - GHS precaution statement code <https://unece.org/sites/default/files/2021-09/GHS_Rev9E_0.pdf>. can be passed multiple times as an array `prec_stats[]`
* `haz_classes` - string - GHS hazard classification. can be passed multiple times as an array `haz_classes[]`
* `pictograms` - string - GHS pictograms. can be passed multiple times as an array `pictograms[]`

#### PUT `/api/chemical/cas/<CAS Number>`
Updates a chemical with the following fields.
##### Parameters
* `cas` - string - CAS number
* `name` - string - name of the chemical
* `prefix` - string - prefix of the name which should not be used in alphabetical sorting (e.g. **1-**butanol)
* `haz_substance` - boolean - is the chemical a hazardous substance?
* `dg_class` - string - dangerous goods shipping class and subclass in the format `8 (3, 6.1)`. Can be used in place of `dg_class_1`, `dg_class_2` and `dg_class_3`
* `dg_class_1` - string - primary dangerous goods class
* `dg_class_2` - string - dangerous goods subclass
* `dg_class_3` - string - dangerous goods secondary subclass
* `packing_group` - string - shipping packing group
* `un_number` - string - UN number
* `un_proper_shipping_name` - string - UN proper shipping name
* `schedule` - string - SUSMP poisons schedule number <https://en.wikipedia.org/wiki/Standard_for_the_Uniform_Scheduling_of_Medicines_and_Poisons>
* `storage_temperature` - string - storage temperature in degrees Celsius. Either a single number of range separated by ~ (e.g. -20~-15)
* `inchi` - string - InChI string representation of the structure
* `smiles` - string - SMILES string representation of the structure
* `pubchem` - string - Pubchem ID
* `density` - string - density in g/mL
* `melting_point` - string - melting point in degrees Celsius
* `boiling_point` - string - boiling point in degrees Celsius
* `sds` - binary - a PDF of the SDS
* `signal_word` - string - GHS signal word
* `haz_stats` - string - GHS hazard statement code <https://unece.org/sites/default/files/2021-09/GHS_Rev9E_0.pdf>. can be passed multiple times as an array `haz_stats[]`
* `prec_stats` - string - GHS precaution statement code <https://unece.org/sites/default/files/2021-09/GHS_Rev9E_0.pdf>. can be passed multiple times as an array `prec_stats[]`
* `haz_classes` - string - GHS hazard classification. can be passed multiple times as an array `haz_classes[]`
* `pictograms` - string - GHS pictograms. can be passed multiple times as an array `pictograms[]`

### Containers
#### GET `/api/container`
Returns all containers and all associated information
##### Parameters
* `limit` - return a maximum of this many records
* `offset` - start at this record

#### POST `/api/container`
Creates a container with the following fields.
##### Parameters
* `location_id` - integer - ID of the location. Can be found using the GET `/api/location` endpoint.
* `supplier` - string - name of the supplier of the container.
* `quantity` - string - size of the container, as a number and an associated unit (e.g. `5 g`). Parsed into container_size and size_unit by the API. If this is not supplied, container_size and size_unit can be supplied instead.
* `container_size` - string - size of the container, number only.
* `size_unit` - string - unit for container_size.
* `barcode` - string - barcode for the container. If this is not supplied, a barcode is automatically generated.
* `description` - string - any descriptive text about the container.
* `product_number` - string - product number from the supplier.
* `lot_number` - string - lot number from the supplier.
* `owner_id` - string - ID of the owner of the chemical. Can be found using the GET `/api/user` endpoint.
* `cas` - string - CAS number of the chemical in the container. If this matches an existing CAS number, the following fields are not used. Otherwise the chemical is created as well.
* `name` - string - name of the chemical
* `prefix` - string - prefix of the name which should not be used in alphabetical sorting (e.g. **1-**butanol)
* `haz_substance` - boolean - is the chemical a hazardous substance?
* `dg_class` - string - dangerous goods shipping class and subclass in the format `8 (3, 6.1)`. Can be used in place of `dg_class_1`, `dg_class_2` and `dg_class_3`
* `dg_class_1` - string - primary dangerous goods class
* `dg_class_2` - string - dangerous goods subclass
* `dg_class_3` - string - dangerous goods secondary subclass
* `packing_group` - string - shipping packing group
* `un_number` - string - UN number
* `un_proper_shipping_name` - string - UN proper shipping name
* `schedule` - string - SUSMP poisons schedule number <https://en.wikipedia.org/wiki/Standard_for_the_Uniform_Scheduling_of_Medicines_and_Poisons>
* `storage_temperature` - string - storage temperature in degrees Celsius. Either a single number of range separated by ~ (e.g. -20~-15)
* `inchi` - string - InChI string representation of the structure
* `smiles` - string - SMILES string representation of the structure
* `pubchem` - string - Pubchem ID
* `density` - string - density in g/mL
* `melting_point` - string - melting point in degrees Celsius
* `boiling_point` - string - boiling point in degrees Celsius
* `sds` - binary - a PDF of the SDS
* `signal_word` - string - GHS signal word
* `haz_stats` - string - GHS hazard statement code <https://unece.org/sites/default/files/2021-09/GHS_Rev9E_0.pdf>. can be passed multiple times as an array `haz_stats[]`
* `prec_stats` - string - GHS precaution statement code <https://unece.org/sites/default/files/2021-09/GHS_Rev9E_0.pdf>. can be passed multiple times as an array `prec_stats[]`
* `haz_class_ids` - string - GHS hazard classification. can be passed multiple times as an array `haz_class_ids[]`
* `pictogram_ids` - string - GHS pictograms. can be passed multiple times as an array `pictogram_ids[]`

  
## Known Issues
* The dg_class_n_id columns must be filled sequentially. If you have dg_class_1_id and dg_class_3_id, but dg_class_2_id is null, only dg_class_1 will appear in the chemical detail page. This doesn't affect the api, where all dg_class objects are returned.

## Roadmap
* Sort chemical list
* Introduce some logic to populate pictograms, hazard classifications and precautionary statements from hazard statements per https://pubchem.ncbi.nlm.nih.gov/ghs/
* Allow the upload of SDSes and parse them automatically
* AJAX for all fields
* List chemicals by location
* Structure searching
* Flexible chemical structure storage/cheminformatics