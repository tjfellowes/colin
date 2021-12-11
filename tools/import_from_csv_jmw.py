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
#
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
    if row[9] :
      location = " / ".join([row[9], row[10]])
    else:
      location = row[10]
    haz_substance = row[11]
    un_number = row[12]
    dg_class_1 = row[13]
    dg_class_2 = row[14]
    dg_class_3 = row[15]
    packing_group = row[16]
    schedule = row[17]
    supplier = row[18]

    if location[0] == 'Fridge':
      storage_temperature = '2~8'
    elif location[0] == 'Freezer':
      storage_temperature = '-20'
    else :
      storage_temperature = '20'

    
    product_number = ''
    lot_number = ''
    haz_class = ''
    pictogram = ''
    signal_word = ''
    haz_stat = ''
    prec_stat = ''
    
    un_proper_shipping_name = ''
    
    owner_id = '1'

    payload = {'path': location}
    response = session.post(url + '/api/location',headers=headers,data=payload)
    if response.status_code == 422:
      print(response.content)
      print(payload)
    elif response.status_code == 200:
      #print(name)
      pass
    else:
      print(str(response.status_code) + str(response.content))


    payload = {'barcode': barcode, 'cas': cas, 'prefix': prefix, 'name': name, 'description': description, 'container_size': container_size, 'size_unit': size_unit, 'location': location,   'supplier': supplier, 'product_number': product_number, 'dg_class': dg_class_1, 'dg_class_2': dg_class_2, 'dg_class_3': dg_class_3, 'lot_number': lot_number, 'haz_stat': haz_stat, 'prec_stat': prec_stat, 'un_number': un_number, 'packing_group': packing_group, 'schedule': schedule, 'storage_temperature': storage_temperature, 'un_proper_shipping_name': un_proper_shipping_name, 'owner_id': owner_id}
    response = session.post(url + '/api/container',headers=headers,data=payload)

    if response.status_code == 422:
      print(response.content)
      print(payload)
    elif response.status_code == 200:
      #print(name)
      pass
    else:
      print(str(response.status_code) + str(response.content))

    print(payload)

    if date_disposed:
      response = session.post(url + '/api/container/delete/barcode/' + barcode,headers=headers)


