# -*- coding: utf-8 -*-
"""
-------------------------------------------------
@version: 0.1
@Author: yangguang02
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: test
@ProjectName: PythonCoding
@Date: 2020/8/12 16:02
-------------------------------------------------
"""
# SET 交集、并集、差集及对称差集
a = {1,2,3}
b = {3,4,5}

c = list(set(a) & set(b))
print(c)

d = list(set(a) | set(b))
print(d)

e = list(set(a) - set(b))
print(e)

f = list(set(b) - set(a))
print(f)

g = list(set(b) ^ set(a))
print(g)


print(list(set(a).intersection(set(b))))
# 使用 intersection 求a与b的交集
print(list(set(b).difference(set(a))))
# 使用 difference 求a与b的差(补)集：求b中有而a中没有的元素
print(list(set(a).union(b)))
# 使用 union 求a与b的并集
print(list(set(a).difference(set(b))))
# 使用 difference 求a与b的差(补)集：求a中有而b中没有的元素
print(list(set(a).symmetric_difference(b)))
# 使用 symmetric_difference 求a与b的对称差集

import os

print(os.curdir)

 #read txt method t
f = open("./plan.txt")
for line in open("./plan.txt",encoding='utf-8',errors='ignore'):
    print(line)