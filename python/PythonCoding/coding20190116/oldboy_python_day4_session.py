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
@file: oldboy_python_day3_session.py
@Date:2019/1/17 8:39
-------------------------------------------------
"""

# 索引
a = 'ABCDEFGHIJK'
print(a[0])  # A
print(a[3])  # D
print(a[5])  # F
print(a[7])  # H

# 分片
a = 'ABCDEFGHIJK'
print(a[0:3])  # ABC
print(a[2:5])  # CDE
print(a[0:])  # 默认到最后 # ABCDEFGHIJK
print(a[0:-1])  # -1 是列表中最后一个元素的索引，但是要满足顾头不顾腚的原则，所以取不到K元素  # ABCDEFGHIJ
print(a[0:5:2])  # 加步长  # ACE
print(a[5:0:-2])  # 反向加步长 FDB
a = 'ABCDEFGHIJK'
print(a[:])  # 取整个字符串
print(a[0:0])  # 空
print(a[5::-2])
print(a[::])
print(a[-1::-1])
print(a[::-1])

# 常用方法
name = 'auBrey'
# aptalize,swapcase,title
# print(name.capitalize()) #首字母大写
# print(name.upper())
# print(name.lower())

# print(name.swapcase()) #大小写翻转\
# msg = 'taibai say hi'
# print(msg.title()) #每个单词的首字母大写,分割符为空格,数字

# 内容居中，总长度，空白处填充
a = 'Ora\tcle'
ret2 = a.center(20,"*")
print(ret2)

b = 'O\tcle'
print(b.expandtabs())

c = 'O\tc le'
d = '瀚高'
print(c.__len__())
print(d.__len__())

e = 'Aubrey Young'
print(e.startswith('Aub'))
print(e.startswith('aub'))
print(e.startswith('b',2,6))

print(e.find('y'))
print(e.find('Yo'))
print(e.find('x'))
print(e.index('u'))
# print(e.index('x'))
f = ' Aubrey Young '

g = '&Aubrey %Young% '
print(e.strip())
print(f.strip())
print(g.strip(' %&'))

print(e.rstrip(' '))
print(e.lstrip(' '))

# 数字符串中的元素出现的个数。
ret = e.count("Au",0,4) # 可切片
print(ret)

a4 = "dkfjdkfasf54"
# startswith 判断是否以...开头
# endswith 判断是否以...结尾
ret4 = a4.endswith('jdk',3,6)  # 顾头不顾腚
print(ret4)  # 返回的是布尔值
ret5 = a4.startswith("kfj",1,4)
print(ret5)

# 寻找字符串中的元素是否存在
ret6 = a4.find("fjdk",1,6)
print(ret6)  # 返回的找到的元素的索引，如果找不到返回-1


ret61 = a4.index("fjdk",4,6)
print(ret61)  # 返回的找到的元素的索引，找不到报错。

# split 以什么分割，最终形成一个列表此列表不含有这个分割的元素。
s1 = 'title Tilte atre'
print(s1.split())
print(s1.split('T'))
s2 = ' title Tilte atre'
print(s2.split())
s3 = ':title:Tilte:atre'
s4 = ' title Tilte atre'
print(s3.split(':'))
print(s4.split('T'))

# Python rsplit() 方法通过指定分隔符对字符串进行分割并返回一个列表，默认分隔符为所有空字符，包括空格、换行(\n)、制表符(\t)等。类似于 split() 方法，只不过是从字符串最后面开始分割。

S = "this is string example....wow!!!"
print(S.rsplit())
print(S.split())
print(S.rsplit('i',1))
print(S.split('i',1))
print(S.rsplit('w'))
# strip
name = '*barry**'
print(name.strip('*'))
print(name.lstrip('*'))
print(name.rstrip('*'))

# format的三种玩法 格式化输出
res ='{} {} {}'.format('egon',18,'male')
res ='{1} {0} {1}'.format('egon',18,'male')
res ='{name} {age} {sex}'.format(sex='male',name='egon',age=18)

s = '我叫{},今年{},爱好{},家在{}'.format('Aubrey',30,'db','JN')
print(s)

s = '我叫{0},今年{1},爱好{2},家在{3},再说一遍我叫{0}'.format('Aubrey',30,'db','JN')
print(s)

s = '我叫{name},今年{age},爱好{hobby},家在{home},再说一遍我叫{name}'.format(name='Aubrey',age=30,hobby='db',home='JN')
print(s)

name = input("请输入名字:")
s = '我叫{0},今年{1},爱好{2},家在{3},再说一遍我叫{0}'.format(name,30,'db','JN')
print(s)

# replace
name = 'alex say :i have one tesla,my name is alex'
print(name.replace('alex','SB',1))
print(name.replace('alex','SB'))

# is系列
name = 'taibai123'
print(name.isalnum())  # 字符串由字母或数字组成
print(name.isalpha())  # 字符串只由字母组成
print(name.isdigit())  # 字符串只由数字组成

# for
s = 'adadadada'

for i in s:
    print(i)

# 数据类型
# int
i = 2
print(i.bit_length())

# int --> str
i = 1
s = str(i)

#str --> int
int('1233')

# bool
# int --> bool :0 --> False;非0 --> True
print(bool(3))

# bool --> int
# Tre --> 1
# False --> 0
# ps:
while True:
    pass

while 1:  # 效率高
    pass

# str --> bool
s = ""  # -->False
s = " "  # --> True
s = "0"  # --> True

s = input("请输入:")

if s:
    print("您输入的为空,请重新输入!")
else:
    pass