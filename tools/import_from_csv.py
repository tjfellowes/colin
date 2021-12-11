import csv
from os import name

import requests
import json
import urllib

from requests import status_codes

url = 'http://192.168.1.148:9292'

headers = {'User-Agent': 'Mozilla/5.0'}
payload = {'username':'root','password':'root'}

session = requests.Session()
session.post(url + '/login',headers=headers,data=payload)

with open('AIC_inventory.csv') as csv_file:
  csv_reader = csv.reader(csv_file, dialect='excel', delimiter=',')
  for row in csv_reader:
    supplier = row[2]
    prefix = ''
    name = row[17]
    product_number = row[25]
    cas = row[4]
    haz_substance = 'true'
    haz_class = row[9]
    pictogram = row[12]
    signal_word = row[35]
    haz_stat = row[11].replace(" ", "")
    prec_stat = row[24].replace(" ", "")
    storage_temperature = '20'
    un_number = row[44]
    un_proper_shipping_name = ''
    dg_class = row[41]
    dg_class_2 = row[42]
    dg_class_3 = row[43]
    packing_group = row[22]
    schedule = ''
    barcode = row[1]
    location = row[15]
    container_size = row[29]
    size_unit = row[30]
    lot_number = row[16]
    owner_id = '1'

    location = location.replace(' > ', '/')

    payload = {'path':location}
    response = session.post(url + '/api/location',headers=headers,data=payload)

    payload = {'cas': cas, 'name': name, 'location': location, 'barcode': barcode, 'container_size': container_size, 'size_unit': size_unit, 'supplier': supplier, 'product_number': product_number, 'dg_class': dg_class, 'dg_class_2': dg_class_2, 'dg_class_3': dg_class_3, 'lot_number': lot_number, 'haz_stat': haz_stat, 'prec_stat': prec_stat, 'un_number': un_number, 'packing_group': packing_group, 'schedule': schedule, 'storage_temperature': storage_temperature, 'un_proper_shipping_name': un_proper_shipping_name, 'owner_id': owner_id}
    response = session.post(url + '/api/container',headers=headers,data=payload)

    if response.status_code == 422:
      print(response.content)
    elif response.status_code == 200:
      #print(name)
      pass
    else:
      print(str(response.status_code) + str(response.content))


