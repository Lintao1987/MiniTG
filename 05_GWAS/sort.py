#!~/bin/python3
#coding:utf-8
import re,os,sys

file1 = open(sys.argv[1],'r')
file2 = open(sys.argv[2],'r')
file3 = open(sys.argv[3],'w')

dict1 = {}
for eachline in file1:
	eachline = eachline.strip()
	list1 = eachline.split()
	if 'RS' in eachline:
		dict1[list1[0]] = eachline

for eachline in file2:
	eachline = eachline.strip()
	list2 = eachline.split()
	if not eachline or '#' in eachline or 'RS' not in eachline:
		continue
	if list2[0] in dict1.keys():
		file3.write('{0}\n'.format(dict1[list2[0]]))
	else:
		file3.write('{0} {1} {2} {3} {4} {5}\n'.format(list2[0],list2[0],"0","0","0","-9"))

