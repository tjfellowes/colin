#!/usr/bin/python3

from sdsparser import SDSParser

sdsFile = 'w322318.pdf'

request_keys = ['manufacturer', 'flash_point', 'specific_gravity', 'product_name', 'sara_311', 'nfpa_fire']

parser = SDSParser()

print(parser.get_sds_data(sdsFile))
    
