import csv
import pint
import requests
import json
import urllib
from prettytable import PrettyTable

from pint import UnitRegistry
ureg = UnitRegistry()

pg = {
  "I": "1",
  "II": "2",
  "III": "3",
  "-": "",
  "": ""
}

schedule = {
  "1": "",
  "2": "2",
  "3": "3",
  "4": "3",
  "7": "7",
  "-": "",
  "": ""
}

dg = {
  "2.1": "9",
  "3": "12",
  "4.1": "14",
  "4.2": "15",
  "4.3": "16",
  "5.1": "18",
  "5.2": "19",
  "6": "20",
  "6.1": "21",
  "8": "24",
  "9": "25",
  "-": "",
  "": "",
  "3, 6.1": "12",
  "3,8": "12",
  "3, 8": "12",
  "6.1, 8": "21",
  "6.1,8": "21"
}

loc = {
  "Harmful": "1",
  "Harmful H1": "2",
  "Harmful H2": "3",
  "Harmful H3": "4",
  "Harmful H4": "5",
  "Harmful H5": "6",
  "Harmful H6": "7",
  "Harmful H7": "8",
  "Harmful H8": "9",
  "Harmful H9": "10",
  "Harmful H10": "11",
  "Harmful H11": "12",
  "Harmful H12": "13",
  "Harmful H13": "14",
  "Harmful H14": "15",
  "Harmful H15": "16",
  "Harmful H16": "17",
  "Harmful H17": "18",
  "Harmful H18": "19",
  "Harmful H19": "20",
  "Harmful H20": "21",
  "Harmful H21": "22",
  "Harmful H22": "23",
  "Harmful H23": "24",
  "Harmful H24": "25",
  "Harmful H25": "26",
  "Harmful H26": "27",
  "Harmful H27": "28",
  "Harmful Desc": "29",
  "Harmful Dessicator": "29",
  "Toxic": "30",
  "Toxic TS1": "31",
  "Toxic TS2": "32",
  "Toxic TS3": "33",
  "Toxic TM1": "34",
  "Toxic TM2": "35",
  "Toxic TM3": "36",
  "Toxic TM4": "37",
  "Toxic TM5": "38",
  "Toxic TM6": "39",
  "Toxic TL1": "40",
  "Toxic TL2": "41",
  "Toxics TL2": "41",
  "Toxic TL3": "42",
  "Toxic TL4": "43",
  "Toxic TXL": "44",
  "Toxic dessicator": "45",
  "Toxic Dessicator": "45",
  "Corrosive": "46",
  "Corrosive 1": "47",
  "Corrosive Acid 1": "47",
  "Corrosive 2": "48",
  "Corrosive Acid 2": "48",
  "Corrosive Basic 1": "49",
  "Corrosive Basic 2": "50",
  "Corrosive Basic 3": "51",
  "Corrosive Basic 4": "52",
  "Corrosive Base 1": "49",
  "Corrosive Base 2": "50",
  "Corrosive Base 3": "51",
  "Corrosive Base 4": "52",
  "Corrosive basic 1": "49",
  "Corrosive basic 2": "50",
  "Corrosive basic 3": "51",
  "Corrosive basic 4": "52",
  "Corrosive Desc": "53",
  "Corrosive Dessicator": "53",
  "Fridge": "54",
  "Fridge Bottom draw": "55",
  "Fridge (bottom)": "55",
  "Fridge door": "56",
  "Fridge Door": "56",
  "Fridge 3 Door": "56",
  "Fridge S1": "57",
  "Fridge S1 B1": "58",
  "Fridge S1 B3": "59",
  "Fridge S2 B1": "60",
  "Fridge S2 B2": "61",
  "Fridge S3": "62",
  "Fridge S3 B1": "63",
  "Fridge S4": "64",
  "Fridge S4 B1": "65",
  "Freezer": "66",
  " Freezer": "66",
  "Freezer 1 S1": "67",
  "Freezer 1 S1 B1": "68",
  "Freezer 1 S1B1": "68",
  "Oxidant Freezer": "68",
  "Freezer 1 S2 B1": "69",
  "Freezer 1 S2 B2": "70",
  "Freezer 1 S2 B3": "71",
  "Freezer 1 S3 B1": "72",
  "Freezer 1 S4 B1": "73",
  "Freezer 1 S4 B2": "74",
  "Freezer 1 S5 B1": "75",
  "Freezer 2 (Corrosive)": "76",
  "Freezer 2": "76",
  "Middle freezer": "76",
  "Freezer 3 (Flammable)": "77",
  "Freezer 3": "77",
  "Flammable liquid": "78",
  "Flammable liquids L": "79",
  "Flammable liquid Large": "79",
  "Flammable liquid Small": "80",
  "Flammable liquids S": "80",
  "Flammable Liquids L": "79",
  "Flammable Liquids S": "80",
  "Flammable Solids": "81",
  " Flammable solid": "81",
  "Flammable Solids Desc 1": "82",
  "Flammable Solids Desc 2": "83",
  "Flammable solid Dessicator 1": "82",
  "Flammable solid Dessicator 2": "83",
  "Posions": "84",
  "Poison Draw No. 1": "85",
  "Poisons draw No.1": "85",
  "Poisons draw No.2": "86",
  "Poisons draw No.3": "87",
  "Poisons draw no.3": "87",
  "Posions Draw 1": "85",
  "Posions Draw 2": "86",
  "Posions Draw 3": "87",
  "Poisons Draw 1": "85",
  "Poisons Draw 2": "86",
  "Poisons Draw 3": "87",
  "Poisons draw 1": "85",
  "Poisons draw 2": "86",
  "Poisons draw 3": "87",
  "Benches": "88",
  "Bench 1": "89",
  "Bench 2": "90",
  "Bench 3": "91",
  "Bench 4": "92",
  "Bench 5": "93",
  "Bench 6": "94",
  "Bench 7": "95",
  "Bench 8": "96",
  "Bench 9": "97",
  "Bench 10": "98",
  "Bench 11": "99",
  "Bench 12": "100",
  "Bench 13": "101",
  "Bench 14": "102",
  "Benches 1": "89",
  "Benches 2": "90",
  "Benches 3": "91",
  "Benches 4": "92",
  "Benches 5": "93",
  "Benches 6": "94",
  "Benches 7": "95",
  "Benches 8": "96",
  "Benches 9": "97",
  "Benches 10": "98",
  "Benches 11": "99",
  "Benches 12": "100",
  "Benches 13": "101",
  "Benches 14": "102",
  "Bench 14 desc": "102",
  "Dangerous When Wet": "103",
  " Dangerous when wet": "103",
  "Oxidizing agents": "104",
  " Oxidants": "104",
  "Non-hazardous": "105",
  " Non-hazardous": "105",
  "Under Sinks": "105",
  "various": "105",
  "Non-Flammable Solvents": "109",
  " Non-flammable solvents": "109",
  "Chromatog/filtration aids": "106",
  " Chromatography/filtration aids": "106",
  "Deuterates desc": "107",
  " Deuterates dessicator": "107",
  "Sieves/drying agents": "108",
  " Sieves/drying agents": "108",
  " ": ""
}

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
      else: haz_substance='true'

      dg_class_id=str(dg[row[5]])
      dg_class_2_id=str(dg[row[6]])
      dg_class_3_id=str('')
      schedule_id=str(schedule[row[7]])
      pg_id=str(pg[row[8]])

      un_number=str(row[9])

      container_size = str(row[10])
      size_unit = str(row[11])

      location_id=str(loc[row[12]])

      supplier_id=str(0)


      #create container matching the chemical
      url = "http://localhost:9292/api/container/create?cas=" + cas + "&prefix=" + prefix + "&name=" + name + "&dg_class_id=" + dg_class_id + "&dg_class_2_id=" + dg_class_2_id + "dg_class_3_id=" + dg_class_3_id + "&schedule_id=" + schedule_id +  "&packing_group_id=" + pg_id +  "&un_number=" + un_number + "&haz_substance=" + haz_substance + "&serial_number=" + serial_number + "&container_size=" + container_size + "&size_unit=" + size_unit + "&supplier_id=" + supplier_id + "&location_id=" + location_id
      if cas:
        requests.get(url).status_code

        t.add_row([serial_number, cas, prefix, name, dg_class_id, dg_class_2_id, dg_class_3_id, schedule_id, container_size, size_unit, pg_id, un_number, haz_substance, location_id])

    line_count += 1

  print(t)

