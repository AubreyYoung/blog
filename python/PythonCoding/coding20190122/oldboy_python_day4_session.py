#!/usr/bin/env python
# _*_ coding:utf-8 _*_


"""
-------------------------------------------------
@version: 0.1
@Author:AubreyYoung
@license: Apache Licence 
@contact: yangguang1900@163.com
@site: https://github.com/AubreyYoung/blog
@software: PyCharm
@file: oldboy_python_day4_session.py
@Date:2019/1/22 9:43
-------------------------------------------------
"""

# dict 字典
dic = {
    'name': ['Aubrey', 'Galaxy'],
    'db': [{'oralce': '18.0.0', 'MySQL': '5.7'}],
    True: 1,
    (1, 2, 3): 'MongoDB',
    2: 'Redis'
}

print(dic)

dic1 = {'age': 18, 'name': 'Aubrey', 'sex': 'male'}

# 增

dic1['high'] = 180  # 没有键值对,则添加
print(dic1)

dic1['age'] = 29  # 如果邮件,则覆盖
print(dic1)

dic1.setdefault('weight', 130)  # 有键值对,不做任何改变,无则添加

# 删
dic1 = {'age': 18, 'name': 'Aubrey', 'sex': 'male'}
# dic1.pop('age')
# print(dic1.pop('age'))  # 有返回值,按键删除
# print(dic1.pop('MySQL',None))  # 可设置返回值

# print(dic1)

dic1.popitem()  # 随机删除
print(dic1.popitem())  # 随机删除,有返回值,元祖里面是删除的键值
print(dic1)

dic1.clear()  # 清空字典

del dic1['name']
del dic1['name1']
del dic1

# 改
dic1['age'] = 18

dic1 = {'age': 18, 'name': 'Aubrey', 'sex': 'male'}
dic2 = {'age': 20, 'weight': 120}
dic2.update(dic1)  # 有覆盖,无增加

print(dic1)
print(dic2)

# 查

dic1 = {'age': 18, 'name': 'Aubrey', 'sex': 'male'}
print(dic1.keys())
print(dic1.values())
print(dic1.items())

dic1 = {'age': 18, 'name': 'Aubrey', 'sex': 'male'}
# for i in dic1:
#      print(i)

# for i in dic1.keys():
#     print(i)

for i in dic1.values():
    print(i)

# a,b值互换
a,b = 1,2
print(a,b)
a,b = b,a
print(a,b)


a,b = [1,2]
print(a,b)

a,b = (1,2)
print(a,b)

a,b = [1,2],[3,4]
print(a,b)

dic1 = {'age': 18, 'name': 'Aubrey', 'sex': 'male'}

# for i in dic1.items():
#     print(i)

for k,v in dic1.items():
    print(k,v)

dic1 = {'age': 18, 'name': 'Aubrey', 'sex': 'male'}

print(dic1['name'])
# print(dic1['v1'])  # 报错

print(dic1.get('v1'))  # 返回None

# 字典的嵌套
dic1 = {'name': ['Aubrey', 'Galaxy', 'Glory'], 'version': {'Oracle': '18.0.3', 'MySQL': '5.7.22'},'age':100}

# dic1['age'] = 33
# dic1['name'].append('Young')
# dic1['name'][0] = 'Young'
dic1['version']['MongoDB'] = '4.0.3'
print(dic1)


info = input('>>').strip()

for i  in  info:
    if i.isalpha():
        info = info.replace(i," ")
l = info.split()
print(len(l))