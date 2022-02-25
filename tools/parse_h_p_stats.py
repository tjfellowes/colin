import sys

with open('p_stats.txt', 'r') as file:
    lines = file.readlines()
    for line in lines:
        if line != '\n':
            data = line.replace('\n','').split('\t')
            print("PrecStat.create!(code: '" + data[0] + "', description: '" + data[1] + "')")