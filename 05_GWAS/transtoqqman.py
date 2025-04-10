#!~/bin/python3
#coding=utf-8
#This script is used to transform EMMAX output file to qqman's input file

import re,sys,os

f1=open(sys.argv[1],"r")#EMMAX output file
f2=open(sys.argv[2],"w")

header="SNP\tCHR\tBP\tP"
f2.write('{0}\n'.format(header))
for eachline1 in f1:
	eachline1 = eachline1.strip()
	list1 = eachline1.split('\t')
	if not eachline1 :
		continue
	else:
		list2 = re.split('_',list1[0])
		ID = list2[1][2:]
		if int(ID)< 10:
			new = "Chr"+str(int(ID))+'_'+list2[2]
		else:
			new = "Chr"+str(int(ID))+'_'+list2[2]
		loc=list2[2]
		f2.write('{0}\t{1}\t{2}\t{3}\n'.format(new,str(int(ID)),loc,list1[-1]))
