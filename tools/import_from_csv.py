import csv
import pint
import requests
import json
import urllib

from pint import UnitRegistry
ureg = UnitRegistry()

with open('inventory.csv') as csv_file:
  csv_reader = csv.reader(csv_file, dialect='excel', delimiter=',')
  for row in csv_reader:
    requests.post(url).status_code

