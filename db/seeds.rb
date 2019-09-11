require 'require_all'
require_all 'src'

include Colin::Models

def create_packing_groups
  PackingGroup.create!(name: 'I')
  PackingGroup.create!(name: 'II')
  PackingGroup.create!(name: 'III')
end

def create_schedules
  Schedule.create!(number: 1, description: nil)
  Schedule.create!(number: 2, description: 'Pharmacy Medicine')
  Schedule.create!(number: 3, description: 'Pharmacist Only Medicine')
  Schedule.create!(number: 4, description: 'Prescription only Medicine')
  Schedule.create!(number: 5, description: 'Low Harm Poison')
  Schedule.create!(number: 6, description: 'Moderate Harm Poison')
  Schedule.create!(number: 7, description: 'Dangerous Poison')
  Schedule.create!(number: 8, description: 'Controlled Medicine')
  Schedule.create!(number: 9, description: 'Prohibited Substance')
end

def create_dg_division(dg_class, number, description)
  DgClass.create! do |d|
    d.number = number
    d.description = description
    d.superclass_id = dg_class.id
  end
end

def create_dg_classes
  # Refer to https://policies.anu.edu.au/ppl/download/ANUP_001154
  # Explosives
  explosives = DgClass.create!(number: '1', description: 'Explosives')
  create_dg_division(explosives, '1.1', 'Substances that have a mass explosion hazard')
  create_dg_division(explosives, '1.2', 'Substances and articles that have a projection hazard, but not a mass explosion hazard')
  create_dg_division(explosives, '1.3', 'Substances or articles that have a fire hazard and either a minor blast hazard or minor projection hazard, or both, but not a mass explosion hazard')
  create_dg_division(explosives, '1.4', 'Substances and articles that present no significant hazard. The effect would be confined to the package and no projection of fragments of size or range is expected')
  create_dg_division(explosives, '1.5', 'Very insensitive substances that have a mass explosion hazard. These substances have a low probability of initiation or of transition from burning to detonation under normal conditions of transport')
  create_dg_division(explosives, '1.6', 'Extremely insensitive articles that do not have a mass explosion hazard')

  # Gases
  gases = DgClass.create!(number: '2', description: 'Gases')
  create_dg_division(gases, '2.1', 'Flammable gases')
  create_dg_division(gases, '2.2', 'Non-flammable, non-toxic gases')
  create_dg_division(gases, '2.3', 'Toxic gases')

  # Flammable Liquids
  DgClass.create!(number: '3', description: 'Flammable Liquids')

  # Flammable solids
  flamsol = DgClass.create!(number: '4', description: 'Flammable Solids')
  create_dg_division(flamsol, '4.1', 'Flammable solids')
  create_dg_division(flamsol, '4.2', 'Spontaneously combustible')
  create_dg_division(flamsol, '4.3', 'Dangerous when wet')

  # Oxidising
  ox = DgClass.create!(number: '5', description: 'Oxidising Substances and Organic Peroxides')
  create_dg_division(ox, '5.1', 'Oxidizing Substances')
  create_dg_division(ox, '5.2', 'Organic Peroxides')

  # Toxic
  toxic = DgClass.create!(number: '6', description: 'Toxic and Infectious Substances')
  create_dg_division(toxic, '6.1', 'Toxic Substances')
  create_dg_division(toxic, '6.2', 'Infectious Substances')

  # Radioactive
  DgClass.create!(number: '7', description: 'Radioactive Substances')

  # Corrosives
  DgClass.create(number: '8', description: 'Corrosives')

  # Misc
  DgClass.create(number: '9', description: 'Miscellaneous Goods')
end

def create_location_division(location, name)
  Location.create! do |d|
    d.name = name
    d.parent_id = location.id
    d.name_fulltext = location.name + " " + name
  end
end

def create_locations
  harmful = Location.create!(name: 'Harmful', name_fulltext: 'Harmful')
  create_location_division(harmful, 'H1')
  create_location_division(harmful, 'H2')
  create_location_division(harmful, 'H3')
  create_location_division(harmful, 'H4')
  create_location_division(harmful, 'H5')
  create_location_division(harmful, 'H6')
  create_location_division(harmful, 'H7')
  create_location_division(harmful, 'H8')
  create_location_division(harmful, 'H9')
  create_location_division(harmful, 'H10')
  create_location_division(harmful, 'H11')
  create_location_division(harmful, 'H12')
  create_location_division(harmful, 'H13')
  create_location_division(harmful, 'H14')
  create_location_division(harmful, 'H15')
  create_location_division(harmful, 'H16')
  create_location_division(harmful, 'H17')
  create_location_division(harmful, 'H18')
  create_location_division(harmful, 'H19')
  create_location_division(harmful, 'H20')
  create_location_division(harmful, 'H21')
  create_location_division(harmful, 'H22')
  create_location_division(harmful, 'H23')
  create_location_division(harmful, 'H24')
  create_location_division(harmful, 'H25')
  create_location_division(harmful, 'H26')
  create_location_division(harmful, 'H27')
  create_location_division(harmful, 'Dessicator')

  toxic = Location.create!(name: 'Toxic', name_fulltext: 'Toxic')
  create_location_division(toxic, 'TS1')
  create_location_division(toxic, 'TS2')
  create_location_division(toxic, 'TS3')
  create_location_division(toxic, 'TM1')
  create_location_division(toxic, 'TM2')
  create_location_division(toxic, 'TM3')
  create_location_division(toxic, 'TM4')
  create_location_division(toxic, 'TM5')
  create_location_division(toxic, 'TM6')
  create_location_division(toxic, 'TL1')
  create_location_division(toxic, 'TL2')
  create_location_division(toxic, 'TL3')
  create_location_division(toxic, 'TL4')
  create_location_division(toxic, 'TXL')
  create_location_division(toxic, 'Dessicator')

  corrosive = Location.create!(name: 'Corrosive', name_fulltext: 'Corrosive')
  create_location_division(corrosive, 'Acid 1')
  create_location_division(corrosive, 'Acid 2')
  create_location_division(corrosive, 'Base 1')
  create_location_division(corrosive, 'Base 2')
  create_location_division(corrosive, 'Base 3')
  create_location_division(corrosive, 'Base 4')
  create_location_division(corrosive, 'Dessicator')

  fridge = Location.create!(name: 'Fridge', name_fulltext: 'Fridge')
  create_location_division(fridge, 'Bottom draw')
  create_location_division(fridge, 'Door')
  create_location_division(fridge, 'S1')
  create_location_division(fridge, 'S1 B1')
  create_location_division(fridge, 'S1 B3')
  create_location_division(fridge, 'S2 B1')
  create_location_division(fridge, 'S2 B2')
  create_location_division(fridge, 'S3')
  create_location_division(fridge, 'S3 B1')
  create_location_division(fridge, 'S4')
  create_location_division(fridge, 'S4 B1')

  freezer =Location.create!(name: 'Freezer', name_fulltext: 'Freezer')
  create_location_division(freezer, '1 S1')
  create_location_division(freezer, '1 S1 B1')
  create_location_division(freezer, '1 S2 B1')
  create_location_division(freezer, '1 S2 B2')
  create_location_division(freezer, '1 S2 B3')
  create_location_division(freezer, '1 S3 B1')
  create_location_division(freezer, '1 S4 B1')
  create_location_division(freezer, '1 S4 B2')
  create_location_division(freezer, '1 S5 B1')
  create_location_division(freezer, '2')
  create_location_division(freezer, '3')

  flammable_liquid = Location.create!(name: 'Flammable liquid', name_fulltext: 'Flammable liquid')
  create_location_division(flammable_liquid, 'Large')
  create_location_division(flammable_liquid, 'Small')

  flammable_solid = Location.create!(name: 'Flammable solid', name_fulltext: 'Flammable solid')
  create_location_division(flammable_solid, 'Dessicator 1')
  create_location_division(flammable_solid, 'Dessicator 2')

  poison = Location.create!(name: 'Poisons', name_fulltext: 'Poisons')
  create_location_division(poison, 'Draw 1')
  create_location_division(poison, 'Draw 2')
  create_location_division(poison, 'Draw 3')

  bench = Location.create!(name: 'Benches', name_fulltext: 'Benches')
  create_location_division(bench, '1')
  create_location_division(bench, '2')
  create_location_division(bench, '3')
  create_location_division(bench, '4')
  create_location_division(bench, '5')
  create_location_division(bench, '6')
  create_location_division(bench, '7')
  create_location_division(bench, '8')
  create_location_division(bench, '9')
  create_location_division(bench, '10')
  create_location_division(bench, '11')
  create_location_division(bench, '12')
  create_location_division(bench, '13')
  create_location_division(bench, '14')

  Location.create!(name: 'Dangerous when wet', name_fulltext: 'Dangerous when wet')
  Location.create!(name: 'Oxidants', name_fulltext: 'Oxidants')
  Location.create!(name: 'Non-hazardous', name_fulltext: 'Non-hazardous')
  Location.create!(name: 'Chromatography/filtration aids', name_fulltext: 'Chromatography/filtration aids')
  Location.create!(name: 'Deuterates dessicator', name_fulltext: 'Deuterates dessicator')
  Location.create!(name: 'Sieves/drying agents', name_fulltext: 'Sieves/drying agents')
  Location.create!(name: 'Non-flammable solvents', name_fulltext: 'Non-flammable solvents')

end


create_packing_groups
create_dg_classes
create_schedules
create_locations
