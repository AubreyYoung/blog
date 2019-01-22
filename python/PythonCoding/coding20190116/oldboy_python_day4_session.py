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

# 列表
li = [1,[1,2,3],'a','b',2,3,'a']

print(li[0])
print(li[0:3])

# 增加
# append
li = [1,[1,2,3],'a','b',2,3,'a']

li.append('oracle')
print(li)

print(li.append('oracle'))  # 无返回值,返回None

li = []

while 1:
    name = input("请输入:")
    if name.strip().upper() == 'KILL':
        break
    else:
        li.append(name)
print(li)

# insert
li = [1,[1,2,3],'a','b',2,3,'a']
li.insert(-1,'oracle')
print(li)

# extend 迭代添加的是元素,int不可以迭代
li.extend('mysql')
print(li)

li.extend([1,2,3])
print(li)

# pop 有返回值
li = [1,[1,2,3],'a','b',2,3,'a']
name = li.pop(0)
name = li.pop()  # 默认删除最后一个
print(name,li)

# remove  默认删除第一个
li = [1,[1,2,3],'a','b',2,3,'a']
li.remove('a')
print(li)

# clear
li = [1,[1,2,3],'a','b',2,3,'a']
li.clear()
print(li)

# del
li = [1,[1,2,3],'a','b',2,3,'a']
del li
print(li)

li = [1,[1,2,3],'a','b',2,3,'a']
# del li[0:2]  # 切片删除
del li[4:]
print(li)

# 改
li = [1,[1,2,3],'a','b',2,3,'a']
li[-1] = 'mysql'
print(li)

li = [1,[1,2,3],'a','b',2,3,'a']
# li[0:2] = 'oralce'
li[0:2] = [4,5,6,'oracle']
print(li)

# 查
li = [1,[1,2,3],'a','b',2,3,'a']

for i in li:
    print(i)

li = [1,[1,2,3],'a','b',2,3,'a']

for i in li[1:3]:
    print(i)

# 公共方法
# len
li = [1,[1,2,3],'a','b',2,3,'a']
l = len(li)
print(l)
print(len('oracle'))

# count
li = [1,[1,2,3],'a','b',2,3,'a']

print(li.count('a'))

#index
li = [1,[1,2,3],'a','b',2,3,'a']

print(li.index('a',0,2))

# sort
li = [12313,43432254,767634,21312321]

# li.sort()
li.sort(reverse=True)
print(li)

# reverse
li = [1,[1,2,3],'a','b',2,3,'a']
li.reverse()
print(li)

# 列表的嵌套
li = [1,[1,2,3],'a','b',2,'mysql','linux']

print(li[1][2])

li[li.index('mysql')] = li[li.index('mysql')].capitalize()
print(li)

# replace
li = [1,[1,2,3],'a','b',2,'mysql',['linux','oracle']]

li[-2] = li[-2].replace('m','M')
print(li)

li[li.index('linux')] = li[li.index('linux')].upper()  # 报错

print(li)

# 元祖tuple
# 只读列表,可循环查询,可切片
# 儿子不能改,孙子可能可以改

tuple = (1,[1,2,3],'a','b',2,'mysql',['linux','oracle'])

print(tuple[-1])
print(tuple[1:4])

for i in tuple:
    print(i)

tuple = (1,[1,2,3],'a','b',2,'mysql',['linux','oracle'])
tuple[-1][0] = tuple[-1][0].upper()
print(tuple)

tuple[-1].append('MongoDB')
print(tuple)


# join
s = 'Aubrey'
print("_".join(s))

# join 列表 --> 字符串
list = ['a','b','mysql']
print(''.join(list))  # 列表中元素不能是int、list等其他类型



# range 实际为数字列表

for i in range(0,100,2):
    print(i)

for i in range(100,0,-20):
    print(i)

for i in range(0,10,-1):  # 运行结果为空
    print(i)

for i in range(100,-20,-20):
    print(i)


# 循环递归打印
list = [1,[1,2,3],'a','b',2,'mysql',['linux','oracle']]

if isinstance(i,list):
    for i in
else:
    print(i)