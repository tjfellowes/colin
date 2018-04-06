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
  DGClass.create! do |d|
    d.number = number
    d.description = description
    d.superclass_id = dg_class.id
  end
end

def create_dg_classes
  # Refer to https://policies.anu.edu.au/ppl/download/ANUP_001154
  # Explosives
  explosives = DGClass.create!(number: 1, description: 'Explosives')
  create_dg_division(explosives, 1, 'Substances that have a mass explosion hazard')
  create_dg_division(explosives, 2, 'Substances and articles that have a projection hazard, but not a mass explosion hazard')
  create_dg_division(explosives, 3, 'Substances or articles that have a fire hazard and either a minor blast hazard or minor projection hazard, or both, but not a mass explosion hazard')
  create_dg_division(explosives, 4, 'Substances and articles that present no significant hazard. The effect would be confined to the package and no projection of fragments of size or range is expected')
  create_dg_division(explosives, 5, 'Very insensitive substances that have a mass explosion hazard. These substances have a low probability of initiation or of transition from burning to detonation under normal conditions of transport')
  create_dg_division(explosives, 6, 'Extremely insensitive articles that do not have a mass explosion hazard')

  # Gases
  gases = DGClass.create!(number: 2, description: 'Gases')
  create_dg_division(gases, 1, 'Flammable gases')
  create_dg_division(gases, 2, 'Non-flammable, non-toxic gases')
  create_dg_division(gases, 3, 'Toxic gases')

  # Flammable Liquids
  DGClass.create!(number: 3, description: 'Flammable Liquids')

  # Flammable solids
  flamsol = DGClass.create!(number: 4, description: 'Flammable Solids')
  create_dg_division(flamsol, 1, 'Flammable solids')
  create_dg_division(flamsol, 2, 'Spontaneously combustible')
  create_dg_division(flamsol, 3, 'Dangerous when wet')

  # Oxidising
  ox = DGClass.create!(number: 5, description: 'Oxidising Substances and Organic Peroxides')
  create_dg_division(ox, 1, 'Oxidizing Substances')
  create_dg_division(ox, 1, 'Organic Peroxides')

  # Toxic
  toxic = DGClass.create!(number: 6, description: 'Toxic and Infectious Substances')
  create_dg_division(toxic, 1, 'Toxic Substances')
  create_dg_division(toxic, 2, 'Infectious Substances')

  # Radioactive
  DGClass.create!(number: 7, description: 'Radioactive Substances')

  # Corrosives
  DGClass.create(number: 8, description: 'Corrosives')

  # Misc
  DGClass.create(number: 9, description: 'Miscellaneous Goods')
end

def create_size_units
  SizeUnit.create!(name: 'milligram', symbol: 'mg', multiplier: 0.001)
  SizeUnit.create!(name: 'gram', symbol: 'g', multiplier: 1)
  SizeUnit.create!(name: 'kilogram', symbol: 'kg', multiplier: 1000)
  SizeUnit.create!(name: 'microlitre', symbol: 'uL', multiplier: 0.001)
  SizeUnit.create!(name: 'millilitre', symbol: 'mL', multiplier: 1)
  SizeUnit.create!(name: 'litre', symbol: 'L', multiplier: 1000)
end

def create_storage_classes
  StorageClass.create!(name: 'Harmful')
  StorageClass.create!(name: 'Toxic')
  StorageClass.create!(name: 'Non-hazardous')
  StorageClass.create!(name: 'Fridge')
  StorageClass.create!(name: 'Freezer')
  StorageClass.create!(name: 'Flammable liquid')
  StorageClass.create!(name: 'Flammable solid')
  StorageClass.create!(name: 'Dangerous when wet')
  StorageClass.create!(name: 'Oxidant')
  StorageClass.create!(name: 'Corrosive')
end

create_packing_groups
create_dg_classes
create_schedules
create_size_units
create_storage_classes
