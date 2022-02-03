require 'require_all'
require_all 'src'

include Colin::Models

def create_sublocation(parent_location, name, code, barcode, temperature, location_types_id)
  return Location.create! do |d|
    d.name = name
    d.code = code
    d.barcode = barcode
    d.temperature = temperature
    d.location_types_id = location_types_id
    d.parent_id = parent_location.id
  end
end

def add_test_data
  synlab = Location.create!(name: 'Synthetic Lab', code: 'Syn', barcode: '100000', temperature: '25', location_types_id: '2')
  cupboard = create_sublocation(synlab, 'Cupboard 1', 'C1', '100100', '25', '3')
  create_sublocation(cupboard, 'Box 1', 'B1', '100101', '25', '8')
  create_sublocation(cupboard, 'Box 2', 'B2', '100102', '25', '8')
  cupboard = create_sublocation(synlab, 'Cupboard 2', 'C2', '100200', '25', '3')
  create_sublocation(cupboard, 'Box 1', 'B1', '100201', '25', '8')
  create_sublocation(cupboard, 'Box 2', 'B2', '100202', '25', '8')
  fridge = create_sublocation(synlab, 'Fridge 1', 'F1', '100300', '4', '5')
  create_sublocation(fridge, 'Box 1', 'B1', '100201', '25', '8')

  Chemical.create!(cas: '1-1-1', name: 'bepis', haz_substance: true, sds_url: 'https://www.nug.com/sds', un_number: '1234', dg_class_1_id: '2', dg_class_2_id: '11', schedule_id: '1', packing_group_id: '1', storage_temperature_min: '69', storage_temperature_max: '420', un_proper_shipping_name: 'conke NOS', sds: File.open('db/seeds/sds.pdf', 'rb'), signal_word_id: '2', inchi: 'InChI=1S/C2H6O/c1-2-3/h3H,2H2,1H3', smiles: 'F/C=C/F', pubchem: '702', density: '1.5', melting_point: '20', boiling_point: '1000', created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601)

  Chemical.create!(cas: '1-3-1', prefix: 'super', name: 'conke', haz_substance: true, sds_url: 'https://www.nug.com/sds', un_number: '1234', dg_class_id: '2', dg_class_2_id: '11', schedule_id: '1', packing_group_id: '1', storage_temperature_min: '69', storage_temperature_max: '420', un_proper_shipping_name: 'conke NOS', sds: File.open('db/seeds/sds.pdf', 'rb'), signal_word_id: '2', inchi: 'InChI=1S/C2H6O/c1-2-3/h3H,2H2,1H3', smiles: 'F/C=C/F', pubchem: '702', density: '1.5', melting_point: '20', boiling_point: '1000', created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601)

  ChemicalHazClass.create!(chemical_id: '1', haz_class_id: '9', category: '3')
  ChemicalPictogram.create!(chemical_id: '1', pictogram_id: '3')
  ChemicalHazStat.create!(chemical_id: '1', haz_stat_id: '6')
  ChemicalHazStat.create!(chemical_id: '1', haz_stat_id: '9')
  ChemicalHazStat.create!(chemical_id: '1', haz_stat_id: '32')
  ChemicalPrecStat.create!(chemical_id: '1', prec_stat_id: '10')
  ChemicalPrecStat.create!(chemical_id: '1', prec_stat_id: '6')
  ChemicalPrecStat.create!(chemical_id: '1', prec_stat_id: '9')
  ChemicalPrecStat.create!(chemical_id: '1', prec_stat_id: '32')
  ChemicalPrecStatSupp.create!(chemical_prec_stat_id: '1', position: '1', information: 'Conke')

  Container.create!(barcode: '1101010', container_size: '50', size_unit: 'g', date_purchased: Time.now.utc.iso8601, chemical_id: '1', supplier_id: '1', description: 'stonky', product_number: '1010101010101_50G', lot_number: '900', user_id: '1', owner_id: '1', picture: File.open('db/seeds/bepis.jpg', 'rb'))

  Container.create!(barcode: '69', container_size: '50', size_unit: 'g', date_purchased: Time.now.utc.iso8601, chemical_id: '2', supplier_id: '1', description: 'stonky', product_number: '1010101010101_50G', lot_number: '900', user_id: '1', owner_id: '1', picture: File.open('db/seeds/bepis.jpg', 'rb'))

 

  ContainerLocation.create!(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: '1', location_id: '3')
  ContainerLocation.create!(created_at: Time.now.utc.iso8601, updated_at: Time.now.utc.iso8601, container_id: '2', location_id: '6')

  Supplier.create!(name: 'conke factory')
end

def create_users
  User.create!(username: 'root', name: 'root', email: 'root@root.com', password: 'root', supervisor_id: 1, hidden: true, can_create_container: true, can_edit_container: true, can_create_user: true, can_edit_user: true, can_create_location: true, can_edit_location: true)
end

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

def create_location_types
  LocationType.create!(name: 'Building')
  LocationType.create!(name: 'Room')
  LocationType.create!(name: 'Cupboard')
  LocationType.create!(name: 'Cabinet')
  LocationType.create!(name: 'Fridge')
  LocationType.create!(name: 'Freezer')
  LocationType.create!(name: 'Shelf')
  LocationType.create!(name: 'Box')
end

#https://unece.org/sites/default/files/2021-09/GHS_Rev9E_0.pdf
#https://pubchem.ncbi.nlm.nih.gov/ghs/
def create_prec_stats
  PrecStat.create!(code: 'P101', description: 'If medical advice is needed, have product container or label at hand.')
  PrecStat.create!(code: 'P102', description: 'Keep out of reach of children.')
  PrecStat.create!(code: 'P103', description: 'Read label before use')
  PrecStat.create!(code: 'P201', description: 'Obtain special instructions before use.')
  PrecStat.create!(code: 'P202', description: 'Do not handle until all safety precautions have been read and understood.')
  PrecStat.create!(code: 'P210', description: 'Keep away from heat, hot surface, sparks, open flames and other ignition sources. No smoking.')
  PrecStat.create!(code: 'P211', description: 'Do not spray on an open flame or other ignition source.')
  PrecStat.create!(code: 'P212', description: 'Avoid heating under confinement or reduction of the desensitized agent.')
  PrecStat.create!(code: 'P220', description: 'Keep away from clothing and other combustible materials.')
  PrecStat.create!(code: 'P221', description: 'Take any precaution to avoid mixing with $1.')
  PrecStat.create!(code: 'P222', description: 'Do not allow contact with air.')
  PrecStat.create!(code: 'P223', description: 'Do not allow contact with water.')
  PrecStat.create!(code: 'P230', description: 'Keep wetted with $1.')
  PrecStat.create!(code: 'P231', description: 'Handle under inert gas.')
  PrecStat.create!(code: 'P232', description: 'Protect from moisture.')
  PrecStat.create!(code: 'P233', description: 'Keep container tightly closed.')
  PrecStat.create!(code: 'P234', description: 'Keep only in original container.')
  PrecStat.create!(code: 'P235', description: 'Keep cool.')
  PrecStat.create!(code: 'P240', description: 'Ground/bond container and receiving equipment.')
  PrecStat.create!(code: 'P241', description: 'Use explosion-proof $1 equipment.')
  PrecStat.create!(code: 'P242', description: 'Use only non-sparking tools.')
  PrecStat.create!(code: 'P243', description: 'Take precautionary measures against static discharge.')
  PrecStat.create!(code: 'P244', description: 'Keep valves and fittings free from oil and grease.')
  PrecStat.create!(code: 'P250', description: 'Do not subject to $1.')
  PrecStat.create!(code: 'P251', description: 'Do not pierce or burn, even after use.')
  PrecStat.create!(code: 'P260', description: 'Do not breathe $1.')
  PrecStat.create!(code: 'P261', description: 'Avoid breathing $1.')
  PrecStat.create!(code: 'P262', description: 'Do not get in eyes, on skin, or on clothing.')
  PrecStat.create!(code: 'P263', description: 'Avoid contact during pregnancy/while nursing.')
  PrecStat.create!(code: 'P264', description: 'Wash $1 thoroughly after handling.')
  PrecStat.create!(code: 'P270', description: 'Do not eat, drink or smoke when using this product.')
  PrecStat.create!(code: 'P271', description: 'Use only outdoors or in a well-ventilated area.')
  PrecStat.create!(code: 'P272', description: 'Contaminated work clothing should not be allowed out of the workplace.')
  PrecStat.create!(code: 'P273', description: 'Avoid release to the environment.')
  PrecStat.create!(code: 'P280', description: 'Wear protective gloves/protective clothing/eye protection/face protection.')
  PrecStat.create!(code: 'P281', description: 'Use personal protective equipment as required.')
  PrecStat.create!(code: 'P282', description: 'Wear cold insulating gloves/face shield/eye protection.')
  PrecStat.create!(code: 'P283', description: 'Wear fire resistant or flame retardant clothing.')
  PrecStat.create!(code: 'P284', description: 'Wear respiratory protection.')
  PrecStat.create!(code: 'P285', description: 'In case of inadequate ventilation wear respiratory protection.')
  PrecStat.create!(code: 'P231+P232', description: 'Handle under $1. Protect from moisture.')
  PrecStat.create!(code: 'P235+P410', description: 'Keep cool. Protect from sunlight.')
  PrecStat.create!(code: 'P301', description: 'IF SWALLOWED: $1.')
  PrecStat.create!(code: 'P302', description: 'IF ON SKIN: $1.')
  PrecStat.create!(code: 'P303', description: 'IF ON SKIN (or hair): $1.')
  PrecStat.create!(code: 'P304', description: 'IF INHALED: $1.')
  PrecStat.create!(code: 'P305', description: 'IF IN EYES: $1.')
  PrecStat.create!(code: 'P306', description: 'IF ON CLOTHING: $1.')
  PrecStat.create!(code: 'P307', description: 'IF exposed: $1.')
  PrecStat.create!(code: 'P308', description: 'IF exposed or concerned:')
  PrecStat.create!(code: 'P309', description: 'IF exposed or if you feel unwell')
  PrecStat.create!(code: 'P310', description: 'Immediately call a POISON CENTER or doctor/physician.')
  PrecStat.create!(code: 'P311', description: 'Call a $1.')
  PrecStat.create!(code: 'P312', description: 'Call a $1 if you feel unwell.')
  PrecStat.create!(code: 'P313', description: 'Get medical advice/attention.')
  PrecStat.create!(code: 'P314', description: 'Get medical advice/attention if you feel unwell.')
  PrecStat.create!(code: 'P315', description: 'Get immediate medical advice/attention.')
  PrecStat.create!(code: 'P320', description: 'Specific treatment is urgent (see $1 on this label).')
  PrecStat.create!(code: 'P321', description: 'Specific treatment (see $1 on this label).')
  PrecStat.create!(code: 'P322', description: 'Specific measures (see $1 on this label).')
  PrecStat.create!(code: 'P330', description: 'Rinse mouth.')
  PrecStat.create!(code: 'P331', description: 'Do NOT induce vomiting.')
  PrecStat.create!(code: 'P332', description: 'IF SKIN irritation occurs: $1')
  PrecStat.create!(code: 'P333', description: 'If skin irritation or rash occurs: $1')
  PrecStat.create!(code: 'P334', description: 'Immerse in cool water [or wrap in wet bandages].')
  PrecStat.create!(code: 'P335', description: 'Brush off loose particles from skin.')
  PrecStat.create!(code: 'P336', description: 'Thaw frosted parts with lukewarm water. Do not rub affected area.')
  PrecStat.create!(code: 'P337', description: 'If eye irritation persists:')
  PrecStat.create!(code: 'P338', description: 'Remove contact lenses, if present and easy to do. Continue rinsing.')
  PrecStat.create!(code: 'P340', description: 'Remove victim to fresh air and keep at rest in a position comfortable for breathing.')
  PrecStat.create!(code: 'P341', description: 'If breathing is difficult, remove victim to fresh air and keep at rest in a position comfortable for breathing.')
  PrecStat.create!(code: 'P342', description: 'If experiencing respiratory symptoms:')
  PrecStat.create!(code: 'P350', description: 'Gently wash with plenty of soap and water.')
  PrecStat.create!(code: 'P351', description: 'Rinse cautiously with water for several minutes.')
  PrecStat.create!(code: 'P352', description: 'Wash with plenty of $1.')
  PrecStat.create!(code: 'P353', description: 'Rinse skin with water [or shower].')
  PrecStat.create!(code: 'P360', description: 'Rinse immediately contaminated clothing and skin with plenty of water before removing clothes.')
  PrecStat.create!(code: 'P361', description: 'Take off immediately all contaminated clothing.')
  PrecStat.create!(code: 'P362', description: 'Take off contaminated clothing.')
  PrecStat.create!(code: 'P363', description: 'Wash contaminated clothing before reuse.')
  PrecStat.create!(code: 'P364', description: 'And wash it before reuse.[Added in 2015 version]')
  PrecStat.create!(code: 'P370', description: 'In case of fire:')
  PrecStat.create!(code: 'P371', description: 'In case of major fire and large quantities:')
  PrecStat.create!(code: 'P372', description: 'Explosion risk.')
  PrecStat.create!(code: 'P373', description: 'DO NOT fight fire when fire reaches explosives.')
  PrecStat.create!(code: 'P374', description: 'Fight fire with normal precautions from a reasonable distance.')
  PrecStat.create!(code: 'P376', description: 'Stop leak if safe to do so.')
  PrecStat.create!(code: 'P377', description: 'Leaking gas fire: Do not extinguish, unless leak can be stopped safely.')
  PrecStat.create!(code: 'P378', description: 'Use $1 to extinguish.')
  PrecStat.create!(code: 'P380', description: 'Evacuate area.')
  PrecStat.create!(code: 'P381', description: 'In case of leakage, eliminate all ignition sources.')
  PrecStat.create!(code: 'P390', description: 'Absorb spillage to prevent material damage.')
  PrecStat.create!(code: 'P391', description: 'Collect spillage.')
  PrecStat.create!(code: 'P301+P310', description: 'IF SWALLOWED: Immediately call a $1.')
  PrecStat.create!(code: 'P301+P312', description: 'IF SWALLOWED: call a $1 IF you feel unwell.')
  PrecStat.create!(code: 'P301+P330+P331', description: 'IF SWALLOWED: Rinse mouth. Do NOT induce vomiting.')
  PrecStat.create!(code: 'P302+P334', description: 'IF ON SKIN: Immerse in cool water [or wrap in wet bandages].')
  PrecStat.create!(code: 'P302+P335+P334', description: 'Brush off loose particles from skin. Immerse in cool water [or wrap in wet bandages].')
  PrecStat.create!(code: 'P302+P350', description: 'IF ON SKIN: Gently wash with plenty of soap and water.')
  PrecStat.create!(code: 'P302+P352', description: 'IF ON SKIN: wash with plenty of water.')
  PrecStat.create!(code: 'P303+P361+P353', description: 'IF ON SKIN (or hair): Take off Immediately all contaminated clothing. Rinse SKIN with water [or shower].')
  PrecStat.create!(code: 'P304+P312', description: 'IF INHALED: Call a $1 if you feel unwell.')
  PrecStat.create!(code: 'P304+P340', description: 'IF INHALED: Remove person to fresh air and keep comfortable for breathing.')
  PrecStat.create!(code: 'P304+P341', description: 'IF INHALED: If breathing is difficult, remove victim to fresh air and keep at rest in a position comfortable for breathing.')
  PrecStat.create!(code: 'P305+P351+P338', description: 'IF IN EYES: Rinse cautiously with water for several minutes. Remove contact lenses if present and easy to do - continue rinsing.')
  PrecStat.create!(code: 'P306+P360', description: 'IF ON CLOTHING: Rinse Immediately contaminated CLOTHING and SKIN with plenty of water before removing clothes.')
  PrecStat.create!(code: 'P307+P311', description: 'IF exposed: call a POISON CENTER or doctor/physician.')
  PrecStat.create!(code: 'P308+P311', description: 'IF exposed or concerned: Call a $1')
  PrecStat.create!(code: 'P308+P313', description: 'IF exposed or concerned: Get medical advice/attention.')
  PrecStat.create!(code: 'P309+P311', description: 'IF exposed or if you feel unwell: call a POISON CENTER or doctor/physician.')
  PrecStat.create!(code: 'P332+P313', description: 'IF SKIN irritation occurs: Get medical advice/attention.')
  PrecStat.create!(code: 'P333+P313', description: 'IF SKIN irritation or rash occurs: Get medical advice/attention.')
  PrecStat.create!(code: 'P335+P334', description: 'Brush off loose particles from skin. Immerse in cool water/wrap in wet bandages.')
  PrecStat.create!(code: 'P337+P313', description: 'IF eye irritation persists: Get medical advice/attention.')
  PrecStat.create!(code: 'P342+P311', description: 'IF experiencing respiratory symptoms: Call a $1.')
  PrecStat.create!(code: 'P361+P364', description: 'Take off immediately all contaminated clothing and wash it before reuse.')
  PrecStat.create!(code: 'P362+P364', description: 'Take off contaminated clothing and wash it before reuse.')
  PrecStat.create!(code: 'P370+P376', description: 'in case of fire: Stop leak if safe to do so.')
  PrecStat.create!(code: 'P370+P378', description: 'In case of fire: Use $1 to extinguish.')
  PrecStat.create!(code: 'P370+P380', description: 'In case of fire: Evacuate area.')
  PrecStat.create!(code: 'P370+P380+P375', description: 'In case of fire: Evacuate area. Fight fire remotely due to the risk of explosion.')
  PrecStat.create!(code: 'P371+P380+P375', description: 'In case of major fire and large quantities: Evacuate area. Fight fire remotely due to the risk of explosion.')
  PrecStat.create!(code: 'P401', description: 'Store in accordance with $1.')
  PrecStat.create!(code: 'P402', description: 'Store in a dry place.')
  PrecStat.create!(code: 'P403', description: 'Store in a well-ventilated place.')
  PrecStat.create!(code: 'P404', description: 'Store in a closed container.')
  PrecStat.create!(code: 'P405', description: 'Store locked up.')
  PrecStat.create!(code: 'P406', description: 'Store in $1 container with a resistant inner liner.')
  PrecStat.create!(code: 'P407', description: 'Maintain air gap between stacks or pallets.')
  PrecStat.create!(code: 'P410', description: 'Protect from sunlight.')
  PrecStat.create!(code: 'P411', description: 'Store at temperatures not exceeding $1.')
  PrecStat.create!(code: 'P412', description: 'Do not expose to temperatures exceeding $1.')
  PrecStat.create!(code: 'P413', description: 'Store bulk masses greater than $1 at temperatures not exceeding $2.')
  PrecStat.create!(code: 'P420', description: 'Store separately.')
  PrecStat.create!(code: 'P422', description: 'Store contents under $1')
  PrecStat.create!(code: 'P402+P404', description: 'Store in a dry place. Store in a closed container.')
  PrecStat.create!(code: 'P403+P233', description: 'Store in a well-ventilated place. Keep container tightly closed.')
  PrecStat.create!(code: 'P403+P235', description: 'Store in a well-ventilated place. Keep cool.')
  PrecStat.create!(code: 'P410+P403', description: 'Protect from sunlight. Store in a well-ventilated place.')
  PrecStat.create!(code: 'P410+P412', description: 'Protect from sunlight. Do not expose to temperatures exceeding $1.')
  PrecStat.create!(code: 'P411+P235', description: 'Store at temperatures not exceeding $1. Keep cool.')
  PrecStat.create!(code: 'P501', description: 'Dispose of contents/container to $1.')
  PrecStat.create!(code: 'P502', description: 'Refer to manufacturer or supplier for information on recovery or recycling.')
end

def create_haz_stats
#http://www.chemsafetypro.com/Topics/GHS/GHS_hazard_statement_h_code.html
  HazStat.create!(code: 'H200', description: 'Unstable explosive')
  HazStat.create!(code: 'H201', description: 'Explosive; mass explosion hazard')
  HazStat.create!(code: 'H202', description: 'Explosive; severe projection hazard')
  HazStat.create!(code: 'H203', description: 'Explosive; fire, blast or projection hazard')
  HazStat.create!(code: 'H204', description: 'Fire or projection hazard')
  HazStat.create!(code: 'H205', description: 'May mass explode in fire')
  HazStat.create!(code: 'H206', description: 'Fire, blast or projection hazard; increased risk of explosion if desensitizing agent is reduced')
  HazStat.create!(code: 'H207', description: 'Fire or projection hazard; increased risk of explosion if desensitizing agent is reduced')
  HazStat.create!(code: 'H208', description: 'Fire hazard; increased risk of explosion if desensitizing agent is reduced')
  HazStat.create!(code: 'H220', description: 'Extremely flammable gas')
  HazStat.create!(code: 'H221', description: 'Flammable gas')
  HazStat.create!(code: 'H222', description: 'Extremely flammable aerosol')
  HazStat.create!(code: 'H223', description: 'Flammable aerosol')
  HazStat.create!(code: 'H224', description: 'Extremely flammable liquid and vapour')
  HazStat.create!(code: 'H225', description: 'Highly flammable liquid and vapour')
  HazStat.create!(code: 'H226', description: 'Flammable liquid and vapour')
  HazStat.create!(code: 'H227', description: 'Combustible liquid')
  HazStat.create!(code: 'H228', description: 'Flammable solid')
  HazStat.create!(code: 'H229', description: 'Pressurized container')
  HazStat.create!(code: 'H230', description: 'May react explosively even in the absence of air')
  HazStat.create!(code: 'H231', description: 'May react explosively even in the absence of air at elevated pressure and/or temperature')
  HazStat.create!(code: 'H232', description: 'May ignite spontaneously if exposed to air')
  HazStat.create!(code: 'H240', description: 'Heating may cause an explosion')
  HazStat.create!(code: 'H241', description: 'Heating may cause a fire or explosion')
  HazStat.create!(code: 'H242', description: 'Heating may cause a fire')
  HazStat.create!(code: 'H250', description: 'Catches fire spontaneously if exposed to air')
  HazStat.create!(code: 'H251', description: 'Self-heating; may catch fire')
  HazStat.create!(code: 'H252', description: 'Self-heating in large quantities; may catch fire')
  HazStat.create!(code: 'H260', description: 'In contact with water releases flammable gases which may ignite spontaneously')
  HazStat.create!(code: 'H261', description: 'In contact with water releases flammable gas')
  HazStat.create!(code: 'H270', description: 'May cause or intensify fire; oxidizer')
  HazStat.create!(code: 'H271', description: 'May cause fire or explosion; strong oxidizer')
  HazStat.create!(code: 'H272', description: 'May intensify fire; oxidizer')
  HazStat.create!(code: 'H280', description: 'Contains gas under pressure; may explode if heated')
  HazStat.create!(code: 'H281', description: 'Contains refrigerated gas; may cause cryogenic burns or injury')
  HazStat.create!(code: 'H290', description: 'May be corrosive to metals')
  HazStat.create!(code: 'H300', description: 'Fatal if swallowed')
  HazStat.create!(code: 'H301', description: 'Toxic if swallowed')
  HazStat.create!(code: 'H302', description: 'Harmful if swallowed')
  HazStat.create!(code: 'H303', description: 'May be harmful if swallowed')
  HazStat.create!(code: 'H304', description: 'May be fatal if swallowed and enters airways')
  HazStat.create!(code: 'H305', description: 'May be harmful if swallowed and enters airways')
  HazStat.create!(code: 'H310', description: 'Fatal in contact with skin')
  HazStat.create!(code: 'H311', description: 'Toxic in contact with skin')
  HazStat.create!(code: 'H312', description: 'Harmful in contact with skin')
  HazStat.create!(code: 'H313', description: 'May be harmful in contact with skin')
  HazStat.create!(code: 'H314', description: 'Causes severe skin burns and eye damage')
  HazStat.create!(code: 'H315', description: 'Causes skin irritation')
  HazStat.create!(code: 'H316', description: 'Causes mild skin irritation')
  HazStat.create!(code: 'H317', description: 'May cause an allergic skin reaction')
  HazStat.create!(code: 'H318', description: 'Causes serious eye damage')
  HazStat.create!(code: 'H319', description: 'Causes serious eye irritation')
  HazStat.create!(code: 'H320', description: 'Causes eye irritation')
  HazStat.create!(code: 'H330', description: 'Fatal if inhaled')
  HazStat.create!(code: 'H331', description: 'Toxic if inhaled')
  HazStat.create!(code: 'H332', description: 'Harmful if inhaled')
  HazStat.create!(code: 'H333', description: 'May be harmful if inhaled')
  HazStat.create!(code: 'H334', description: 'May cause allergy or asthma symptoms or breathing difficulties if inhaled')
  HazStat.create!(code: 'H335', description: 'May cause respiratory irritation')
  HazStat.create!(code: 'H336', description: 'May cause drowsiness or dizziness')
  HazStat.create!(code: 'H340', description: 'May cause genetic defects')
  HazStat.create!(code: 'H341', description: 'Suspected of causing genetic defects')
  HazStat.create!(code: 'H350', description: 'May cause cancer')
  HazStat.create!(code: 'H351', description: 'Suspected of causing cancer')
  HazStat.create!(code: 'H360', description: 'May damage fertility or the unborn child')
  HazStat.create!(code: 'H361', description: 'Suspected of damaging fertility or the unborn child')
  HazStat.create!(code: 'H361d', description: 'Suspected of damaging the unborn child')
  HazStat.create!(code: 'H362', description: 'May cause harm to breast-fed children')
  HazStat.create!(code: 'H370', description: 'Causes damage to organs')
  HazStat.create!(code: 'H371', description: 'May cause damage to organs')
  HazStat.create!(code: 'H372', description: 'Causes damage to organs through prolonged or repeated exposure')
  HazStat.create!(code: 'H373', description: 'May cause damage to organs through prolonged or repeated exposure')
  HazStat.create!(code: 'H400', description: 'Very toxic to aquatic life')
  HazStat.create!(code: 'H401', description: 'Toxic to aquatic life')
  HazStat.create!(code: 'H402', description: 'Harmful to aquatic life')
  HazStat.create!(code: 'H410', description: 'Very toxic to aquatic life with long-lasting effects')
  HazStat.create!(code: 'H411', description: 'Toxic to aquatic life with long-lasting effects')
  HazStat.create!(code: 'H412', description: 'Harmful to aquatic life with long-lasting effects')
  HazStat.create!(code: 'H413', description: 'May cause long-lasting harmful effects to aquatic life')
  HazStat.create!(code: 'H420', description: 'Harms public health and the environment by destroying ozone in the upper atmosphere')
end

def create_haz_classes
  HazClass.create!(description: 'Explosives')
  HazClass.create!(description: 'Flammable gases')
  HazClass.create!(description: 'Flammable aerosols')
  HazClass.create!(description: 'Oxidising gases')
  HazClass.create!(description: 'Gases under pressure')
  HazClass.create!(description: 'Flammable liquids')
  HazClass.create!(description: 'Flammable solids')
  HazClass.create!(description: 'Self-reactive substances')
  HazClass.create!(description: 'Pyrophoric solids')
  HazClass.create!(description: 'Pyrophoric liquids')
  HazClass.create!(description: 'Self-heating substances')
  HazClass.create!(description: 'Substances which in contact with water emit flammable gases')
  HazClass.create!(description: 'Oxidising liquids')
  HazClass.create!(description: 'Oxidising solids')
  HazClass.create!(description: 'Organic peroxides')
  HazClass.create!(description: 'Substances corrosive to metal')
  HazClass.create!(description: 'Acute toxicity')
  HazClass.create!(description: 'Skin corrosion')
  HazClass.create!(description: 'Skin irritation')
  HazClass.create!(description: 'Eye effects')
  HazClass.create!(description: 'Sensitisation (Skin or Eye)')
  HazClass.create!(description: 'Germ cell mutagenicity')
  HazClass.create!(description: 'Carcinogenicity')
  HazClass.create!(description: 'Reproductive toxicity')
  HazClass.create!(description: 'Target organ systemic toxicity: single and repeated exposure')
  HazClass.create!(description: 'Aspiration toxicity')
  HazClass.create!(description: 'Acute aquatic toxicity')
  HazClass.create!(description: 'Chronic aquatic toxicity')
end

def create_pictograms
  Pictogram.create!(name: 'Compressed gas', picture: File.open("db/seeds/images/compressed_gas.jpg", "rb").read)
  Pictogram.create!(name: 'Corrosive', picture: File.open("db/seeds/images/corrosive.jpg", "rb").read)
  Pictogram.create!(name: 'Ecotoxic', picture: File.open("db/seeds/images/ecotoxic.jpg", "rb").read)
  Pictogram.create!(name: 'Explosive', picture: File.open("db/seeds/images/explosive.jpg", "rb").read)
  Pictogram.create!(name: 'Flammable', picture: File.open("db/seeds/images/flammable.jpg", "rb").read)
  Pictogram.create!(name: 'Harmful', picture: File.open("db/seeds/images/harmful.jpg", "rb").read)
  Pictogram.create!(name: 'Irritant', picture: File.open("db/seeds/images/irritant.jpg", "rb").read)
  Pictogram.create!(name: 'Oxidant', picture: File.open("db/seeds/images/oxidant.jpg", "rb").read)
  Pictogram.create!(name: 'Toxic', picture: File.open("db/seeds/images/toxic.jpg", "rb").read)
end

def create_signal_words
  SignalWord.create!(name: 'Warning')
  SignalWord.create!(name: 'Danger')
end

create_packing_groups
create_dg_classes
create_schedules
create_users
create_location_types
create_prec_stats
create_haz_stats
create_haz_classes
create_pictograms
create_signal_words
