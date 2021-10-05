#!/usr/local/bin/python3.9
import textract, re, sys

text = textract.process(sys.argv[1], encoding = 'utf_8', method = 'pdfminer').decode('utf_8')

with open(sys.argv[1]+'.txt', 'w') as f:
    f.write(text)

if re.search(r"Sigma|Aldrich|Merck", text) :

    name = re.findall(r"Product name.*?\:.*?Product Number", text, re.DOTALL)[0].split('\n')
    name = [i.strip().strip(':').strip() for i in name if not re.search(r"Product name|Product Number" , i) and re.search(r"\w", i)][0]

    cas = re.findall(r"CAS\-No.*?\d+\-\d+\-\d", text, re.DOTALL)[0].split()[-1]

    #print(cas)
    try:
        signalword = re.findall(r"2.2  Label elements.*?Warning|2.2  Label elements.*?Danger", text, re.DOTALL)[0].split()[-1]
    except:
        signalword = ''

    #print(signalword)

    hpstat = re.findall(r"2.2  Label elements.*?2.3  Other hazards", text, re.DOTALL)[0].split('\n')

    hstat = list(set([i.strip() for i in hpstat if re.search(r"H\d\d\d", i)]))

    pstat = list(set([i.strip() for i in hpstat if re.search(r"P\d\d\d", i)]))

    #print(hstat)
    #print(pstat)

    hclass = re.findall(r"2.1  Classification of the substance or mixture.*?2.2  Label elements ", text, re.DOTALL)[0].split('\n')

    hclass = [i.strip().split(', ') for i in hclass if re.search(r"H\d\d\d", i)]

    un_number = re.findall(r"14.1  UN number.*?\s\d\d\d\d\s.*?14.2  UN proper shipping name|14.1  UN number.*?-", text, re.DOTALL)[0].split()[-1]

    un_proper_shipping_name = re.findall(r"14.2  UN proper shipping name.*?ADR/RID:.*?\n", text, re.DOTALL)[0].split('\n')[-2].strip('ADR/RID:').strip()

    dg_class = re.findall(r"14.3  Transport hazard class\(es\).*?ADR/RID:.*?\n", text, re.DOTALL)[0].split('\n')[-2].strip('ADR/RID:').strip()

    packing_group = re.findall(r"14.4  Packaging group.*?ADR/RID:.*?\n", text, re.DOTALL)[0].split('\n')[-2].strip('ADR/RID:').strip()

    un_number, un_proper_shipping_name, dg_class, packing_group = [i.replace('-', '').replace('Not dangerous goods', '') for i in [un_number, un_proper_shipping_name, dg_class, packing_group]]

    print({
        'name': name,
        'cas': cas,
        'un_proper_shipping_name': un_proper_shipping_name,
        'un_number': un_number,
        'dg_class': dg_class,
        'packing_group': packing_group,
        'signalword': signalword,
        'hstat': hstat,
        'pstat': pstat,
        'hclass': hclass
        })

else :
    print('toot')