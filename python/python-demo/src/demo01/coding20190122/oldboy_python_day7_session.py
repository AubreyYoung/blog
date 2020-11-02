#!/usr/bin/env python
#_*_ coding:utf-8 _*_


"""
-------------------------------------------------
@version: 0.1
@Author:AubreyYoung
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: oldboy_python_day7_session.py
@Date:2019/1/22 14:44
-------------------------------------------------
"""


# 集合,可变数据类型,它里面的元素必须是不可变数据类型,无序,不重复

# 列表去重,先转化为set,再重新转化为list

set1 = set({1,2,3})
set2 = {1,2,3,[4,5],{'name':'oracle'}}  # 报错
print(set1)
print(set2)

# 增
set1 = {'alex','wusir','ritian','egon','barry'}
set1.add('女神')
print(set1)

set1 = {'alex','wusir','ritian','egon','barry'}
set1.add('barry')
print(set1)

# update：迭代着增加
set1 = {'alex','wusir','ritian','egon','barry'}
set1.update('A')
print(set1)
set1.update('老师')
print(set1)
set1.update([1,2,3])
print(set1)

# 删除
# pop随机删除
set1 = {'alex','wusir','ritian','egon','barry'}
set1.pop()
print(set1.pop())
print(set1)

# remove 按元素删除
set1 = {'alex','wusir','ritian','egon','barry'}
set1.remove('barry')
set1.remove('oracle')

# clear清空
set1 = {'alex','wusir','ritian','egon','barry'}
set1.clear()
print(set1)

# del
set1 = {'alex','wusir','ritian','egon','barry'}
# del set1('alex')  # 报错
del set1
print(set1)

# 查
set1 = {'alex','wusir','ritian','egon','barry'}

for i in set1:
    print(i)

# 集合的逻辑运算

# 交集。（& 或者 intersection）
set1 = {1,2,3,4,5}
set2 = {4,5,6,7,8}
print(set1 & set2)  # {4, 5}
print(set1.intersection(set2))  # {4, 5}

# 并集。（| 或者 union）
set1 = {1,2,3,4,5}
set2 = {4,5,6,7,8}
print(set1 | set2)  # {1, 2, 3, 4, 5, 6, 7,8}
print(set2.union(set1))  # {1, 2, 3, 4, 5, 6, 7,8}

# 差集。（- 或者 difference）
set1 = {1,2,3,4,5}
set2 = {4,5,6,7,8}
print(set1 - set2)  # {1, 2, 3}
print(set1.difference(set2))  # {1, 2, 3}

# 反交集 （^ 或者 symmetric_difference）
set1 = {1,2,3,4,5}
set2 = {4,5,6,7,8}
print(set1 ^ set2)  # {1, 2, 3, 6, 7, 8}
print(set1.symmetric_difference(set2))  # {1, 2, 3, 6, 7, 8}

# 子集与超集
set1 = {1,2,3}
set2 = {1,2,3,4,5,6}
print(set1 < set2)
print(set1.issubset(set2))  # 这两个相同，都是说明set1是set2子集。
print(set2 > set1)
print(set2.issuperset(set1))  # 这两个相同，都是说明set2是set1超集

# frozenset不可变集合，让集合变成不可变类型。

s = frozenset('barry')
print(s,type(s))  # frozenset({'a', 'y', 'b', 'r'}) <class 'frozenset'>

for i in s:
    print(i)

# 去重
li1 = [1,1,2,3,3,44,55,44,33,2]
set1 = set(li1)
print(set1)
li2 = list(set1)
print(li2)