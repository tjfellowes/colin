from os import name

import requests
import json
import urllib

from requests import status_codes

#url = 'http://localhost:9292'
url = 'https://colin-uom-dev.herokuapp.com'

headers = {'User-Agent': 'Mozilla/5.0'}
payload = {'username':'root','password':'root'}

session = requests.Session()
session.post(url + '/user/login',headers=headers,data=payload)

loctypes = {i['name']:i['id'] for i in session.get(url + '/api/locationtype',headers=headers).json()}
print(loctypes)


with open('locations') as file:
    n=1
    ancestry = list()
    for i in file:
        id = n
        level = i.rstrip().count('\t')-2
        name = i.strip().split('\t')[-1]
        location_type = i.split('\t')[0]
        temperature = i.split('\t')[1]
        ancestry.insert(level, id)
        ancestry = ancestry[:level+1]
        if len(ancestry) > 1:
            parent_id = ancestry[-2]
        else:
            parent_id = None

        payload = {'id': id, 'parent_id': parent_id, 'name': name, 'location_type_id': loctypes[location_type], 'temperature': temperature}

        print(payload)

        response = session.post(url + '/api/location',headers=headers,data=payload)

        n=n+1

response = session.get(url + '/api/location',headers=headers,data=payload)