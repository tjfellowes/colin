SELECT DISTINCT ON (container_locations.container_id) 
serial_number AS barcode, 
cas, 
chemicals.prefix AS prefix, 
chemicals.name AS name, 
containers.description AS 
description, 
container_size, 
size_unit, 
date_purchased, 
date_disposed,
parent_location.name AS parent_location,
location.name AS location,
haz_substance, 
un_number,
dg_class_1.number AS dg_class_1,
dg_class_2.number AS dg_class_2,
dg_class_3.number AS dg_class_3,
packing_groups.name AS packing_group,
schedules.number AS schedule,
suppliers.name AS supplier
FROM container_locations 
INNER JOIN containers ON container_locations.container_id = containers.id
INNER JOIN chemicals ON containers.chemical_id = chemicals.id
INNER JOIN locations location ON container_locations.location_id = location.id
LEFT JOIN locations parent_location ON location.parent_id = parent_location.id
LEFT JOIN suppliers ON containers.supplier_id = suppliers.id
LEFT JOIN dg_classes dg_class_1 ON chemicals.dg_class_id = dg_class_1.id
LEFT JOIN dg_classes dg_class_2 ON chemicals.dg_class_2_id = dg_class_2.id
LEFT JOIN dg_classes dg_class_3 ON chemicals.dg_class_3_id = dg_class_3.id
LEFT JOIN schedules ON chemicals.schedule_id = schedules.id
LEFT JOIN packing_groups ON chemicals.packing_group_id = packing_groups.id
ORDER BY container_locations.container_id, container_locations.created_at DESC
;