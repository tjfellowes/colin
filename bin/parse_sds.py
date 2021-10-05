#!/usr/local/bin/python3.9
import textract, re

text = textract.process('aniline.pdf', encoding = 'utf_8', method = 'pdfminer').decode('utf_8')

#with open('text.txt', 'w') as f:
#    f.write(text)

name = re.findall(r"Product name.*?\:.*?Product Number", text, re.DOTALL)[0].split('\n')
name = [i.strip().strip(':').strip() for i in name if not re.search(r"Product name|Product Number" , i) and re.search(r"\w", i)][0]

cas = re.findall(r"CAS\-No.*?\d+\-\d+\-\d", text, re.DOTALL)[0].split()[-1]

#print(cas)

signalword = re.findall(r"Signal word.*?Warning|Signal word.*?Danger", text, re.DOTALL)[0].split()[-1]

#print(signalword)

hpstat = re.findall(r"2.2  Label elements.*?Reduced Labeling", text, re.DOTALL)[0].split('\n')

hstat = [i.strip() for i in hpstat if re.search(r"H\d\d\d", i)]

pstat = [i.strip() for i in hpstat if re.search(r"P\d\d\d", i)]

#print(hstat)
#print(pstat)

hclass = re.findall(r"2.1  Classification of the substance or mixture.*?2.2  Label elements ", text, re.DOTALL)[0].split('\n')

hclass = [i.strip().split(', ') for i in hclass if re.search(r"H\d\d\d", i)]

un_number = re.findall(r"14.1  UN number.*?\d\d\d\d", text, re.DOTALL)[0].split()[-1]

un_proper_shipping_name = re.findall(r"14.2  UN proper shipping name.*?ADR/RID:.*?\n", text, re.DOTALL)[0].split('\n')[-2].strip('ADR/RID:').strip()

dg_class = re.findall(r"14.3  Transport hazard class\(es\).*?ADR/RID:.*?\n", text, re.DOTALL)[0].split('\n')[-2].strip('ADR/RID:').strip()

packing_group = re.findall(r"14.4  Packaging group.*?ADR/RID:.*?\n", text, re.DOTALL)[0].split('\n')[-2].strip('ADR/RID:').strip()

print([name,cas,un_proper_shipping_name,un_number,dg_class,packing_group,signalword,hstat,pstat,hclass])