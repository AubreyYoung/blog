# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: pandas_execl
@ProjectName: python-demo
@Date: 2020/11/2 13:46
-------------------------------------------------
"""

# 导入pandas包
import pandas as pd


# 读取Excel数据，选取nyse这一页
nyse = pd.read_excel('A2-MAPS- LLD-Expansion Update 2020-10-21.xlsx', sheet_name='EXPANSION PLAN', na_values='n/a')

# 显示前几行
print(nyse.head())

# 显示摘要信息
nyse.info()

# 将Excel文件读取成 ExcelFile 格式
xls = pd.ExcelFile('A2-MAPS- LLD-Expansion Update 2020-10-21.xlsx')

# 获取sheet表的名称
exchanges = xls.sheet_names
print(exchanges)

# 读取所有sheet的数据，存储在字典中
listings = pd.read_excel(xls, sheet_name=exchanges, na_values='n/a')

# 查看 nasdaq 表的摘要信息
listings['StorageLUNs'].info()

# 创建 ExcelFile 变量
xls = pd.ExcelFile('A2-MAPS- LLD-Expansion Update 2020-10-21.xlsx')

# 获取sheet名
exchanges = xls.sheet_names

# 创建空列表
listings = []

# 使用循环逐一导入每一页的数据，并存储在列表中
for exchange in exchanges:
    listing = pd.read_excel(xls, sheet_name=exchange, na_values='n/a')
    listing['Exchange'] = exchange
    listings.append(listing)

# 合并数据
listing_data = pd.concat(listings)

# 查看合并后数据的摘要
listing_data.info()


# 读取 nyse 和nasdaq 这两张表的数据
nyse = pd.read_excel('listings.xlsx', sheet_name='nyse', na_values='n/a')
nasdaq = pd.read_excel('listings.xlsx', sheet_name='nasdaq', na_values='n/a')

# 添加一列 Exchange，标记来自哪张表的数据
nyse['Exchange'] = 'NYSE'
nasdaq['Exchange'] = 'NASDAQ'

# 拼接两个DataFrame
combined_listings = pd.concat([nyse, nasdaq])  # 注意这里的[ ]
combined_listings.info()