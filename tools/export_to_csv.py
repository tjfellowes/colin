import pint
#import csv
import unicodecsv as csv
import requests
import json
import urllib
from prettytable import PrettyTable
from pint import UnitRegistry

ureg = UnitRegistry()
ureg.define('None = 0')


inventory = requests.get('http://localhost:9292/api/container/all').json()

with open('exported_inventory.csv', 'w+') as csv_file:
  csv_writer = csv.writer(csv_file, dialect='excel', delimiter=',')
  line_count = 0

  t = PrettyTable()
  t.field_names = ["Serial No.", "CAS No.", "Name", "DG Class", "Subrisk", "Schedule", "Packing Group", "UN No.", "Size", "Location"]
  t.align['Name'] = 'l'
  t.align['Location'] = 'l'
  csv_writer.writerow(["Serial No.", "CAS No.", "Prefix", "Name", "Haz. sub.", "DG Class", "DG Subclass", "Schedule", "Packing group", "UN No.", "Size", "Size Unit", "Location"])
  for row in inventory:
    csv_writer.writerow([
    row['serial_number'],
    row['chemical']['cas'],
    row['chemical']['prefix'],
    row['chemical']['name'],
    row['chemical']['haz_substance'],
    row['chemical'].get('dg_class', {}).get('number', ''),
    row['chemical'].get('dg_class_2', {}).get('number', ''),
    row['chemical'].get('schedule', {}).get('number', ''),
    row['chemical'].get('packing_group', {}).get('name', ''),
    row['chemical']['un_number'],
    str(row['container_size']),
    str(row['size_unit']),
    ' '.join([str(row['container_location'][-1].get('location', {}).get('parent', {}).get('name', '')), str(row['container_location'][-1].get('location', {}).get('name', ''))])
    ])

    t.add_row([
    row['serial_number'],
    row['chemical']['cas'],
    row['chemical']['prefix'] + row['chemical']['name'][0:45],
    row['chemical'].get('dg_class', {}).get('number', ''),
    row['chemical'].get('dg_class_2', {}).get('number', ''),
    row['chemical'].get('schedule', {}).get('number', ''),
    row['chemical'].get('packing_group', {}).get('name', ''),
    row['chemical']['un_number'],
    #"blep",
    '{:~}'.format(ureg(str(row['container_size']) + ' ' + str(row['size_unit'])).to_compact()),
    ' '.join([str(row['container_location'][-1].get('location', {}).get('parent', {}).get('name', '')), str(row['container_location'][-1].get('location', {}).get('name', ''))])

    ])

print(t)
print("Exported to csv file.")


