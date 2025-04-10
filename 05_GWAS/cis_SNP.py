#!~/bin/python3
#coding:utf-8

#include the required module
import sys
import re
import os
import argparse

#command-line interface setting
parser = argparse.ArgumentParser(description = 'Generating parameters lines to New file')
parser.add_argument('-i1', type = argparse.FileType('r'), help = 'input of SNP pos')
parser.add_argument('-i2', type = argparse.FileType('r'), help = 'input of cis SNP')
parser.add_argument('-i3', type = argparse.FileType('r'), help = 'input of .gen')
parser.add_argument('-g', type = str , help = 'gene id')
parser.add_argument('-o', type = argparse.FileType('w'), help = 'output of new file')

args = parser.parse_args()

dict1 = {}
for eachline in args.i1:
	eachline = eachline.strip()
	list1 = eachline.split()
	if not eachline or 'snpid' in eachline:
		continue
	else:
		dict1[list1[0]] = list1[1]+"_"+list1[2]
dict2 = {}
for eachline in args.i2:
	eachline = eachline.strip()
	eachline = eachline.replace("\"","")
	list2 = eachline.split()
	if not eachline or 'snps' in eachline:
		continue
	if list2[2] == args.g:
		dict2[dict1[list2[1]]] = list2[2]

for eachline in args.i3:
	eachline = eachline.strip()
	list3 = eachline.split()
	if not eachline or '#' in eachline:
		continue
	if list3[1] in dict2.keys():
		args.o.write('{0}\n'.format(eachline))



