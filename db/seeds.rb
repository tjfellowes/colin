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

create_packing_groups
create_dg_classes
create_schedules

