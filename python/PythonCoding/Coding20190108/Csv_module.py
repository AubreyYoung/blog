#!python3
# -*- coding: UTF-8 -*-
import csv
with open('stocks.csv',encoding='utf-8') as f:
    reader = csv.reader(f)
    print(list(reader))



with open('stocks.csv',encoding='utf-8') as f:
    reader = csv.reader(f)
    for row in reader:
        # 行号从1开始
        print(reader.line_num,row)