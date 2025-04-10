#!~/bin/python3
#coding:utf-8

import re,os,sys
file1 = open(sys.argv[1],'r')
file2 = open(sys.argv[2],'w')

for eachline in file1:
	eachline = eachline.strip()
	list1 = eachline.split()
	if not eachline or '#' in eachline:
		continue
	else:
		ID = int(list1[0].replace('TS-RS1_ch',''))
		POS = list1[0] + "_" + list1[1]
		file2.write('{0} {1} {2} {3} {4}'.format(ID,POS,list1[1],list1[3],list1[4]))
		for i in range(9,len(list1)):
			if list1[i] == '.':
				file2.write(' 0 0 0')
			else:
				Sample = re.split('/|:',list1[i])
				if Sample[0] == '.' and Sample[1] == '.':
					file2.write(' 0 0 0')
				elif Sample[0] == Sample[1] and Sample[0] == '0' and Sample[1] == '0':
					file2.write(' 1 0 0')
				elif Sample[0] == Sample[1] and Sample[0] != '\.' and Sample[1] != '\.' and Sample[0] != '0' and Sample[1] != '0':
					file2.write(' 0 0 1') 
				elif Sample[0] != Sample[1]:
					file2.write(' 0 1 0')
		file2.write('\n')
