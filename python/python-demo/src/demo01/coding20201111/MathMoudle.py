# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: MathMoudle
@ProjectName: python-demo
@Date: 2020/11/11 10:21
-------------------------------------------------
"""

import math
import time
import datetime
from datetime import timedelta

a = math.cos(math.pi / 2)
print(a)

print(math.pi)

import random

print(random.randint(1, 100))
print(random.choice(['aa', 'bb', 'cc', 'dd']))

print(time.time())
print(time.localtime())
print(time.strftime('%Y%m%d %H:%M:%S'))

print(datetime.datetime.now())

newtime: timedelta = datetime.timedelta(minutes=30)

print(datetime.datetime.now()+newtime)


