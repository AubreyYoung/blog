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
@file: oldboy_python_day6_session.py
@Date:2019/1/22 11:32
-------------------------------------------------
"""


# Python2与Python3区别
# Python2
# print 'a' 或 print('a')
# range() xrange()
# raw_input()

# Python3
# print('a')
# range()
# input()

# = 赋值 == 比较值是否相等 is 比较,比较的是内存地址 id(内容)

li1 = [1,2,3]
li2 = li1
li3 = li2
print(li1 is li2)
print(id(li1),id(li2))

# 数字,字符串 小数字池
# 数字的范围-5 -- 256(pycharm会影响实验结果)
# 字符串: 1.不能含有特殊字符 2.s*20 还是同一个地址,s*21以后都是两个地址(3.7该规则变成4096个字符)

i1 = 6
i2 = 6
print(id(i1),id(i2))

i1 = 400
i2 = 400
print(id(i1),id(i2))

s1 = 'oracle'
s2 = 'oracle'
print(id(s1),id(s2))


s1 = 'oracle#'
s2 = 'oracle#'
print(id(s1),id(s2))


s1 = 'o'*20
s2 = 'o'*20
print(id(s1),id(s2))

s1 = 'o'*21
s2 = 'o'*21
print(id(s1),id(s2))

# 剩下的list dict tuple set无数据池
li1 = [1]
li2 = [1]
print(id(li1),id(li2))

# 编码
# 1.各个编码之间的二进制,是不能互相识别的,会产生乱码
# 2.文件的存储,传输,不能使用unicode(只能使用utf-8 utf-16 gbk gbk2312 ascii等)

# Python3 str在内存中是用unicode编码的.
# bytes类型(使用utf-8 utf-16 gbk gbk2312 ascii等)
# 对于英文
# str     表现形式  s = 'oralce'
#         编码形式  00001000 unicode
# bytes   表现形式  s = b'oralce'
#         编码形式  00001000 utf-8等

s1 = 'oracle'
s2 = b'oracle'
print(s1,type(s1))
print(s2,type(s2))

# 对于英文
# str     表现形式  s = '数据'
#         编码形式  00001000 unicode
# bytes   表现形式  s = b'x\e91\91\e01\e21\e31\e32\'
#         编码形式  00001000 utf-8,gbk等
# 报错4个字节gbk,6个字节utf-8

s1 = '我'
print(s1,type(s1))
s2 = b'我'
print(s2,type(s2))

# encode编码 str --> bytes
s1 = 'oracle'
# s2 = s1.encode()
# s2 = s1.encode('utf-8')
s2 = s1.encode('gbk')
print(s2)

s1 = '中国'
s2 = s1.encode()
# s2 = s1.encode('utf-8')
# s2 = s1.encode('gbk')
print(s2)