import csv
from os import name

import requests
import json
import urllib

from requests import status_codes

#url = 'https://colin-uol.herokuapp.com'
url = 'http://localhost:9292'


headers = {'User-Agent': 'Mozilla/5.0'}
payload = {'username':'root','password':'root'}

session = requests.Session()
session.post(url + '/user/login',headers=headers,data=payload)

haz_classes_dict = {(str(i.get('superclass',{}).get('description','')) + ' (' + i['description'] + ')'):i['id'] for i in session.get(url + '/api/haz_class',headers=headers,data=payload).json()}

haz_classes_dict['No data available'] = ''
haz_classes_dict['Not hazardous'] = ''
haz_classes_dict[''] = ''

with open('haz_classes_dictionary.json', 'r') as f:
  haz_classes_dict.update(json.load(f))

locations_dict = {i['location_path']:i['id'] for i in session.get(url + '/api/location',headers=headers,data=payload).json()}

pictograms_dict = {i['code']:i['id'] for i in session.get(url + '/api/pictogram',headers=headers,data=payload).json()}

temperature_dict = {'ROOM': 25, 'FRIDGE': 4, 'FREEZER': -20, '': 25}


with open('Chemicals_all_19_02_2022.csv') as csv_file:
  csv_reader = csv.DictReader(csv_file, dialect='excel', delimiter=',')
  for row in csv_reader:
    try:
      haz_class_ids = [haz_classes_dict[i] for i in row['Hazard Classification'].split(';')]
    except KeyError as e:
      print("Hazard class not found: " + e.args[0])
      print("Please manually enter the hazard classification ID:")
      id = input()
      haz_classes_dict[e.args[0]] = int(id)
      with open('haz_classes_dictionary.json', 'w') as outfile:
        json.dump(haz_classes_dict, outfile, indent=4)

    if True:
      payload = { 
      'location_id' : locations_dict[row['Location path'].replace(' > ','/')], 
      'supplier' : row['Brand'],
      'container_size' : row['Net Quantity'],
      'size_unit' : row['Quantity unit'],
      'cas' : row['CAS'],
      'barcode' : row['Barcode'],
      'product_number' : row['Product number'],
      'owner_id' : 1,
      'cas' : row['CAS'],
      'name' : row['Product name'],
      'dg_class_1' : row['Transport hazard class 1'],
      'dg_class_2' : row['Transport hazard class 2'],
      'dg_class_3' : row['Transport hazard class 3'],
      'packing_group' : row['Packaging group'],
      'un_number' : row['UN number'],
      'storage_temperature' : temperature_dict[row['Storage temperature']],
      'inchi': row['InChI'],
      'signal_word': row['Hazard Signal Word'],
      'haz_stats[]': [i for i in row['Hazard code(s)'].replace(' ','').split(';') if i],
      'prec_stats[]': [i for i in row['Precautionary statement(s)'].replace(' ','').split(';') if i],
      'pictogram_ids[]': [pictograms_dict[i] for i in row['Hazard Label(s)'].replace('_','').split(';') if i],
      'haz_class_ids[]': [haz_classes_dict[i] for i in row['Hazard Classification'].split(';') if haz_classes_dict[i]]
      }
      #print(payload['barcode'])

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



