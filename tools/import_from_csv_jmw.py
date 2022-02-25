import csv
from os import name

import requests
import json
import urllib

from requests import status_codes

url = 'http://localhost:9292'
#url = 'https://colin-uom.herokuapp.com'

headers = {'User-Agent': 'Mozilla/5.0'}
payload = {'username':'root','password':'root'}

session = requests.Session()
session.post(url + '/user/login',headers=headers,data=payload)

locations = {i['location_path'].replace('/', ' ').casefold():i['id'] for i in session.get(url + '/api/location',headers=headers).json()}

with open('data-1639228931488.csv') as csv_file:
  csv_reader = csv.reader(csv_file, dialect='unix', delimiter=',')
  next(csv_reader, None)
  for row in csv_reader:
    barcode = row[0]
    cas = row[1]
    prefix = row[2]
    name = row[3]
    description = row[4]
    container_size = row[5]
    size_unit = row[6]
    date_purchased = row[7]
    date_disposed = row[8]
    haz_substance = row[11]
    un_number = row[12]
    dg_class_1 = row[13]
    dg_class_2 = row[14]
    dg_class_3 = row[15]
    packing_group = row[16]
    schedule = row[17]
    supplier = row[18]
    storage_temperature = 20
    product_number = ''
    lot_number = ''
    haz_class = ''
    pictogram = ''
    signal_word = ''
    haz_stat = ''
    prec_stat = ''
    un_proper_shipping_name = ''    
    owner_id = '1'

    if row[10].strip().casefold() =='missing':
      location_id = 1
    else:
      location_id = locations[' '.join([row[9].strip().casefold(), row[10].strip().casefold()]).strip()]

    payload = {'barcode': barcode, 'cas': cas, 'prefix': prefix, 'name': name, 'description': description, 'container_size': container_size, 'size_unit': size_unit, 'location_id': location_id,   'supplier': supplier, 'product_number': product_number, 'dg_class_1': dg_class_1, 'dg_class_2': dg_class_2, 'dg_class_3': dg_class_3, 'lot_number': lot_number, 'haz_stat': haz_stat, 'prec_stat': prec_stat, 'un_number': un_number, 'packing_group': packing_group, 'schedule': schedule, 'storage_temperature': storage_temperature, 'un_proper_shipping_name': un_proper_shipping_name, 'owner_id': owner_id} 

    if True:
      response = session.post(url + '/api/container',headers=headers,data=payload)

      if response.status_code == 422:
        print(response.content)
      elif response.status_code == 200:
        #print(name)
        pass
      else:
        print(str(response.status_code) + str(response.content))

    if False:
      response = session.put(url + '/api/container/barcode/' + row['Barcode'],headers=headers,data=payload)

      if response.status_code == 422:
        print(response.content)
      elif response.status_code == 200:
        #print(name)
        pass
      else:
        print(str(response.status_code) + str(response.content))

    if False:
      response = session.put(url + '/api/chemical/cas/' + row['CAS'],headers=headers,data=payload)

      if response.status_code == 422:
        print(response.content)
      elif response.status_code == 200:
        #print(name)
        pass
      else:
        print(str(response.status_code) + str(response.content))

    if date_disposed:
      response = session.post(url + '/api/container/delete/barcode/' + barcode,headers=headers)