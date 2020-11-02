#!/usr/bin/env python
# @Time    : 2018/10/20
# @Author  : Aubrey
# @File    : PythonConnectMongodb.py
# @Version : 3.7.1
# @Software: PyCharm Community Edition
# @Blog    : https://github.com/AubreyYoung/blog

import pymongo

connection = pymongo.MongoClient('127.0.0.1',27017)
tdb = connection.alpha87
post = tdb.test
post.insert({'name':"李白", "age":"30", "skill":"Python"})
print("操作完成")