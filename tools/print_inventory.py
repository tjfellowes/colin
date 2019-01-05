import pint
import requests
import json
import urllib
from prettytable import PrettyTable
from pint import UnitRegistry

ureg = UnitRegistry()
ureg.define('None = 0')


inventory = requests.get('http://localhost:9292/api/container/all').json()

t = PrettyTable()
t.field_names = ["Serial No.", "CAS No.", "Name", "DG Class", "Schedule", "Packing Group", "UN No.", "Size", "Location"]
t.align['Name'] = 'l'
t.align['Location'] = 'l'
for row in inventory:
  t.add_row([
  row['serial_number'],
  row['chemical']['cas'],
  row['chemical']['prefix'] + row['chemical']['name'][0:45],
  row['chemical'].get('dg_class', {}).get('number', ''),
  row['chemical'].get('schedule', {}).get('number', ''),
  row['chemical'].get('packing_group', {}).get('name', ''),
  row['chemical']['un_number'],
  '{:~}'.format(ureg(str(row['container_size']) + ' ' + str(row['size_unit'])).to_compact()),
  str(row['storage_location']['location'].get('parent', {}).get('name', '')) + ' ' + str(row['storage_location']['location']['name'])
  ])

print t


