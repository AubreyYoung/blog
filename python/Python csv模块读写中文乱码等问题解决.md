# Python csv模块读写中文乱码等问题解决

玩蛇网[python教程](http://www.iplaypy.com/)学习今天来给大家介绍标准库中，读取解析CSV文件的一个模块，叫做**csv模块**。

![python csv模块](http://www.iplaypy.com/uploads/allimg/160303/2-160303150I2C1.jpg)

[TOC]

## 一、csv模块简介

csv模块是[Python](http://www.iplaypy.com/)内置的模块，不需要另外安装，使用的时候直接 import csv #导入模块，就可以了。

## 二、csv模块主要函数

1. reader()读取csv文件数据的函数方法；
2. writer()写入csv文件数据的函数方法；

以上2个方法是csv模块最为常用的方法，使用起来也非常简便。

## 三、csv模块案例演示

```
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
```

## 四、csv模块问题总结

csv模块是Python用来读取写入操作csv数据文件的的专用模块，大家可以用dir()方法查看该模块的更多功能和方法。