import csv
import pint
import requests
import json
import urllib
from prettytable import PrettyTable

from pint import UnitRegistry
ureg = UnitRegistry()

with open('inventory.csv') as csv_file:
  csv_reader = csv.reader(csv_file, dialect='excel', delimiter=',')
  line_count = 0
  cas_list = list()
  t = PrettyTable(['serial_number', 'cas', 'prefix', 'name', 'dg_class_id', 'dg_class_2_id', 'dg_class_3_id', 'schedule_id', 'container_size', 'size_unit', 'pg_id', 'un_number', 'haz_substance', 'location_id'])
  for row in csv_reader:
    if line_count:
      serial_number=str(row[0])
      cas=str(row[1])
      prefix=str(row[2])
      name=str(urllib.quote_plus(row[3]))


      if row[4]=='True': haz_substance='true'
      elif row[4]=='False': haz_substance='false'

      dg_class=str(row[5])
      dg_class_2=str(row[6])
      dg_class_3=str('')
      schedule=str(row[7])
      pg=str(row[8])

      un_number=str(row[9])

      container_size = str(row[10])
      size_unit = str(row[11])

      location=str(row[12])

      supplier_=str(row[13])


      #create container matching the chemical
      url = "http://colin-uom.herokuapp.com/api/container/serial/" + serial_number + "?cas=" + cas + "&prefix=" + prefix + "&name=" + name + "&dg_class=" + dg_class + "&dg_class_2=" + dg_class_2 + "dg_class_3=" + dg_class_3 + "&schedule=" + schedule +  "&packing_group=" + pg +  "&un_number=" + un_number + "&haz_substance=" + haz_substance + "&container_size=" + container_size + "&size_unit=" + size_unit + "&supplier=" + supplier + "&location=" + location
      if cas:
        requests.post(url).status_code

        t.add_row([serial_number, cas, prefix, name, dg_class, dg_class_2, dg_class_3, schedule, container_size, size_unit, pg, un_number, haz_substance, location])

    line_count += 1

  print(t)

