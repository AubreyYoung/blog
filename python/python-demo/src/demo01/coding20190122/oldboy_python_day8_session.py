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

# r bytes -- str
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\10.225.11.115_20190123_091734.log', mode='r',
         encoding='utf-8')
content = f.read()
print(content)
# print(f,type(f))
f.close()

# rb
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test1.txt', mode='rb')
content = f.read()
print(content)
f.close()

# 对于w,无该文件则创建
# 有文件,先将原文件的内容全部清除,再写
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='w', encoding='utf-8')
f.write('redis')
f.close()

# wb
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='wb')
f.write('linux'.encode('utf-8'))
f.close()

# a
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='a', encoding='utf-8')
f.write('mysql')
f.close()

# r+
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='r+', encoding='utf-8')
content = f.read()
print(content)
f.write('mysql')
print(f.read())
f.close()

# r+
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='r+', encoding='utf-8')
f.write('oracle')
print(f.read())
f.close()

# r+b
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='r+b')
f.write('oracle'.encode('UTF-8'))
print(f.read())
f.close()

# w+
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='w+')
f.write('oracle')
f.seek(0)
print(f.read())
f.close()

# seek 光标按照字节定光标的位置
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\10.225.11.115_20190123_091734.log', mode='r',
         encoding='utf-8')
f.seek(400)
print(f.tell())  # 打印光标位置
content = f.read(100)  # 读出来的都是字符
print(content)
# print(f,type(f))
f.close()

f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\test2.txt', mode='a+', encoding='utf-8')
f.write('mysql')
count = f.tell()
f.seek(count - 2)
print(f.read())
f.close()

# readline  一行一行的读
# readlines 每一行当成列表中的一个元素,添加到list中
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\10.225.11.115_20190123_091734.log', mode='r',
         encoding='utf-8')
print(f.tell())  # 打印光标位置
# content = f.readline()  # 读出来的都是字符
# print(content)
content = f.readlines()
print(f.tell())
# print(f,type(f))
f.close()

# truncate

# 循环
f = open('D:\Git\\blog\python\PythonCoding\coding20190123\\10.225.11.115_20190123_091734.log', mode='r',
         encoding='utf-8')
for i in f:
    print(i)
f.close()

# 自动关闭打开文件
with open('D:\Git\\blog\python\PythonCoding\coding20190123\\10.225.11.115_20190123_091734.log', mode='r',
          encoding='utf-8') as obj, open('D:\Git\\blog\python\PythonCoding\coding20190123\\test1.txt', mode='r',
                                         encoding='utf-8') as obj2:
    obj.read()
    print(obj.read())


# 账号注册,登陆验证
username = input('请输入用户名:')
password = input('请输入密码:')

with open('D:\Git\\blog\python\PythonCoding\coding20190123\\users.txt', mode='w+', encoding='UTF-8') as userfile1:
    userfile1.write('{}\n{}'.format(username, password))
    print("注册成功!")

i = 0
lis = []
while i < 3:
    usn = input('用户名:')
    pwd = input('密码:')
    with open('D:\Git\\blog\python\PythonCoding\coding20190123\\users.txt', mode='r', encoding='UTF-8') as userfile2:
        for x in userfile2:
            lis.append(x)
        if usn == lis[0].strip() and pwd == lis[1].strip():
            print("登陆成功!")
            break
        else:
            i += 1
            print("登录失败")